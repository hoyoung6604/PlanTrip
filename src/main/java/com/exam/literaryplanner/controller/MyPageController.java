package com.exam.literaryplanner.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.Community;
import com.exam.literaryplanner.repository.LiteraryRepository;
import com.exam.literaryplanner.repository.CommunityRepository;
import com.exam.literaryplanner.service.MemberDeleteService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/members/mypage")
public class MyPageController {

    private final PasswordEncoder passwordEncoder;
    private final LiteraryRepository literaryRepository;
    private final CommunityRepository reviewRepository;
    private final MemberDeleteService memberDeleteService;

    public MyPageController(LiteraryRepository literaryRepository,
                            CommunityRepository reviewRepository,
                            PasswordEncoder passwordEncoder,
                            MemberDeleteService memberDeleteService) {
        this.literaryRepository = literaryRepository;
        this.reviewRepository = reviewRepository;
        this.passwordEncoder = passwordEncoder;
        this.memberDeleteService = memberDeleteService;
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

        Member member = literaryRepository.findById(loginMember.getMIdx()).orElseThrow();

        // ✅ BCrypt 비교는 matches()
        if (!passwordEncoder.matches(password, member.getMPw())) {
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
            // ✅ 저장은 encode()
            member.setMPw(passwordEncoder.encode(mPw));
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

        List<Community> reviews;
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

    @PostMapping("/withdraw")
    public String withdraw(HttpSession session) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
			return "redirect:/members/login";
		}

        Integer mIdx = loginMember.getMIdx();

        // ✅ DB에 바로 DELETE (강제)
        literaryRepository.deleteMemberNative(mIdx);

        session.invalidate();
        return "redirect:/";
    }

}

