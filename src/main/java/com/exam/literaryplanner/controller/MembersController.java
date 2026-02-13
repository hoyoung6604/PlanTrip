package com.exam.literaryplanner.controller;

import java.util.Map;
import java.util.Optional;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.service.LiteraryService;
import com.exam.literaryplanner.service.MailService;
import com.exam.literaryplanner.service.PasswordResetService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/members")
public class MembersController {

    private final LiteraryService literaryService;
    private final PasswordResetService passwordResetService;
    private final MailService mailService;

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
       로그인 처리 (페이지)
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
       로그인 처리 (AJAX)
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

        String redirectTo = (member.getMRole() != null && member.getMRole() == 9) ? "/admin" : "/";

        return ResponseEntity.ok(Map.of(
                "ok", true,
                "redirectTo", redirectTo
        ));
    }

    /* =====================
       아이디 찾기
       ===================== */
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
       회원가입 처리 (페이지)
       ===================== */
    @PostMapping("/register")
    public String register(Member member, Model model) {
        try {
            literaryService.register(member);
        } catch (DataIntegrityViolationException e) {
            model.addAttribute("error", resolveDuplicateMessage(e));
            return "members/register";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "members/register";
        }
        return "redirect:/members/login";
    }

    /* =====================
       회원가입 처리 (AJAX)
       ===================== */
    @PostMapping(value = "/register", headers = "X-Requested-With=XMLHttpRequest")
    @ResponseBody
    public ResponseEntity<?> registerAjax(Member member, HttpSession session) {

        String rawId = member.getMId();
        String rawPw = member.getMPw();

        try {
            literaryService.register(member);
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "ok", false,
                    "message", resolveDuplicateMessage(e)
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "ok", false,
                    "message", e.getMessage()
            ));
        }

        // 가입 직후 자동 로그인
        if (rawId != null && rawPw != null) {
            literaryService.login(rawId, rawPw)
                    .ifPresent(m -> session.setAttribute("loginMember", m));
        }

        return ResponseEntity.ok(Map.of(
                "ok", true,
                "redirectTo", "/"
        ));
    }

    private String resolveDuplicateMessage(DataIntegrityViolationException e) {
        String msg = "이미 사용 중인 정보가 있습니다. 다시 확인해 주세요.";
        String m = (e.getMostSpecificCause() != null ? e.getMostSpecificCause().getMessage() : e.getMessage());
        if (m != null) {
            String lower = m.toLowerCase();
            if (lower.contains("m_email") || lower.contains("email")) msg = "이미 가입된 이메일입니다.";
            else if (lower.contains("m_id") || lower.contains("id")) msg = "이미 사용 중인 아이디입니다.";
        }
        return msg;
    }

    /* =====================
       비밀번호 재설정
       ===================== */
    @GetMapping("/find-password")
    public String findPasswordForm() {
        return "members/find-password";
    }

    @PostMapping("/find-password")
    public String sendResetLink(@RequestParam String email,
                                HttpServletRequest request,
                                Model model) {

        String baseUrl = buildBaseUrl(request);
        passwordResetService.sendResetLink(email, baseUrl);

        model.addAttribute("message", "입력하신 이메일로 재설정 링크를 발송했습니다. 메일함을 확인해주세요.");
        return "members/find-password";
    }

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

    private String buildBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String host = request.getServerName();
        int port = request.getServerPort();

        boolean isDefaultPort = ("http".equalsIgnoreCase(scheme) && port == 80)
                || ("https".equalsIgnoreCase(scheme) && port == 443);

        return scheme + "://" + host + (isDefaultPort ? "" : ":" + port);
    }
}
