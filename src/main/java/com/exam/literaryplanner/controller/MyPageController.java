package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.Review;
import com.exam.literaryplanner.repository.LiteraryRepository;
import com.exam.literaryplanner.repository.ReviewRepository;
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
    private final ReviewRepository reviewRepository;

    public MyPageController(LiteraryRepository literaryRepository,
                            ReviewRepository reviewRepository) {
        this.literaryRepository = literaryRepository;
        this.reviewRepository = reviewRepository;
    }

    /* ================= 마이페이지 메인 ================= */
    @GetMapping
    public String mypage(HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        return "members/mypage/mypage";
    }

    /* ================= 비밀번호 확인 ================= */
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

        Member member = literaryRepository.findById(loginMember.getMIdx())
                .orElseThrow();

        if (!member.getMPw().equals(password)) {
            model.addAttribute("error", "비밀번호가 일치하지 않습니다.");
            return "members/mypage/check";
        }

        session.setAttribute("authEdit", true);
        return "redirect:/members/mypage/edit";
    }

    /* ================= 회원정보 수정 ================= */
    @GetMapping("/edit")
    public String editForm(HttpSession session, Model model) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        Boolean authEdit = (Boolean) session.getAttribute("authEdit");

        if (loginMember == null || authEdit == null || !authEdit) {
            return "redirect:/members/mypage";
        }

        Member member = literaryRepository.findById(loginMember.getMIdx())
                .orElseThrow();

        model.addAttribute("member", member);
        return "members/mypage/edit";
    }

    @PostMapping("/edit")
    public String editMember(@RequestParam String mName,
                             @RequestParam String mEmail,
                             @RequestParam(required = false) String mPw,
                             @RequestParam(required = false) String mPwConfirm,
                             HttpSession session,
                             Model model) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        Boolean authEdit = (Boolean) session.getAttribute("authEdit");

        if (loginMember == null || authEdit == null || !authEdit) {
            return "redirect:/members/login";
        }

        Member member = literaryRepository.findById(loginMember.getMIdx()).orElseThrow();

        member.setMName(mName);
        member.setMEmail(mEmail);

        // 비번 변경 요청이 들어온 경우만
        if (mPw != null && !mPw.isBlank()) {
            if (mPwConfirm == null || !mPw.equals(mPwConfirm)) {
                model.addAttribute("member", member);
                model.addAttribute("error", "새 비밀번호가 일치하지 않습니다.");
                return "members/mypage/edit";
            }
            member.setMPw(mPw);
        }

        literaryRepository.save(member);

        session.setAttribute("loginMember", member);
        session.removeAttribute("authEdit");

        return "redirect:/members/mypage";
    }


    /* ================= 나의 일정 ================= */
    @GetMapping("/plans")
    public String myPlans(HttpSession session, Model model) {

        if (session.getAttribute("loginMember") == null) {
            return "redirect:/members/login";
        }

        List<Map<String, String>> plans = new ArrayList<>();
        model.addAttribute("plans", plans);

        return "members/mypage/plans";
    }

    /* ================= 내가 쓴 후기 ================= */
    @GetMapping("/reviews")
    public String myReviews(@RequestParam(required = false) String keyword,
                            HttpSession session,
                            Model model) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        List<Review> reviews;
        if (keyword != null && !keyword.isBlank()) {
            reviews = reviewRepository.findByMIdxAndRvTitleContainingOrderByRvIdxDesc(
                    loginMember.getMIdx(),
                    keyword.trim()
            );
        } else {
            reviews = reviewRepository.findByMIdxOrderByRvIdxDesc(loginMember.getMIdx());
        }

        model.addAttribute("reviews", reviews);
        model.addAttribute("keyword", keyword);

        return "members/mypage/reviews";
    }
}

