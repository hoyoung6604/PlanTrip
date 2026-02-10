package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.service.LiteraryService;
import com.exam.literaryplanner.service.MailService;
import com.exam.literaryplanner.service.PasswordResetService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.util.Optional;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.dao.DataIntegrityViolationException;

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
       로그인 처리 (기존 페이지 방식)
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
        session.setAttribute("loginMember", member);

        if (member.getMRole() != null && member.getMRole() == 9) {
            return "redirect:/admin";
        }

        return "redirect:/";
    }

    /* =====================
       [추가] 모달(AJAX) 로그인 처리
       - auth-modal.js(fetch)가 보내는 X-Requested-With 헤더가 있을 때만 매핑됨
       - 페이지 이동 없이 JSON 반환
       ===================== */
    @PostMapping(value = "/login", headers = "X-Requested-With=XMLHttpRequest")
    @ResponseBody
    public ResponseEntity<?> loginAjax(@RequestParam String id,
                                       @RequestParam String password,
                                       HttpSession session) {

        Optional<Member> loginMemberOpt = literaryService.login(id, password);

        if (loginMemberOpt.isEmpty()) {
            return ResponseEntity.status(401).body(Map.of(
                    "ok", false,
                    "message", "아이디 또는 비밀번호가 틀렸습니다."
            ));
        }

        Member member = loginMemberOpt.get();
        session.setAttribute("loginMember", member);

        String redirectTo = "/";
        if (member.getMRole() != null && member.getMRole() == 9) {
            redirectTo = "/admin";
        }

        return ResponseEntity.ok(Map.of(
                "ok", true,
                "redirectTo", redirectTo
        ));
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

    /* =====================
       회원가입 화면
       ===================== */
    @GetMapping("/register")
    public String registerForm() {
        return "members/register";
    }

    /* =====================
       회원가입 처리 (기존 페이지 방식)
       ===================== */
    @PostMapping("/register")
    public String register(Member member, Model model) {

        try {
            literaryService.register(member);
        } catch (DataIntegrityViolationException e) {
            String msg = "이미 사용 중인 정보가 있습니다. 다시 확인해 주세요.";
            String m = (e.getMostSpecificCause() != null ? e.getMostSpecificCause().getMessage() : e.getMessage());
            if (m != null) {
                String lower = m.toLowerCase();
                if (lower.contains("m_email") || lower.contains("email")) msg = "이미 가입된 이메일입니다.";
                else if (lower.contains("m_id") || lower.contains("id")) msg = "이미 사용 중인 아이디입니다.";
            }
            model.addAttribute("error", msg);
            return "members/register";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "members/register";
        }

        return "redirect:/members/login";
    }

    /* =====================
       [추가] 모달(AJAX) 회원가입 처리
       - 페이지 이동 없이 JSON 반환
       - 가입 성공 후 자동 로그인까지 시도해서 모달에서 “바로 로그인 상태”가 되도록 처리
       ===================== */
    @PostMapping(value = "/register", headers = "X-Requested-With=XMLHttpRequest")
    @ResponseBody
    public ResponseEntity<?> registerAjax(Member member, HttpSession session) {

        // 자동 로그인용(가입 전 비번 원문 보관)
        String rawPw = member.getMPw();
        String rawId = member.getMId();

        try {
            literaryService.register(member);

        } catch (DataIntegrityViolationException e) {
            String msg = "이미 사용 중인 정보가 있습니다. 다시 확인해 주세요.";
            String m = (e.getMostSpecificCause() != null ? e.getMostSpecificCause().getMessage() : e.getMessage());
            if (m != null) {
                String lower = m.toLowerCase();
                if (lower.contains("m_email") || lower.contains("email")) msg = "이미 가입된 이메일입니다.";
                else if (lower.contains("m_id") || lower.contains("id")) msg = "이미 사용 중인 아이디입니다.";
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "ok", false,
                    "message", msg
            ));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "ok", false,
                    "message", e.getMessage()
            ));
        }

        // ✅ 가입 직후 자동 로그인
        Optional<Member> loginOpt = Optional.empty();
        if (rawId != null && rawPw != null) {
            loginOpt = literaryService.login(rawId, rawPw);
        }
        loginOpt.ifPresent(m -> session.setAttribute("loginMember", m));

        return ResponseEntity.ok(Map.of(
                "ok", true,
                "redirectTo", "/"
        ));
    }

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
    public Object sendResetLink(@RequestParam String email,
                                HttpServletRequest request,
                                Model model) {

        String baseUrl = buildBaseUrl(request);
        passwordResetService.sendResetLink(email, baseUrl);

        String msg = "입력하신 이메일로 재설정 링크를 발송했습니다. 메일함을 확인해주세요.";
        String xr = request.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equalsIgnoreCase(xr)) {
            return ResponseEntity.ok(Map.of(
                    "ok", true,
                    "message", msg
            ));
        }

        model.addAttribute("message", msg);
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
