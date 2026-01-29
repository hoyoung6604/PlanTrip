package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.service.LiteraryService;
import jakarta.servlet.http.HttpSession;

import java.util.Optional;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/members")
public class MembersController {

    private final LiteraryService literaryService;

    public MembersController(LiteraryService literaryService) {
        this.literaryService = literaryService;
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

        Optional<Member> loginMember =
                literaryService.login(id, password);

        if (loginMember.isEmpty()) {
            model.addAttribute("error", "아이디 또는 비밀번호가 틀렸습니다.");
            return "members/login";
        }

        // ✅ 세션 저장
        session.setAttribute("loginMember", loginMember.get());

        // ✅ 무조건 메인으로
        return "redirect:/";
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

}

