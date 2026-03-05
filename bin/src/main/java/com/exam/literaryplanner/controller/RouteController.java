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
import com.exam.literaryplanner.domain.TravelPlan;
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
    // 0. 계획 수정 (기본정보) : GET/POST /plans/edit
    // - mypage 상세보기에서 "수정" 눌렀을 때 404가 났던 이유:
    //   planEdit.jsp는 존재하지만, /plans/edit 매핑이 없어서였음.
    // ==========================
    @GetMapping("/edit")
    public String editPlanForm(@RequestParam Integer pIdx, HttpSession session, Model model) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        TravelPlan plan = travelPlanRepository.findById(pIdx)
                .orElseThrow(() -> new IllegalArgumentException("해당 계획이 존재하지 않습니다. pIdx=" + pIdx));

        // 내 계획만 수정 가능
        if (plan.getMIdx() == null || !plan.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/members/mypage/plans";
        }

        model.addAttribute("plan", plan);
        model.addAttribute("cities", cityRepository.findAllByOrderByNameAsc());
        return "plans/planEdit";
    }

    @PostMapping("/edit")
    public String editPlan(
            @RequestParam Integer pIdx,
            @RequestParam String planName,
            @RequestParam Integer cId,
            @RequestParam(name = "purposes") List<String> purposes,
            @RequestParam String startDate,
            @RequestParam String endDate,
            HttpSession session,
            RedirectAttributes ra,
            Model model
    ) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/members/login";
        }

        TravelPlan plan = travelPlanRepository.findById(pIdx)
                .orElseThrow(() -> new IllegalArgumentException("해당 계획이 존재하지 않습니다. pIdx=" + pIdx));
        if (plan.getMIdx() == null || !plan.getMIdx().equals(loginMember.getMIdx())) {
            return "redirect:/members/mypage/plans";
        }

        // 기본 검증
        LocalDate s = LocalDate.parse(startDate);
        LocalDate e = LocalDate.parse(endDate);
        if (e.isBefore(s)) {
            model.addAttribute("plan", plan);
            model.addAttribute("cities", cityRepository.findAllByOrderByNameAsc());
            model.addAttribute("error", "종료일은 시작일 이후여야 합니다.");
            return "plans/planEdit";
        }
        if (purposes == null || purposes.isEmpty()) {
            model.addAttribute("plan", plan);
            model.addAttribute("cities", cityRepository.findAllByOrderByNameAsc());
            model.addAttribute("error", "여행 목적은 1개 이상 선택해야 합니다.");
            return "plans/planEdit";
        }

        // 계획 기본 정보 업데이트
        String safeName = (planName == null) ? "" : planName.trim();
        if (safeName.isBlank()) {
            safeName = "여행계획";
        }
        String title = safeName;
        // 기존 createPlan이 title에 목적을 넣는 형태를 쓰고 있어서 동일하게 맞춤
        String safePurposes = String.join(",", purposes);
        if (!safePurposes.isBlank()) {
            title = String.format("%s [%s]", safeName, safePurposes);
        }

        plan.setPTitle(title);
        plan.setTpTitle(title);
        plan.setPStart(s);
        plan.setPEnd(e);
        travelPlanRepository.save(plan);

        ra.addFlashAttribute("saveMsg", "여행 계획이 수정되었습니다.");

        // 수정 후: 장소 선택/경로 수정 화면으로 이동
        return "redirect:/plans/route?pIdx=" + pIdx
                + "&cityId=" + cId
                + "&purpose=" + String.join("&purpose=", purposes);
    }

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

        // JSP에서 기존 선택 데이터를 복원하기 위해 그대로 넘김
        model.addAttribute("savedDetails", savedDetails);

        // ✅ mypage 상세보기에서 바로 /plans/route?pIdx=... 로 들어오는 경우
        //    (cityId/purpose가 비어있을 수 있음)
        //    1) 저장된 PlanDetail(선택된 장소) 기준으로 cityId/purpose를 유추
        //    2) 유추가 되면 URL 파라미터 형태로 다시 redirect해서
        //       route.jsp(체크박스/hidden input/JS)가 동일한 흐름으로 동작하게 맞춘다.

        List<Integer> sIdxList = new ArrayList<>();
        if (savedDetails != null && !savedDetails.isEmpty()) {
            sIdxList = savedDetails.stream()
                    .map(PlanDetail::getsIdx)
                    .filter(v -> v != null)
                    .distinct()
                    .collect(Collectors.toList());
        }

        // ⚠️ cityId 유추를 위해 City를 함께 로딩해야 한다.
        // findByIdIn()은 city가 LAZY라서 환경(OpenEntityManagerInView 설정 등)에 따라
        // controller에서 cityId를 못 꺼내는 케이스가 있어, fetch join 버전으로 고정한다.
        List<Spot> savedSpots = List.of();
        if (!sIdxList.isEmpty()) {
            savedSpots = spotRepository.findByIdIn(sIdxList);
        }
        model.addAttribute("savedSpots", savedSpots);

        boolean needInfer = (cityId == null || purpose == null || purpose.isEmpty());
        if (needInfer && savedSpots != null && !savedSpots.isEmpty()) {
            // cityId: 첫 번째 장소의 도시로
            if (cityId == null) {
                for (Spot sp : savedSpots) {
                    if (sp != null && sp.getCity() != null && sp.getCity().getId() != null) {
                        cityId = sp.getCity().getId();
                        break;
                    }
                }
            }

            // purpose: 저장된 장소들의 catCode를 유니크로
            if (purpose == null || purpose.isEmpty()) {
                LinkedHashSet<String> cats = new LinkedHashSet<>();
                for (Spot sp : savedSpots) {
                    if (sp != null && StringUtils.hasText(sp.getCatCode())) {
                        cats.add(sp.getCatCode());
                    }
                }
                if (!cats.isEmpty()) {
                    purpose = new ArrayList<>(cats);
                }
            }
        }

        // ✅ 유추가 되었으면, 파라미터 포함한 동일 URL로 redirect
        // (장소 목록/숙소/hidden inputs/JS 흐름을 생성 단계와 똑같이 맞추기 위해)
        if (needInfer && cityId != null && purpose != null && !purpose.isEmpty()) {
            StringBuilder sb = new StringBuilder("redirect:/plans/route?pIdx=")
                    .append(pIdx)
                    .append("&cityId=")
                    .append(cityId);
            for (String p : purpose) {
                if (StringUtils.hasText(p)) {
                    sb.append("&purpose=").append(p);
                }
            }
            return sb.toString();
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