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
import com.exam.literaryplanner.service.ReviewPhotoService;
import com.exam.literaryplanner.repository.ReviewRepository;
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

    // ✅ 생성자 1개만! (스프링이 여기로 두 repo를 주입함)
    public CommunityController(ReviewRepository reviewRepository,
                               ReviewPhotoRepository reviewPhotoRepository,
                               ReviewPhotoService reviewPhotoService,
                               SpotService spotService) {
        this.reviewRepository = reviewRepository;
        this.reviewPhotoRepository = reviewPhotoRepository;
        this.reviewPhotoService = reviewPhotoService;
        this.spotService = spotService;
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

        // ✅ spots/detail/{id} 등에서 넘어오는 sIdx가 있으면 선택된 장소로 고정
        if (sIdx != null) {
            try {
                Spot spot = spotService.findById(sIdx);
                model.addAttribute("selectedSpot", spot);
            } catch (Exception ignored) {
                // 잘못된 sIdx가 들어와도 작성 화면 자체는 열리게 둠
            }
            model.addAttribute("selectedSpotId", sIdx);
        }

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
                              @RequestParam(value = "photos", required = false) MultipartFile[] photos,
                              HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
			return "redirect:/members/login";
		}

        Review review = new Review();
        review.setSIdx(sIdx);
        review.setMIdx(loginMember.getMIdx());
        review.setRvStar(rvStar);
        review.setRvCont(rvCont);
        review.setRvTitle(rvTitle);

        Review saved = reviewRepository.save(review);

        // ✅ 작성 시 사진도 같이 업로드(선택)
        try {
            if (photos != null && photos.length > 0 && photos[0] != null && !photos[0].isEmpty()) {
                reviewPhotoService.saveAll(saved.getRvIdx(), photos);
            }
        } catch (Exception ignored) {
            // 사진 업로드 실패해도 글 작성은 유지
        }

        // ✅ 작성 후 상세로 이동
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
        // 본인 글만 삭제 가능
        if ((review == null) || !review.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/members/mypage/reviews";
        }

        reviewRepository.deleteById(rvIdx);

        if ("mypage".equals(from)) {
            return "redirect:/members/mypage/reviews";
        }

        return "redirect:/community/view?rvIdx=" + rvIdx;
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

        model.addAttribute("review", review);

        // ✅ 수정 화면에서도 기존 사진을 함께 보여주기
        model.addAttribute("photos", reviewPhotoRepository.findByRvIdxOrderByRpIdxAsc(Integer.valueOf(rvIdx)));

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
        // 본인 글만 수정 가능
        if ((review == null) || !review.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/members/mypage/reviews";
        }

        review.setRvTitle(rvTitle);
        review.setRvCont(rvCont);
        review.setRvStar(rvStar);
        reviewRepository.save(review);

        if ("mypage".equals(from)) {
            return "redirect:/members/mypage/reviews";
        }

        return "redirect:/community/view?rvIdx=" + rvIdx;
    }

    /* =========================
     * 후기 상세
     * ========================= */
    @GetMapping("/view")
    public String view(@RequestParam Integer rvIdx, Model model) {
        Review review = reviewRepository.findById(rvIdx).orElseThrow();
        model.addAttribute("review", review);

        // ✅ 사진 목록(없으면 빈 리스트)
        model.addAttribute("photos", reviewPhotoRepository.findByRvIdxOrderByRpIdxAsc(Integer.valueOf(rvIdx)));

        return "community/view";
    }
}
