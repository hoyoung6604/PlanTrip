package com.exam.literaryplanner.controller;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.exam.literaryplanner.domain.*;
import com.exam.literaryplanner.dto.RouteSpotDto;
import com.exam.literaryplanner.dto.SpotDistanceDto;
import com.exam.literaryplanner.repository.*;
import com.exam.literaryplanner.repository.SpotRepository;
import com.exam.literaryplanner.service.*;

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
    //  - 마이페이지 상세보기의 "수정" 버튼이 여기로 들어온다.
    //  - 저장된 장소/도시/목적을 최대한 추론해서 form 기본값으로 복원한다.
    // ==========================
    @GetMapping("/edit")
    public String editPlanPage(@RequestParam Integer pIdx, HttpSession session, Model model) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        TravelPlan plan = travelPlanRepository.findMyPlan(pIdx, loginMember.getMIdx())
                .orElseThrow(() -> new IllegalArgumentException("해당 계획이 존재하지 않습니다. pIdx=" + pIdx));

        // 저장된 장소 기반으로 도시/목적을 추론(없으면 null)
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
            @RequestParam(name="purposes") List<String> purposes,
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

        // ✅ 기본정보 업데이트
        plan.setPTitle(planName);
        plan.setTpTitle(planName);
        plan.setPStart(start);
        plan.setPEnd(end);
        travelPlanRepository.save(plan);

        // ✅ 다음 단계(장소 선택/경로 수정)로 이동
        //    route.jsp가 오른쪽 목록을 채우려면 cityId/purpose가 필요해서 같이 넘김
        return "redirect:/plans/route?pIdx=" + pIdx
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

        // ✅ 서버에 저장된 기존 선택 데이터(마이페이지 수정 진입 시 복원용)
        List<PlanDetail> savedDetails =
                planDetailRepository.findByPIdxOrderByPDayAscPSeqAsc(pIdx);
        model.addAttribute("savedDetails", savedDetails);

        // ✅ savedDetails에 해당하는 Spot 정보도 같이 내려줘야 route.jsp에서 복원 가능
        List<Integer> savedSpotIds = savedDetails.stream()
                .map(PlanDetail::getsIdx)
                .filter(Objects::nonNull)
                .distinct()
                .toList();

        List<Spot> savedSpots = savedSpotIds.isEmpty()
                ? List.of()
                : spotRepository.findAllById(savedSpotIds);

        model.addAttribute("savedSpots", savedSpots);

        // ✅ 쿼리스트링(cityId/purpose)이 없더라도, 기존 저장 데이터로 기본값을 추론해서
        //    "장소 리스트(오른쪽 목록)"이 비어 보이는 문제를 방지
        if (cityId == null && !savedSpots.isEmpty() && savedSpots.get(0).getCity() != null) {
            cityId = savedSpots.get(0).getCity().getId();
        }
        if ((purpose == null || purpose.isEmpty()) && !savedSpots.isEmpty()) {
            Set<String> inferred = savedSpots.stream()
                    .map(Spot::getCatCode)
                    .filter(Objects::nonNull)
                    .filter(cat -> !cat.equalsIgnoreCase("STAY"))
                    .collect(Collectors.toCollection(LinkedHashSet::new));
            if (!inferred.isEmpty()) {
                purpose = new ArrayList<>(inferred);
            }
        }

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

        if (details.isEmpty()) return List.of();

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