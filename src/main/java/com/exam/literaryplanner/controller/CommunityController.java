package com.exam.literaryplanner.controller;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.Community;
import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.repository.ReviewPhotoRepository;
import com.exam.literaryplanner.repository.CommunityRepository;
import com.exam.literaryplanner.repository.SpotRepository;
import com.exam.literaryplanner.service.ReviewPhotoService;
import com.exam.literaryplanner.service.SpotService;

import jakarta.servlet.http.HttpSession;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/community")
public class CommunityController {

    private final CommunityRepository reviewRepository;
    private final ReviewPhotoRepository reviewPhotoRepository;
    private final ReviewPhotoService reviewPhotoService;
    private final SpotService spotService;
    private final SpotRepository spotRepository; // ✅ 추가

    public CommunityController(CommunityRepository reviewRepository,
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

        List<Community> reviews;

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

        // ✅ 장소 드롭다운(작성 폼에서 선택할 수 있게)
        model.addAttribute("spotList", spotRepository.findAll());

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
            @RequestParam(required = false) Integer sIdx,
            @RequestParam(required = false) Integer rvStar,   // ⭐ DB에는 없음(임시로 받기만)
            @RequestParam String rvCont,
            @RequestParam String rvTitle,
            @RequestParam(value = "photos", required = false) MultipartFile[] photos,
            HttpSession session,
            RedirectAttributes ra) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            ra.addFlashAttribute("msg", "로그인이 필요합니다.");
            return "redirect:/members/login";
        }

        if (sIdx == null) {
            ra.addFlashAttribute("msg", "장소를 선택해 주세요.");
            return "redirect:/community/write";
        }

        Spot spot = spotRepository.findById(sIdx).orElse(null);
        if (spot == null) {
            ra.addFlashAttribute("msg", "선택한 장소 정보를 찾을 수 없습니다.");
            return "redirect:/community/write";
        }

        Community review = new Community();
        review.setMIdx(loginMember.getMIdx());
        review.setSIdx(sIdx);

        // 조회용 연관(저장에는 영향 없음)
        review.setMember(loginMember);
        review.setSpot(spot);

        review.setRvTitle(rvTitle);
        // ✅ UI에서 maxlength로 막아도(브라우저/개발자도구/직접 요청 등) 서버로 더 긴 값이 들어올 수 있어서
        // DB 컬럼 길이 문제로 500이 터지지 않도록 서버에서 한 번 더 안전하게 제한
        if (rvCont != null) {
            final int MAX_CONT_LEN = 5000;
            if (rvCont.length() > MAX_CONT_LEN) {
                rvCont = rvCont.substring(0, MAX_CONT_LEN);
            }
        }
        review.setRvCont(rvCont);

        // 지역은 설계서상 communityT.c_region -> spot.addr에서 앞 토큰(예: 서울/부산)으로 저장
        review.setRvRegion(extractRegion(spot));

        review.setRvVCount(0);
        // ✅ DB 설계서 기준: c_regDate는 NOT NULL, c_update는 NULL 허용
        review.setRvRegDate(LocalDateTime.now());
        review.setRvUpdate(null);

        // ✅ 후기 먼저 저장해서 PK(c_idx=rvIdx) 생성
        // - c_cont 컬럼 타입이 VARCHAR/TINYTEXT 로 되어 있으면 긴 글에서 "Data too long" 으로 500이 터짐
        // - 여기서 잡아서 사용자에게 메시지로 안내하고 write 페이지로 되돌린다.
        Community savedReview;
        try {
            savedReview = reviewRepository.save(review);
        } catch (DataIntegrityViolationException e) {
            ra.addFlashAttribute("msg", "후기 내용이 너무 길어서 저장에 실패했습니다. (DB communityT.c_cont 컬럼을 TEXT로 설정하면 해결됩니다)");
            return "redirect:/community/write";
        }

        // ✅ 사진 업로드(다중) → reviewPhotoT (rv_idx = communityT.c_idx)
        try {
            Integer rvIdx = (savedReview != null ? savedReview.getRvIdx() : null);
            if (rvIdx != null && photos != null && photos.length > 0) {
                reviewPhotoService.saveMany(rvIdx, photos);

                // ✅ (호환) c_img에도 저장 파일명을 함께 기록
                // - 일부 환경에서 reviewPhotoT 저장이 누락되거나(테이블/권한/예외 등)
                //   상세보기에서 사진이 비어 보이는 케이스를 대비
                try {
                    var savedPhotos = reviewPhotoRepository.findByRvIdxOrderByRpIdxAsc(rvIdx);
                    if (savedPhotos != null && !savedPhotos.isEmpty()) {
                        String joined = savedPhotos.stream()
                                .map(p -> p.getRpStoredName())
                                .filter(n -> n != null && !n.isBlank())
                                .distinct()
                                .reduce((a,b) -> a + "|" + b)
                                .orElse(null);
                        if (joined != null && !joined.isBlank()) {
                            savedReview.setRvImg(joined);
                            reviewRepository.save(savedReview);
                        }
                    }
                } catch (Exception ignored) {}
            }
        } catch (Exception e) {
            // 사진 저장 실패해도 글 등록은 유지
            e.printStackTrace();
        }
        ra.addFlashAttribute("msg", "후기가 등록되었습니다.");
        return "redirect:/community";
    }

    /* =========================
     * 내 여행 후기
     * ========================= */
    @GetMapping("/my-reviews")
    public String myReviews(HttpSession session, Model model) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        List<Community> myReviews = reviewRepository.findByMIdxOrderByRvIdxDesc(loginMember.getMIdx());
        model.addAttribute("myReviews", myReviews);
        return "community/myReview";
    }

    /* =========================
     * 후기 삭제
     * ========================= */
    @PostMapping("/delete")
    public String delete(@RequestParam Integer rvIdx,
                         HttpSession session,
                         RedirectAttributes ra) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        Community review = reviewRepository.findById(rvIdx).orElse(null);
        if (review == null) {
            return "redirect:/community/my-reviews";
        }

        if (!review.getMIdx().equals(loginMember.getMIdx())) {
            ra.addFlashAttribute("msg", "삭제 권한이 없습니다.");
            return "redirect:/community/my-reviews";
        }

        // ✅ 사진 메타 먼저 삭제(테이블이 있을 때 FK/정합성 문제 방지)
        try {
            reviewPhotoRepository.deleteByRvIdx(rvIdx);
        } catch (Exception ignored) {}

        reviewRepository.deleteById(rvIdx);
        ra.addFlashAttribute("msg", "후기가 삭제되었습니다.");
        return "redirect:/community/my-reviews";
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

        Community review = reviewRepository.findById(rvIdx).orElse(null);
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

        Community review = reviewRepository.findById(rvIdx).orElse(null);
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

		Community review = reviewRepository.findDetail(rvIdx).orElse(null);
		if (review == null) {
            return "redirect:/community";
        }
		// ✅ 조회수 실시간 카운팅 (UPDATE 쿼리로 안전하게 +1)
		try {
			int current = (review.getRvVCount() == null) ? 0 : review.getRvVCount();
			reviewRepository.incrementViewCount(rvIdx);
			review.setRvVCount(current + 1); // 화면에 즉시 반영
		} catch (Exception ignored) {
			// 조회수 저장 실패해도 상세 페이지는 보여줘야 해서 무시
		}

        model.addAttribute("review", review);
        model.addAttribute("photos", reviewPhotoRepository.findByRvIdxOrderByRpIdxAsc(rvIdx));

        return "community/view";
    }
    // 지역은 설계서상 communityT.c_region 역할
    // spot.addr에서 앞 단어(예: "서울", "부산", "제주")만 뽑아서 저장
    private String extractRegion(Spot spot) {
        if (spot == null) return null;

        String addr = null;
        try {
            addr = spot.getAddr(); // Spot에 getAddr()가 있는 경우
        } catch (Exception ignored) {}

        if (addr != null) {
            addr = addr.trim();
            if (!addr.isBlank()) {
                String[] tokens = addr.split("\\s+");
                if (tokens.length > 0 && !tokens[0].isBlank()) {
                    return tokens[0].trim();
                }
            }
        }

        // addr이 없으면 city 이름으로 대체(안전장치)
        try {
            if (spot.getCity() != null && spot.getCity().getName() != null) {
                String cityName = spot.getCity().getName().trim();
                if (!cityName.isBlank()) return cityName;
            }
        } catch (Exception ignored) {}

        return null;
    }
}
