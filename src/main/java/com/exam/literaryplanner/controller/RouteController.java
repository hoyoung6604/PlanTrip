package com.exam.literaryplanner.controller;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.PlanDetail;
import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.dto.RouteSpotDto;
import com.exam.literaryplanner.dto.SpotDistanceDto;
import com.exam.literaryplanner.repository.CityRepository;
import com.exam.literaryplanner.repository.PlanDetailRepository;
import com.exam.literaryplanner.repository.SpotRepository;
import com.exam.literaryplanner.repository.TravelPlanRepository;
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
    private final CityRepository cityRepository;
    private final SpotRepository spotRepository;
    private final PlanDetailRepository planDetailRepository;
    private final KakaoDirectionsService kakaoDirectionsService;
    private final TravelPlanRepository travelPlanRepository;
    private final PlanService planService;

    // ==========================
    // 1. 계획 생성 화면
    // ==========================
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
        if (loginMember == null) {
			return "redirect:/members/login";
		}

        Integer planId = planService.createPlan(
                planName,
                loginMember.getMIdx(),
                purposes,
                LocalDate.parse(startDate),
                LocalDate.parse(endDate)
        );

        return "redirect:/plans/route?pIdx=" + planId
                + "&cityId=" + cId
                + "&purpose=" + String.join("&purpose=", purposes);
    }

    // ==========================
    // 2. 루트 페이지
    // ==========================
    @GetMapping("/route")
    public String routePage(
            @RequestParam Integer pIdx,
            @RequestParam(required = false) Integer cityId,
            @RequestParam(required = false) List<String> purpose,
            Model model
    ) {
        model.addAttribute("pIdx", pIdx);

        List<PlanDetail> savedDetails =
                planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx);

        model.addAttribute("savedDetails", savedDetails);

        List<Spot> spots = List.of();
        if (cityId != null && purpose != null && !purpose.isEmpty()) {
            spots = spotRepository
                    .findByCity_IdAndCatCodeInOrderByNameAsc(cityId, purpose);
        }

        model.addAttribute("cityId", cityId);
        model.addAttribute("purpose", purpose);
        model.addAttribute("spots", spots);

        return "plans/route";
    }

    // ==========================
    // 3. 루트 저장
    // ==========================
    @PostMapping("/route/save")
    public String saveRoute(
            @RequestParam Integer pIdx,
            @RequestParam Integer cityId,
            @RequestParam List<String> purpose,
            @RequestParam(name="sIdx") List<Integer> sIdx,
            @RequestParam(name="pDay") List<Integer> pDay,
            @RequestParam(name="pMemo", required=false) List<String> pMemo,
            RedirectAttributes redirectAttributes
    ) {
        planDetailRepository.deleteByPIdx(pIdx);

        for (int i = 0; i < sIdx.size(); i++) {
            PlanDetail d = new PlanDetail();
            d.setpIdx(pIdx);
            d.setsIdx(sIdx.get(i));
            d.setpDay(pDay.get(i));
            d.setpSeq(i + 1);

            if (pMemo != null && pMemo.size() > i) {
                d.setpMemo(pMemo.get(i));
            }

            planDetailRepository.save(d);
        }

        redirectAttributes.addFlashAttribute("saveMsg", "계획이 저장되었습니다.");
        return "redirect:/";
    }

    // ==========================
    // 4. 카카오 길찾기 API
    // ==========================
    @ResponseBody
    @GetMapping("/api/directions")
    public Map<String, Object> directions(@RequestParam String spotIds) {

        List<Integer> ids = parseSpotIds(spotIds);
        List<RouteSpotDto> dto = routeService.getRouteSpotsInOrder(ids);

        var result = kakaoDirectionsService.getDirections(dto);

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("distanceM", result.distanceM());
        out.put("durationSec", result.durationSec());
        out.put("path", result.path());

        return out;
    }

    // ==========================
    // 5. 숙소 페이지 이동
    // ==========================
    @GetMapping("/stay")
    public String stayPage(@RequestParam Integer pIdx, Model model) {

        List<PlanDetail> details =
                planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx);

        Map<Integer, List<PlanDetail>> byDay =
                details.stream().collect(Collectors.groupingBy(PlanDetail::getpDay));

        Map<Integer, Map<String, Double>> dayCenters = new LinkedHashMap<>();

        for (Integer day : byDay.keySet()) {

            List<Integer> sIds = byDay.get(day).stream()
                    .map(PlanDetail::getsIdx)
                    .toList();

            List<Spot> spots = spotRepository.findAllById(sIds);

            double avgLat = spots.stream().mapToDouble(Spot::getLat).average().orElse(0);
            double avgLng = spots.stream().mapToDouble(Spot::getLng).average().orElse(0);

            Map<String, Double> center = new HashMap<>();
            center.put("lat", avgLat);
            center.put("lng", avgLng);

            dayCenters.put(day, center);
        }

        model.addAttribute("pIdx", pIdx);
        model.addAttribute("dayCenters", dayCenters);

        return "plans/stay";
    }

    // ==========================
    // 6. 주변 숙소 API
    // ==========================
    @ResponseBody
    @GetMapping("/api/stays")
    public List<SpotDistanceDto> nearbyStays(
            @RequestParam double lat,
            @RequestParam double lng
    ) {
        return spotRepository.findNearestStay(lat, lng);
    }

    @ResponseBody
    @GetMapping("/api/stays/byRoute")
    public List<SpotDistanceDto> staysByRoute(@RequestParam Integer pIdx) {

        List<PlanDetail> details =
                planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx);

        if (details.isEmpty()) {
			return List.of();
		}

        List<Spot> spots = spotRepository.findAllById(
                details.stream()
                        .map(PlanDetail::getsIdx)
                        .toList()
        );

        double avgLat = spots.stream().mapToDouble(Spot::getLat).average().orElse(0);
        double avgLng = spots.stream().mapToDouble(Spot::getLng).average().orElse(0);

        return spotRepository.findNearestStay(avgLat, avgLng);
    }



    // ==========================
    // 공통 유틸
    // ==========================
    private List<Integer> parseSpotIds(String spotIds) {

        if (!StringUtils.hasText(spotIds)) {
			return List.of();
		}

        String[] parts = spotIds.split(",");
        LinkedHashSet<Integer> set = new LinkedHashSet<>();

        for (String p : parts) {
            try {
                set.add(Integer.parseInt(p.trim()));
            } catch (Exception ignore) {}
        }

        return new ArrayList<>(set);
    }
}