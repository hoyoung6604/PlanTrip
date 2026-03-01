package com.exam.literaryplanner.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.Review;
import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.domain.TravelPlan;
import com.exam.literaryplanner.domain.Community;
import com.exam.literaryplanner.repository.LiteraryRepository;
import com.exam.literaryplanner.repository.PlanDetailRepository;
import com.exam.literaryplanner.repository.SpotRepository;
import com.exam.literaryplanner.repository.TravelPlanRepository;
import com.exam.literaryplanner.repository.CityRepository;
import com.exam.literaryplanner.repository.CommunityRepository;
import com.exam.literaryplanner.service.MemberDeleteService;
import com.exam.literaryplanner.service.PlanMapService;
import com.exam.literaryplanner.service.SpotService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/members/mypage")
public class MyPageController {

    private final PasswordEncoder passwordEncoder;
    private final LiteraryRepository literaryRepository;
    private final CommunityRepository reviewRepository;
    private final MemberDeleteService memberDeleteService;
    private final TravelPlanRepository travelPlanRepository;
    private final PlanDetailRepository planDetailRepository;
    private final PlanMapService planMapService;
    private final SpotRepository spotRepository;
    private final CityRepository cityRepository;
    private final SpotService spotService;

    public MyPageController(LiteraryRepository literaryRepository,
                            CommunityRepository reviewRepository,
                            PasswordEncoder passwordEncoder,
                            MemberDeleteService memberDeleteService,
                            TravelPlanRepository travelPlanRepository,
                            PlanDetailRepository planDetailRepository,
                            PlanMapService planMapService,
                            SpotRepository spotRepository,
                            CityRepository cityRepository,
                            SpotService spotService) {
        this.literaryRepository = literaryRepository;
        this.reviewRepository = reviewRepository;
        this.passwordEncoder = passwordEncoder;
        this.memberDeleteService = memberDeleteService;
        this.travelPlanRepository = travelPlanRepository;
        this.planDetailRepository = planDetailRepository;
        this.planMapService = planMapService;
        this.spotRepository = spotRepository;
        this.cityRepository = cityRepository;
        this.spotService = spotService;
    }

    /* ================= 마이페이지 메인 ================= */
    @GetMapping
    public String mypage(HttpSession session, Model model) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

     // 가장 최근에 찜한 장소 6
        List<Spot> recentWishList = spotService.getRecentWishSpots(loginMember.getMIdx());
        model.addAttribute("recentWishList", recentWishList);

        return "members/mypage/mypage";
    }
    
    /* ================= 내가 찜한 장소 (전체보기) ================= */
    @GetMapping("/wishlist")
    public String myWishList(HttpSession session, Model model) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        // 전체 찜 목록 가져오기 (이전에 SpotService에 만들어둔 getWishSpots 메서드 사용)
        List<Spot> allWishList = spotService.getWishSpots(loginMember.getMIdx());
        model.addAttribute("allWishList", allWishList);

        return "members/mypage/wishlist"; // 새롭게 띄워줄 jsp 파일 경로
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
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        List<TravelPlan> list = travelPlanRepository.findMyPlans(loginMember.getMIdx());

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        List<Map<String, Object>> plans = new ArrayList<>();
        for (int i = 0; i < list.size(); i++) {
            TravelPlan p = list.get(i);
            plans.add(Map.of(
                    "no", i + 1,
                    "pIdx", p.getPIdx(),
                    "title", p.getPTitle(),
                    "regDate", (p.getPRegDate() == null ? "" : p.getPRegDate().format(fmt))
            ));
        }

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

        model.addAttribute("myReviews", reviews);
        model.addAttribute("reviews", reviews);
        model.addAttribute("keyword", keyword);

        // ✅ 마이페이지 메뉴에서 커뮤니티 myReview.jsp 그대로 띄움
        return "community/myReview";
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
    
    @GetMapping("/plans/view")
    public String planView(@RequestParam Integer pIdx, HttpSession session, Model model) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        var plan = travelPlanRepository.findMyPlanView(pIdx, loginMember.getMIdx())
                .orElseThrow(() -> new IllegalArgumentException("없거나 권한 없음"));

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String regDateStr = plan.getpRegDate() == null ? "" : plan.getpRegDate().format(fmt);

        model.addAttribute("plan", plan);
        model.addAttribute("regDateStr", regDateStr);

        // ✅ 동선용(숙소 제외)
        model.addAttribute("pointsJson", planMapService.buildPointsJson(pIdx));
        model.addAttribute("spotNamesByDay", planMapService.getSpotNamesByDay(pIdx));

        // ✅ 숙소용(숙소만)
        model.addAttribute("staysJson", planMapService.buildStaysJson(pIdx));
        model.addAttribute("stayNamesByDay", planMapService.getStayNamesByDay(pIdx));

        return "members/mypage/planView";
    }
    @GetMapping("/plans/delete")
    public String planDelete(@RequestParam Integer pIdx, HttpSession session) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        travelPlanRepository.deleteMyPlan(pIdx, loginMember.getMIdx());
        return "redirect:/members/mypage/plans";
    }
    
    @GetMapping("/route")
    public String routePage(
        @RequestParam Integer pIdx,
        @RequestParam(required = false) Integer cityId,
        @RequestParam(required = false) List<String> purpose,
        Model model
    ) {
        model.addAttribute("pIdx", pIdx);

        // 항상 기존 저장 detail은 내려줌 (편집 초기값)
        model.addAttribute("savedDetails",
            planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx)
        );

        // city/purpose가 있어야 spots 목록을 뿌릴 수 있음
        List<Spot> spots = List.of();
        if (cityId != null && purpose != null && !purpose.isEmpty()) {
            spots = spotRepository.findByCity_IdAndCatCodeInOrderByNameAsc(cityId, purpose);
        }
        model.addAttribute("cityId", cityId);
        model.addAttribute("purpose", purpose);
        model.addAttribute("spots", spots);

        return "plans/route";
    }
    
    

}

