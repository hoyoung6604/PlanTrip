package com.exam.literaryplanner.controller;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.PlanDetail;
import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.domain.TravelPlan;
import com.exam.literaryplanner.dto.RouteSpotDto;
import com.exam.literaryplanner.repository.CityRepository;
import com.exam.literaryplanner.repository.PlanDetailRepository;
import com.exam.literaryplanner.repository.SpotRepository;
import com.exam.literaryplanner.repository.TravelPlanRepository;
import com.exam.literaryplanner.service.CityService;
import com.exam.literaryplanner.service.KakaoDirectionsService;
import com.exam.literaryplanner.service.PlanService;
import com.exam.literaryplanner.service.RouteService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/plans")
public class RouteController {

    private final RouteService routeService;
    private final CityService cityService;
    private final PlanService planService;
    private final CityRepository cityRepository;
    private final SpotRepository spotRepository;
    private final PlanDetailRepository planDetailRepository;
    private final KakaoDirectionsService kakaoDirectionsService;
    private final TravelPlanRepository travelPlanRepository;

 // 1) 계획 만들기 화면 (도시 목록 뿌리기)
    @GetMapping("/planRoute")
    public String planRoutePage(Model model) {
      model.addAttribute("cities", cityRepository.findAllByOrderByNameAsc());
      return "plans/planRoute";
    }
    
    @PostMapping("/planRoute")
    public String createPlanRoute(
            @RequestParam String planName,
            @RequestParam Integer cId,
            @RequestParam(name="purposes") List<String> purposes,
            @RequestParam String startDate,
            @RequestParam String endDate,
            HttpSession session
    ) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        Integer mIdx = loginMember.getMIdx();

        Integer planId = planService.createPlan(
                planName,           // 지금은 city 파라미터로 쓰고 있지만 일단 제목 재료로 사용됨
                mIdx,               // ✅ 여기에 회원번호
                purposes,
                LocalDate.parse(startDate),
                LocalDate.parse(endDate)
        );

