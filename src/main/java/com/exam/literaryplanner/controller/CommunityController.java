package com.exam.literaryplanner.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.Review;
import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.repository.ReviewPhotoRepository;
import com.exam.literaryplanner.repository.ReviewRepository;
import com.exam.literaryplanner.repository.SpotRepository;
import com.exam.literaryplanner.service.ReviewPhotoService;
import com.exam.literaryplanner.service.SpotService;

import jakarta.servlet.http.HttpSession;
import org.springframework.web.multipart.MultipartFile;

@Controller
@RequestMapping("/community")
public class CommunityController {

    private final ReviewRepository reviewRepository;
    private final ReviewPhotoRepository reviewPhotoRepository;
    private final ReviewPhotoService reviewPhotoService;
    private final SpotService spotService;
    private final SpotRepository spotRepository; // ✅ 추가

    public CommunityController(ReviewRepository reviewRepository,
                               ReviewPhotoRepository reviewPhotoRepository,
                               ReviewPhotoService reviewPhotoService,
                               SpotService spotService,
                               SpotRepository spotRepository) { // ✅ 생성자에 추가
        this.reviewRepository = reviewRepository;
        this.reviewPhotoRepository = reviewPhotoRepository;
        this.reviewPhotoService = reviewPhotoService;
        this.spotService = spotService;
        this.spotRepository = spotRepository; // ✅ 추가
    }

    /* =========================
     * 커뮤니티 메인 (전체 후기 목록)
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
    public String writeForm(@RequestParam(required = false) Integer sIdx,
                            HttpSession session,
                            Model model) {
        if (session.getAttribute("loginMember") == null) {
            return "redirect:/members/login";
        }

        if (sIdx != null) {
            try {
                Spot spot = spotService.findById(sIdx);
                model.addAttribute("selectedSpot", spot);
            } catch (Exception ignored) {}
            model.addAttribute("selectedSpotId", sIdx);
        }

        return "community/write";
    }

    /* =========================
     * 후기 작성 처리
     * ========================= */
    @PostMapping("/write")
    public String writeReview(
            @RequestParam(required = false) Integer sIdx,   // 상세에서 넘어온 실제 spot
            @RequestParam(required = false) Integer cIdx,   // 일반 작성 시 선택한 도시
            @RequestParam int rvStar,
            @RequestParam String rvCont,
            @RequestParam String rvTitle,
            @RequestParam(value = "photos", required = false) MultipartFile[] photos,
            HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        Integer finalSIdx = sIdx;

        // 🔥 핵심: sIdx가 없으면 (일반 작성 = 도시 선택)
        if (finalSIdx == null && cIdx != null) {
            // 해당 도시(c_idx)에 속한 spot 하나 가져오기
            Spot spot = spotService.findFirstByCityId(cIdx); // ← 이 메서드만 추가하면 끝
            if (spot == null) {
                return "redirect:/community/write";
            }
            finalSIdx = spot.getId(); // ★ 이게 핵심
        }

        Review review = new Review();
        review.setSIdx(finalSIdx);  // 이제 진짜 spot id가 들어감
        review.setMIdx(loginMember.getMIdx());
        review.setRvStar(rvStar);
        review.setRvCont(rvCont);
        review.setRvTitle(rvTitle);

        Review saved = reviewRepository.save(review);

        try {
            if (photos != null && photos.length > 0 && photos[0] != null && !photos[0].isEmpty()) {
                reviewPhotoService.saveAll(saved.getRvIdx(), photos);
            }
        } catch (Exception ignored) {}

        return "redirect:/community/view?rvIdx=" + saved.getRvIdx();
    }

    /* =========================
     * 내 후기
     * ========================= */
    @GetMapping("/my-reviews")
    public String myReviews(HttpSession session, Model model) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

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
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null || !review.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/community/my-reviews";
        }

        reviewRepository.deleteById(rvIdx);

        if ("mypage".equals(from)) {
            return "redirect:/community/my-reviews";
        }
        return "redirect:/community";
    }

    /* =========================
     * 후기 수정 폼
     * ========================= */
    @GetMapping("/edit")
    public String editForm(@RequestParam Integer rvIdx, Model model, HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) {
            return "redirect:/community/my-reviews";
        }

        if (!review.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/community/my-reviews";
        }

        model.addAttribute("review", review);
        model.addAttribute("photos", reviewPhotoRepository.findByRvIdxOrderByRpIdxAsc(rvIdx));

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
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        Review review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null || !review.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/community/my-reviews";
        }

        review.setRvTitle(rvTitle);
        review.setRvCont(rvCont);
        review.setRvStar(rvStar);
        reviewRepository.save(review);

        if ("mypage".equals(from)) {
            return "redirect:/community/my-reviews";
        }

        return "redirect:/community/view?rvIdx=" + rvIdx;
    }

    /* =========================
     * 후기 상세
     * ========================= */
    @GetMapping("/view")
    public String view(@RequestParam Integer rvIdx, Model model) {

    	Review review = reviewRepository.findDetail(rvIdx).orElse(null);
        if (review == null) {
            return "redirect:/community";
        }

        model.addAttribute("review", review);
        model.addAttribute("photos", reviewPhotoRepository.findByRvIdxOrderByRpIdxAsc(rvIdx));

        return "community/view";
    }
}
