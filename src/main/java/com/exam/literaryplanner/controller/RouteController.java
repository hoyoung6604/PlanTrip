package com.exam.literaryplanner.controller;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.PlanDetail;
import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.domain.TravelPlan;
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
            @RequestParam(name = "purposes") List<String> purposes,
            @RequestParam String startDate,
            @RequestParam String endDate,
            HttpSession session
    ) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

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
    // (추가) 계획 기본정보 수정 화면
    // ==========================
    @GetMapping("/edit")
    public String editPlanPage(@RequestParam Integer pIdx, HttpSession session, Model model) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        TravelPlan plan = travelPlanRepository.findMyPlan(pIdx, loginMember.getMIdx())
                .orElseThrow(() -> new IllegalArgumentException("해당 계획이 존재하지 않습니다. pIdx=" + pIdx));

        List<PlanDetail> savedDetails = planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx);
        List<Integer> savedSpotIds = savedDetails.stream()
                .map(PlanDetail::getsIdx)
                .filter(Objects::nonNull)
                .distinct()
                .toList();
        List<Spot> savedSpots = savedSpotIds.isEmpty() ? List.of() : spotRepository.findAllById(savedSpotIds);

        Integer selectedCityId = null;
        if (!savedSpots.isEmpty() && savedSpots.get(0).getCity() != null) {
            selectedCityId = savedSpots.get(0).getCity().getId();
        }

        Set<String> selectedPurposesSet = savedSpots.stream()
                .map(Spot::getCatCode)
                .filter(Objects::nonNull)
                .filter(cat -> !cat.equalsIgnoreCase("STAY"))
                .collect(Collectors.toCollection(LinkedHashSet::new));

        model.addAttribute("plan", plan);
        model.addAttribute("cities", cityRepository.findAllByOrderByNameAsc());
        model.addAttribute("selectedCityId", selectedCityId);
        model.addAttribute("selectedPurposes", new ArrayList<>(selectedPurposesSet));

        return "plans/planEdit";
    }

    @PostMapping("/edit")
    public String editPlanSubmit(
            @RequestParam Integer pIdx,
            @RequestParam String planName,
            @RequestParam Integer cId,
            @RequestParam(name = "purposes", required = false) List<String> purposes, // ✅ 방어
            @RequestParam String startDate,
            @RequestParam String endDate,
            HttpSession session,
            RedirectAttributes redirectAttributes
    ) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        TravelPlan plan = travelPlanRepository.findMyPlan(pIdx, loginMember.getMIdx())
                .orElseThrow(() -> new IllegalArgumentException("해당 계획이 존재하지 않습니다. pIdx=" + pIdx));

        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        if (end.isBefore(start)) {
            redirectAttributes.addFlashAttribute("error", "종료일은 시작일보다 빠를 수 없어.");
            return "redirect:/plans/edit?pIdx=" + pIdx;
        }

        List<String> safePurposes = (purposes == null) ? new ArrayList<>() : purposes.stream()
                .filter(v -> v != null && !v.isBlank())
                .toList();

        plan.setPTitle(planName);
        plan.setPStart(start);
        plan.setPEnd(end);
        travelPlanRepository.save(plan);

        String redirect = "redirect:/plans/route?pIdx=" + pIdx + "&cityId=" + cId;
        if (!safePurposes.isEmpty()) {
            redirect += "&purpose=" + String.join("&purpose=", safePurposes);
        }
        return redirect;
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

        List<PlanDetail> savedDetails = planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx);
        model.addAttribute("savedDetails", savedDetails);

        List<Integer> savedSpotIds = savedDetails.stream()
                .map(PlanDetail::getsIdx)
                .filter(Objects::nonNull)
                .distinct()
                .toList();

        List<Spot> savedSpots = savedSpotIds.isEmpty() ? List.of() : spotRepository.findAllById(savedSpotIds);
        model.addAttribute("savedSpots", savedSpots);

        if (cityId == null && !savedSpots.isEmpty() && savedSpots.get(0).getCity() != null) {
            cityId = savedSpots.get(0).getCity().getId();
        }
        if ((purpose == null || purpose.isEmpty()) && !savedSpots.isEmpty()) {
            Set<String> inferred = savedSpots.stream()
                    .map(Spot::getCatCode)
                    .filter(Objects::nonNull)
                    .filter(cat -> !cat.equalsIgnoreCase("STAY"))
                    .collect(Collectors.toCollection(LinkedHashSet::new));
            if (!inferred.isEmpty()) purpose = new ArrayList<>(inferred);
        }

        List<Spot> spots = List.of();
        if (cityId != null && purpose != null && !purpose.isEmpty()) {
            spots = spotRepository.findByCity_IdAndCatCodeInOrderByNameAsc(cityId, purpose);
        }

        model.addAttribute("cityId", cityId);
        model.addAttribute("purpose", purpose);
        model.addAttribute("spots", spots);

        return "plans/route";
    }

    // ==========================
    // 3. 루트 저장 (핵심 수정)
    // ==========================
    @Transactional
    @PostMapping("/route/save")
    public String saveRoute(
            @RequestParam Integer pIdx,
            @RequestParam(required = false) Integer cityId,                 // ✅ 방어
            @RequestParam(name = "purpose", required = false) List<String> purpose, // ✅ 방어
            @RequestParam(name = "sIdx") List<Integer> sIdx,
            @RequestParam(name = "pDay") List<Integer> pDay,
            @RequestParam(name = "pMemo", required = false) List<String> pMemo,
            HttpSession session,
            RedirectAttributes ra
    ) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            ra.addFlashAttribute("saveErr", "로그인이 필요합니다.");
            return "redirect:/members/login";
        }

        // ✅ 내 계획인지 확인 (권한 방어)
        travelPlanRepository.findMyPlan(pIdx, loginMember.getMIdx())
                .orElseThrow(() -> new IllegalArgumentException("권한이 없거나 존재하지 않는 계획입니다. pIdx=" + pIdx));

        // ✅ 최소 선택 검증
        if (sIdx == null || sIdx.isEmpty()) {
            ra.addFlashAttribute("saveErr", "저장할 장소가 없습니다.");
            return redirectBackToRoute(pIdx, cityId, purpose);
        }
        if (pDay == null || pDay.size() != sIdx.size()) {
            ra.addFlashAttribute("saveErr", "저장 데이터 형식이 올바르지 않습니다. (DAY 누락)");
            return redirectBackToRoute(pIdx, cityId, purpose);
        }

        // ✅ cityId가 비었으면 첫 장소로 추정
        if (cityId == null) {
            try {
                Spot first = spotRepository.findById(sIdx.get(0)).orElse(null);
                if (first != null && first.getCity() != null) cityId = first.getCity().getId();
            } catch (Exception ignore) {}
        }

        List<String> safePurpose = (purpose == null) ? List.of() : purpose.stream()
                .filter(v -> v != null && !v.isBlank())
                .toList();

        try {
            // ✅ 기존 route 전체 삭제 후 재저장 (트랜잭션이라 중간에 터지면 롤백됨)
            planDetailRepository.deleteByPIdx(pIdx);

            for (int i = 0; i < sIdx.size(); i++) {
                PlanDetail d = new PlanDetail();
                d.setpIdx(pIdx);
                d.setsIdx(sIdx.get(i));
                d.setpDay(pDay.get(i));
                d.setpSeq(i + 1);

                if (pMemo != null && pMemo.size() > i) d.setpMemo(pMemo.get(i));

                planDetailRepository.save(d);
            }

            // ✅ 저장 성공 → 마이페이지 상세보기로
            ra.addFlashAttribute("saveMsg", "저장 완료");
            return "redirect:/members/mypage/plans/view?pIdx=" + pIdx;

        } catch (Exception e) {
            // ✅ 저장 실패 → route로 복귀
            ra.addFlashAttribute("saveErr", "저장 실패 (서버 로그 확인 필요)");
            return redirectBackToRoute(pIdx, cityId, safePurpose);
        }
    }

    private String redirectBackToRoute(Integer pIdx, Integer cityId, List<String> purpose) {
        String redirect = "redirect:/plans/route?pIdx=" + pIdx;
        if (cityId != null) redirect += "&cityId=" + cityId;
        if (purpose != null && !purpose.isEmpty()) {
            redirect += "&purpose=" + String.join("&purpose=", purpose);
        }
        return redirect;
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

        List<PlanDetail> details = planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx);

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
    public List<SpotDistanceDto> nearbyStays(@RequestParam double lat, @RequestParam double lng) {
        return spotRepository.findNearestStay(lat, lng);
    }

    @ResponseBody
    @GetMapping("/api/stays/byRoute")
    public List<SpotDistanceDto> staysByRoute(@RequestParam Integer pIdx) {

        List<PlanDetail> details = planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx);
        if (details.isEmpty()) return List.of();

        List<Spot> spots = spotRepository.findAllById(
                details.stream().map(PlanDetail::getsIdx).toList()
        );

        double avgLat = spots.stream().mapToDouble(Spot::getLat).average().orElse(0);
        double avgLng = spots.stream().mapToDouble(Spot::getLng).average().orElse(0);

        return spotRepository.findNearestStay(avgLat, avgLng);
    }

    // ==========================
    // 공통 유틸
    // ==========================
    private List<Integer> parseSpotIds(String spotIds) {

        if (!StringUtils.hasText(spotIds)) return List.of();

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