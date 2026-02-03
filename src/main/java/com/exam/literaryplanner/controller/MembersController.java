package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.service.LiteraryService;
import com.exam.literaryplanner.service.MailService;
import com.exam.literaryplanner.service.PasswordResetService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.util.Optional;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/members")
public class MembersController {

    private final LiteraryService literaryService;
    private final PasswordResetService passwordResetService;
    private final MailService mailService; // 아이디 찾기를 이메일로 보내고 싶으면 사용

    public MembersController(LiteraryService literaryService,
            PasswordResetService passwordResetService,
            MailService mailService) {
    	this.literaryService = literaryService;
    	this.passwordResetService = passwordResetService;
    	this.mailService = mailService;
    }

    /* =====================
       로그인 화면
       ===================== */
    @GetMapping("/login")
    public String loginForm() {
        return "members/login";
    }

    /* =====================
       로그인 처리
       ===================== */
    @PostMapping("/login")
    public String login(@RequestParam String id,
                        @RequestParam String password,
                        HttpSession session,
                        Model model) {

        Optional<Member> loginMemberOpt = literaryService.login(id, password);

        if (loginMemberOpt.isEmpty()) {
            model.addAttribute("error", "아이디 또는 비밀번호가 틀렸습니다.");
            return "members/login";
        }

        Member member = loginMemberOpt.get();

        // ✅ 세션 저장(1번만)
        session.setAttribute("loginMember", member);

        // ✅ 관리자면 관리자 메인으로
        if (member.getMRole() != null && member.getMRole() == 9) {
            return "redirect:/admin";
        }

        // ✅ 일반 유저는 메인으로
        return "redirect:/";
    }

 // -----------------------------
    // 아이디 찾기 (이메일로)
    // -----------------------------
    @GetMapping("/find-id")
    public String findIdForm() {
        return "members/find-id";
    }

    @PostMapping("/find-id")
    public String findId(@RequestParam String email, Model model) {
        // 서비스/리포지토리에서 이메일로 찾기
        // (LiteraryService에 메서드가 없다면 Repository 직접 쓰거나 서비스에 추가해야 함)
        // 여기서는 LiteraryService에 findByEmail이 없다고 가정하고 login 서비스처럼 Repository 메서드가 있을 수 있으니
        // 우선 안내용으로 model만 넣어둠.

        // ✅ 추천: LiteraryService에 아래 메서드 하나 추가:
        // public Optional<Member> findByEmail(String email){ return literaryRepository.findByMEmail(email); }

        model.addAttribute("message", "입력하신 이메일로 가입된 계정이 있다면 안내해 드립니다.");
        return "members/find-id";
    }
    
    /* =====================
       로그아웃
       ===================== */
    @PostMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }
    
    @GetMapping("/register")
    public String registerForm() {
        return "members/register";
    }
    
    @PostMapping("/register")
    public String register(Member member, Model model) {

        try {
            literaryService.register(member);
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "members/register";
        }

        return "redirect:/members/login";
    }
    
    //라이트모드 다크모드 추가 이후에 생겼던 로그인 문제 해결 방안 코드 
	/*
	 * @GetMapping("/login") public String legacyLoginRedirect() { return
	 * "redirect:/members/login"; }
	 * 
	 * @PostMapping("/logout") public String legacyLogoutRedirect(HttpSession
	 * session) { session.invalidate(); return "redirect:/"; }
	 */

 // -----------------------------
    // 비밀번호 재설정(토큰 링크 방식)
    // 1) 이메일 입력 페이지
    // -----------------------------
    @GetMapping("/find-password")
    public String findPasswordForm() {
        return "members/find-password";
    }

    // 2) 링크 발송 요청
    @PostMapping("/find-password")
    public String sendResetLink(@RequestParam String email,
                                HttpServletRequest request,
                                Model model) {

        String baseUrl = buildBaseUrl(request);
        passwordResetService.sendResetLink(email, baseUrl);

        // 보안상: 이메일 존재 여부와 무관하게 동일 메시지
        model.addAttribute("message", "입력하신 이메일로 재설정 링크를 발송했습니다. 메일함을 확인해주세요.");
        return "members/find-password";
    }

    // 3) 링크 클릭 -> 새 비번 입력 폼
    @GetMapping("/password/reset")
    public String resetPasswordForm(@RequestParam String token, Model model) {
        try {
            passwordResetService.validateToken(token);
            model.addAttribute("token", token);
            return "members/reset-password";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "members/reset-password-invalid";
        }
    }

    // 4) 새 비번 제출
    @PostMapping("/password/reset")
    public String resetPassword(@RequestParam String token,
                                @RequestParam String password,
                                @RequestParam String passwordConfirm,
                                Model model) {

        if (password == null || password.isBlank()) {
            model.addAttribute("token", token);
            model.addAttribute("error", "비밀번호를 입력해 주세요.");
            return "members/reset-password";
        }

        if (!password.equals(passwordConfirm)) {
            model.addAttribute("token", token);
            model.addAttribute("error", "비밀번호가 일치하지 않습니다.");
            return "members/reset-password";
        }

        try {
            passwordResetService.resetPassword(token, password);
            return "redirect:/members/login?reset=success";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "members/reset-password-invalid";
        }
    }

    // -----------------------------
    // util
    // -----------------------------
    private String buildBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String host = request.getServerName();
        int port = request.getServerPort();

        boolean isDefaultPort = ("http".equalsIgnoreCase(scheme) && port == 80)
                || ("https".equalsIgnoreCase(scheme) && port == 443);

        return scheme + "://" + host + (isDefaultPort ? "" : ":" + port);
    }
    
}

