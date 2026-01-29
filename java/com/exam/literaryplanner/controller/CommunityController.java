package com.exam.literaryplanner.controller;

import jakarta.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.exam.literaryplanner.domain.Review;
import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.repository.ReviewRepository;



@Controller
@RequestMapping("/community")
public class CommunityController {

    private final ReviewRepository reviewRepository;

    CommunityController(ReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    /** 커뮤니티 메인 */
    @GetMapping
    public String communityMain(Model model) {

        model.addAttribute("reviews",
                reviewRepository.findAllByOrderByRvIdxDesc());

        return "community/community";
    }


    /** 여행 후기 목록 (모두 열람 가능) */
    @GetMapping("/reviews")
    public String reviewList() {
        // 👉 /WEB-INF/views/community/reviewList.jsp
        return "community/reviewList";
    }
    
    // 후기 작성 페이지 이동
    @GetMapping("/write")
    public String writeForm(HttpSession session) {
        if (session.getAttribute("loginMember") == null) {
            return "redirect:/login";
        }
        return "community/write";
    }

    @PostMapping("/write")
    public String writeReview(
            @RequestParam int s_idx,
            @RequestParam int rv_star,
            @RequestParam String rv_cont,
            HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");

        Review review = new Review();
        review.setSIdx(s_idx);
        review.setMemberId(loginMember.getId());
        review.setRvStar(rv_star);
        review.setRvCont(rv_cont);

        reviewRepository.save(review);

        return "redirect:/community";
    }
    
    @GetMapping("/my-reviews")
    public String myReviews(HttpSession session, Model model) {

        Member loginMember = (Member) session.getAttribute("loginMember");

        if (loginMember == null) {
            return "redirect:/login";
        }

        model.addAttribute("myReviews",
                reviewRepository.findByMemberIdOrderByRvIdxDesc(loginMember.getId()));

        return "community/myReview";
    }


    @PostMapping("/delete")
    public String deleteReview(@RequestParam int rvIdx, HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/login";

        reviewRepository.deleteById(rvIdx);

        return "redirect:/community/my-reviews";
    }

    @GetMapping("/edit")
    public String editForm(@RequestParam int rvIdx, Model model, HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/login";

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) return "redirect:/community/my-reviews";

        model.addAttribute("review", review);
        return "community/editReview";
    }


    @PostMapping("/edit")
    public String editReview(
            @RequestParam int rvIdx,
            @RequestParam int rvStar,
            @RequestParam String rvCont,
            HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/login";

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) return "redirect:/community/my-reviews";

        review.setRvStar(rvStar);
        review.setRvCont(rvCont);

        reviewRepository.save(review);

        return "redirect:/community/my-reviews";
    }



}
