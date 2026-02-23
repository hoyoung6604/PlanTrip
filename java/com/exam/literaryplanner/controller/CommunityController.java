package com.exam.literaryplanner.controller;

import jakarta.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import org.springframework.web.multipart.MultipartFile;

import com.exam.literaryplanner.domain.Review;
import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.repository.ReviewRepository;
import com.exam.literaryplanner.service.ReviewPhotoService;



@Controller
@RequestMapping("/community")
public class CommunityController {

    private final ReviewRepository reviewRepository;
    private final ReviewPhotoService reviewPhotoService;

    CommunityController(ReviewRepository reviewRepository, ReviewPhotoService reviewPhotoService) {
        this.reviewRepository = reviewRepository;
        this.reviewPhotoService = reviewPhotoService;
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
            @RequestParam(value = "photos", required = false) MultipartFile[] photos,
            HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/login";
        }

        Review review = new Review();
        review.setSIdx(s_idx);
        // 기존 로직 유지 (Review 엔티티에 맞춰서 memberId / mIdx 중 존재하는 setter만 사용)
        try {
            // memberId(String) 필드가 있는 경우
            Review.class.getMethod("setMemberId", String.class).invoke(review, loginMember.getId());
        } catch (Exception ignore) {
            try {
                // mIdx(Integer) 필드가 있는 경우
                Review.class.getMethod("setMIdx", Integer.class).invoke(review, loginMember.getMIdx());
            } catch (Exception ignore2) {}
        }

        try {
            Review.class.getMethod("setRvStar", Integer.class).invoke(review, rv_star);
        } catch (Exception ignore) {}
        try {
            Review.class.getMethod("setRvCont", String.class).invoke(review, rv_cont);
        } catch (Exception ignore) {}

        Review saved = reviewRepository.save(review);

        // ✅ 사진 업로드 (리뷰 저장 후 rvIdx 확보)
        try {
            Integer rvIdx = null;
            try {
                rvIdx = (Integer) Review.class.getMethod("getRvIdx").invoke(saved);
            } catch (Exception ignore) {}

            if (rvIdx != null) {
                reviewPhotoService.saveMany(rvIdx, photos);
            }
        } catch (Exception e) {
            // 사진 저장 실패해도 글 등록은 유지
            e.printStackTrace();
        }

        return "redirect:/community";
    }

        Review review = new Review();
        review.setSIdx(s_idx);
        // 기존 로직 유지 (Review 엔티티에 맞춰서 memberId / mIdx 중 존재하는 setter만 사용)
        try {
            // memberId(String) 필드가 있는 경우
            Review.class.getMethod("setMemberId", String.class).invoke(review, loginMember.getId());
        } catch (Exception ignore) {
            try {
                // mIdx(Integer) 필드가 있는 경우
                Review.class.getMethod("setMIdx", Integer.class).invoke(review, loginMember.getMIdx());
            } catch (Exception ignore2) {}
        }

        try {
            Review.class.getMethod("setRvStar", Integer.class).invoke(review, rv_star);
        } catch (Exception ignore) {}
        try {
            Review.class.getMethod("setRvCont", String.class).invoke(review, rv_cont);
        } catch (Exception ignore) {}

        Review saved = reviewRepository.save(review);

        // ✅ 사진 업로드 (리뷰 저장 후 rvIdx 확보)
        try {
            Integer rvIdx = null;
            try {
                rvIdx = (Integer) Review.class.getMethod("getRvIdx").invoke(saved);
            } catch (Exception ignore) {}

            if (rvIdx != null) {
                reviewPhotoService.saveMany(rvIdx, photos);
            }
        } catch (Exception e) {
            // 사진 저장 실패해도 글 등록은 유지
            e.printStackTrace();
        }

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





    /** 후기 상세 보기 */
    @GetMapping("/view")
    public String view(@RequestParam Integer rvIdx, Model model) {
        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) {
            return "redirect:/community";
        }
        model.addAttribute("review", review);
        model.addAttribute("photos", reviewPhotoService.list(rvIdx));
        return "community/view";
    }
}