        return "redirect:/plans/route?pIdx=" + planId
             + "&cityId=" + cId
             + "&purpose=" + String.join("&purpose=", purposes);
    }

    // ✅ 2) Route 페이지 (지도 + 선)
    // GET /plans/route?spotIds=1,2,3
    // GET /plans/route?spotIds=1&spotIds=2&spotIds=3  (반복 파라미터도 허용)
    @GetMapping("/route")
    public String routePage(
        @RequestParam Integer pIdx,
        @RequestParam(required = false) Integer cityId,
        @RequestParam(required = false) List<String> purpose,
        Model model
    ) {
        // 저장된 디테일은 무조건 내려줌 (수정 초기값)
        model.addAttribute("pIdx", pIdx);
        model.addAttribute("savedDetails",
            planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx)
        );

        // cityId/purpose가 있을 때만 장소목록 로딩
        List<Spot> spots = List.of();
        if (cityId != null && purpose != null && !purpose.isEmpty()) {
            spots = spotRepository.findByCity_IdAndCatCodeInOrderByNameAsc(cityId, purpose);
        }

        model.addAttribute("cityId", cityId);
        model.addAttribute("purpose", purpose);
        model.addAttribute("spots", spots);

        return "plans/route";
    }
    
    @PostMapping("/route/save")
    public String saveRoute(
        @RequestParam Integer pIdx,
        @RequestParam Integer cityId,
        @RequestParam List<String> purpose,
        @RequestParam(name="sIdx") List<Integer> sIdx,
        @RequestParam(name="pDay") List<Integer> pDay,
        @RequestParam(name="pMemo", required=false) List<String> pMemo
    ) {
      // 기존 저장 삭제 후 다시 저장(간단/확실)
      planDetailRepository.deleteByPIdx(pIdx);

      for (int i = 0; i < sIdx.size(); i++) {
        PlanDetail d = new PlanDetail();
        d.setpIdx(pIdx);
        d.setsIdx(sIdx.get(i));
        d.setpDay(pDay.get(i));
        d.setpSeq(i + 1); // 선택된 순서대로
        if (pMemo != null && pMemo.size() > i) d.setpMemo(pMemo.get(i));
        planDetailRepository.save(d);
      }

      return "redirect:/plans/route?pIdx=" + pIdx + "&cityId=" + cityId + "&purpose=" + String.join("&purpose=", purpose);
    }

    @ResponseBody
    @GetMapping("/api/directions")
    public Map<String, Object> directions(@RequestParam String spotIds) {
      List<Integer> ids = parseSpotIds(spotIds);
      List<RouteSpotDto> dto = routeService.getRouteSpotsInOrder(ids);

      var result = kakaoDirectionsService.getDirections(dto);

      Map<String, Object> out = new LinkedHashMap<>();
      out.put("distanceM", result.distanceM());
      out.put("durationSec", result.durationSec());
      out.put("path", result.path()); // [{lat:.., lng:..}, ...]
      return out;
    }

    private List<Integer> parseSpotIds(String spotIds) {
      if (spotIds == null || spotIds.isBlank()) return List.of();
      String[] parts = spotIds.split(",");
      List<Integer> ids = new ArrayList<>();
      for (String p : parts) {
        try { ids.add(Integer.parseInt(p.trim())); } catch (Exception ignore) {}
      }
      LinkedHashSet<Integer> set = new LinkedHashSet<>(ids);
      return new ArrayList<>(set);
    }
  
    /**
     * spotIds 문자열("1,2,3")과 spotIdsList(1,2,3)를 합쳐서
     *  - 순서 유지
     *  - 중복 제거
     *  - 숫자만 통과
     */
    private List<Integer> mergeAndNormalizeSpotIds(String spotIds, List<Integer> spotIdsList) {
        List<Integer> collected = new ArrayList<>();

        // 1) 문자열 콤마 방식
        if (StringUtils.hasText(spotIds)) {
            String[] parts = spotIds.split(",");
            for (String p : parts) {
                try {
                    int v = Integer.parseInt(p.trim());
                    collected.add(v);
                } catch (NumberFormatException ignore) {}
            }
        }

        // 2) 반복 파라미터 방식
        if (spotIdsList != null && !spotIdsList.isEmpty()) {
            for (Integer v : spotIdsList) {
                if (v != null) collected.add(v);
            }
        }
        
        
        
        // 3) 순서 유지 + 중복 제거
        LinkedHashSet<Integer> set = new LinkedHashSet<>(collected);
        return new ArrayList<>(set);
    }
    
    @GetMapping("/edit")
    public String editPlanForm(@RequestParam Integer pIdx, HttpSession session, Model model) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        TravelPlan plan = travelPlanRepository.findMyPlan(pIdx, loginMember.getMIdx())
                .orElseThrow(() -> new IllegalArgumentException("없거나 권한 없음"));

        model.addAttribute("plan", plan);
        model.addAttribute("cities", cityRepository.findAllByOrderByNameAsc());

        // ⚠️ 지금 DB에 city/purpose 저장이 없으면 여기 두 줄은 일단 빼도 됨
        // model.addAttribute("selectedCityId", ...);
        // model.addAttribute("selectedPurposes", ...);

        return "plans/planEdit";
    }
    
    @PostMapping("/edit")
    public String editPlanSubmit(
            @RequestParam Integer pIdx,
            @RequestParam String planName,
            @RequestParam Integer cId,
            @RequestParam(name="purposes") List<String> purposes,
            @RequestParam String startDate,
            @RequestParam String endDate,
            HttpSession session
    ) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        TravelPlan plan = travelPlanRepository.findMyPlan(pIdx, loginMember.getMIdx())
                .orElseThrow(() -> new IllegalArgumentException("없거나 권한 없음"));

        plan.setPTitle(planName);
        plan.setPStart(LocalDate.parse(startDate));
        plan.setPEnd(LocalDate.parse(endDate));
        travelPlanRepository.save(plan);

        return "redirect:/plans/route?pIdx=" + pIdx
                + "&cityId=" + cId
                + "&purpose=" + String.join("&purpose=", purposes);
    }
    
    
}