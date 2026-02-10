package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.Review;
import com.exam.literaryplanner.repository.ReviewRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/community")
public class CommunityController {

    private final ReviewRepository reviewRepository;

    public CommunityController(ReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    /* =========================
     * 커뮤니티 메인
     * ========================= */
    @GetMapping
    public String communityMain(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer minStar,
            @RequestParam(required = false) Integer sIdx,
            @RequestParam(required = false, defaultValue = "latest") String sort,
            Model model) {

        List<Review> reviews;

        if ("star".equals(sort)) {
            reviews = reviewRepository.searchOrderByStarDesc(keyword, minStar, sIdx);
        } else {
            reviews = reviewRepository.searchOrderByLatestDesc(keyword, minStar, sIdx);
        }

        model.addAttribute("reviews", reviews);
        model.addAttribute("keyword", keyword);
        model.addAttribute("minStar", minStar);
        model.addAttribute("sIdx", sIdx);
        model.addAttribute("sort", sort);

        return "community/community";
    }

    /* =========================
     * 후기 작성 폼
     * ========================= */
    @GetMapping("/write")
    public String writeForm(HttpSession session) {
        if (session.getAttribute("loginMember") == null) return "redirect:/members/login";
        return "community/write";
    }

    /* =========================
     * 후기 작성 처리
     * ========================= */
    @PostMapping("/write")
    public String writeReview(@RequestParam Integer sIdx,
                              @RequestParam int rvStar,
                              @RequestParam String rvCont,
                              @RequestParam String rvTitle,
                              HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        Review review = new Review();
        review.setSIdx(sIdx);
        review.setMIdx(loginMember.getMIdx());
        review.setRvStar(rvStar);
        review.setRvCont(rvCont);
        review.setRvTitle(rvTitle);

        reviewRepository.save(review);
        return "redirect:/community";
    }

    /* =========================
     * 내 후기
     * ========================= */
    @GetMapping("/my-reviews")
    public String myReviews(HttpSession session, Model model) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        List<Review> reviews = reviewRepository.findByMIdxOrderByRvIdxDesc(loginMember.getMIdx());
        model.addAttribute("myReviews", reviews);

        return "community/myReview";
    }

    /* =========================
     * 후기 삭제
     * ========================= */
    @PostMapping("/delete")
    public String deleteReview(@RequestParam Integer rvIdx,
                               @RequestParam(required = false) String from,
                               HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) {
            return "redirect:/members/mypage/reviews";
        }

        // 본인 글만 삭제 가능
        if (!review.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/members/mypage/reviews";
        }

        reviewRepository.deleteById(rvIdx);

        if ("mypage".equals(from)) {
            return "redirect:/members/mypage/reviews";
        }

        return "redirect:/community";
    }

    /* =========================
     * 후기 수정 폼
     * ========================= */
    @GetMapping("/edit")
    public String editForm(@RequestParam Integer rvIdx, Model model, HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) return "redirect:/community/my-reviews";

        model.addAttribute("review", review);
        return "community/editReview";
    }

    /* =========================
     * 후기 수정 처리
     * ========================= */
    @PostMapping("/edit")
    public String editReview(@RequestParam Integer rvIdx,
                             @RequestParam String rvTitle,
                             @RequestParam String rvCont,
                             @RequestParam int rvStar,
                             @RequestParam(required = false) String from,
                             HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) return "redirect:/members/mypage/reviews";

        // 본인 글만 수정 가능
        if (!review.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/members/mypage/reviews";
        }

        review.setRvTitle(rvTitle);
        review.setRvCont(rvCont);
        review.setRvStar(rvStar);
        reviewRepository.save(review);

        if ("mypage".equals(from)) {
            return "redirect:/members/mypage/reviews";
        }

        return "redirect:/community";
    }
    
    @GetMapping("/view")
    public String view(@RequestParam Integer rvIdx, Model model) {
        Review review = reviewRepository.findById(rvIdx).orElseThrow();
        model.addAttribute("review", review);
        return "community/view";
    }

}

