package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.repository.LiteraryRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/members/mypage")
public class MyPageController {

    private final LiteraryRepository literaryRepository;

    public MyPageController(LiteraryRepository literaryRepository) {
        this.literaryRepository = literaryRepository;
    }

    @GetMapping
    public String mypage(HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        return "members/mypage/mypage";
    }

    @GetMapping("/check")
    public String checkForm(HttpSession session) {

        if (session.getAttribute("loginMember") == null) {
            return "redirect:/members/login";
        }

        return "members/mypage/check";
    }

    @PostMapping("/check")
    public String checkPassword(@RequestParam String password,
                                HttpSession session,
                                Model model) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        Member member = literaryRepository.findById(loginMember.getId())
                .orElseThrow();

        if (!member.getPassword().equals(password)) {
            model.addAttribute("error", "비밀번호가 일치하지 않습니다.");
            return "members/mypage/check";
        }

        session.setAttribute("authEdit", true);
        return "redirect:/members/mypage/edit";
    }

    @GetMapping("/edit")
    public String editForm(HttpSession session, Model model) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        Boolean authEdit = (Boolean) session.getAttribute("authEdit");

        if (loginMember == null || authEdit == null) {
            return "redirect:/members/mypage";
        }

        Member member = literaryRepository.findById(loginMember.getId())
                .orElseThrow();

        model.addAttribute("member", member);
        return "members/mypage/edit";
    }

    @PostMapping("/edit")
    public String editSubmit(@ModelAttribute Member formMember,
                             HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        Boolean authEdit = (Boolean) session.getAttribute("authEdit");

        if (loginMember == null || authEdit == null) {
            return "redirect:/members/mypage";
        }

        Member member = literaryRepository.findById(loginMember.getId())
                .orElseThrow();

        member.setName(formMember.getName());
        member.setAge(formMember.getAge());
        member.setGender(formMember.getGender());
        member.setEmailAddress(formMember.getEmailAddress());

        literaryRepository.save(member);
        session.removeAttribute("authEdit");

        return "redirect:/members/mypage";
    }

    @GetMapping("/plans")
    public String myPlans(HttpSession session, Model model) {

        if (session.getAttribute("loginMember") == null) {
            return "redirect:/members/login";
        }

        List<Map<String, String>> plans = new ArrayList<>();
        model.addAttribute("plans", plans);

        return "members/mypage/plans";
    }

    @GetMapping("/reviews")
    public String myReviews(HttpSession session, Model model) {

        if (session.getAttribute("loginMember") == null) {
            return "redirect:/members/login";
        }

        List<Map<String, String>> reviews = new ArrayList<>();
        model.addAttribute("reviews", reviews);

        return "members/mypage/reviews";
    }
}
