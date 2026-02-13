package com.exam.literaryplanner.config;

import java.io.IOException;
import java.security.SecureRandom;

import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.repository.LiteraryRepository;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
public class OAuth2LoginSuccessHandler implements AuthenticationSuccessHandler {

    private final LiteraryRepository literaryRepository;
    private final PasswordEncoder passwordEncoder;

    public OAuth2LoginSuccessHandler(LiteraryRepository literaryRepository,
                                     PasswordEncoder passwordEncoder) {
        this.literaryRepository = literaryRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {

        Object principal = authentication.getPrincipal();

        // 구글은 보통 OIDC라서 OidcUser로 들어옴(아니면 OAuth2User)
        String subject;
        String email;
        String name;

        if (principal instanceof OidcUser oidcUser) {
            subject = oidcUser.getSubject();                 // 구글 고유ID(sub)
            email = oidcUser.getEmail();                     // 이메일
            name = oidcUser.getFullName();                   // 이름(없으면 아래로 대체)
            if (name == null || name.isBlank()) {
				name = oidcUser.getGivenName();
			}
        } else {
            OAuth2User user = (OAuth2User) principal;
            subject = String.valueOf(user.getAttribute("sub"));
            email = user.getAttribute("email");
            name = user.getAttribute("name");
        }

        // ✅ sns_id 저장 규칙 (추천)
        String snsId = "google:" + subject;

        // 1) snsId로 기존 회원 찾기
        Member member = literaryRepository.findBySnsId(snsId).orElse(null);

        // 2) 없으면 자동 회원가입(또는 email로 연결하고 싶으면 email로 한번 더 검색 가능)
        if (member == null) {
            member = new Member();

            // m_id는 유니크라서 자동 생성(원하는 규칙으로 바꾸면 됨)
            member.setMId("google_" + subject.substring(0, Math.min(10, subject.length())));

            // pw는 소셜로그인에서는 안 쓰지만 NOT NULL이라 랜덤+암호화로 채움
            member.setMPw(passwordEncoder.encode(randomPassword(20)));

            member.setMName((name != null && !name.isBlank()) ? name : "구글사용자");
            member.setMEmail((email != null && !email.isBlank()) ? email : (member.getMId() + "@google.local"));
            member.setMRole(1);
            member.setSnsId(snsId);

            member = literaryRepository.save(member);
        }

        // ✅ 여기서 너희 방식대로 “세션 로그인”을 만들어줌
        HttpSession session = request.getSession();
        session.setAttribute("loginMember", member);
        session.setAttribute("loginUserName", member.getMName()); // 너 JSP에서 쓰는 값도 같이

        // 원하는 곳으로 이동
        response.sendRedirect(request.getContextPath() + "/");
    }

    private String randomPassword(int len) {
        final String chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*";
        SecureRandom r = new SecureRandom();
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) {
			sb.append(chars.charAt(r.nextInt(chars.length())));
		}
        return sb.toString();
    }
}
