package com.exam.literaryplanner.controller;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.exam.literaryplanner.service.TransportService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/transport")
@RequiredArgsConstructor
public class TransportController {

    private final TransportService transportService;
    
    private TransportController(TransportService transportService) {
        this.transportService = transportService;
    }


    // ✅ 페이지 진입 시: 기본으로 "오늘 날짜" 제주↔전국 공항 운항편 자동 표시
    @GetMapping("/flight")
    public String flight(
            @RequestParam(required = false) String depPlandTime,
            @RequestParam(required = false) String airportId,
            @RequestParam(defaultValue = "JEJU_OUT") String direction, // ✅ JEJU_OUT / JEJU_IN
            @RequestParam(defaultValue = "1") int page,
            Model model
    ) {
        String date = (depPlandTime == null || depPlandTime.isBlank())
                ? LocalDate.now(ZoneId.of("Asia/Seoul")).format(DateTimeFormatter.BASIC_ISO_DATE)
                : depPlandTime;

        model.addAttribute("airports", transportService.getAirports());
        model.addAttribute("depPlandTime", date);

        // ✅ 달력용 yyyy-MM-dd
        String depPlandTimeIso = LocalDate.parse(date, DateTimeFormatter.BASIC_ISO_DATE)
                .format(DateTimeFormatter.ISO_LOCAL_DATE);
        model.addAttribute("depPlandTimeIso", depPlandTimeIso);

        String selected = (airportId == null || airportId.isBlank())
                ? transportService.getDefaultAirportId()
                : airportId;

        model.addAttribute("selectedAirportId", selected);
        model.addAttribute("direction", direction);

        // ✅ 전체(선택공항↔제주) 조회
        List<Map<String, Object>> all = transportService.searchJejuRouteByAirport(selected, date);

        // ✅ 방향 필터: 출발공항 기준
        // JEJU_OUT = 제주 출발(=depAirportId가 JEJU_ID)
        // JEJU_IN  = 선택공항 출발(=depAirportId가 selected)
        String jejuId = "NAARKPC"; // 제주 공항 ID (서비스와 동일)
        List<Map<String, Object>> filtered = new ArrayList<>();

        for (Map<String, Object> m : all) {
            String depId = Objects.toString(m.get("depAirportId"), "").trim();
            String arrId = Objects.toString(m.get("arrAirportId"), "").trim();
            String depNm = Objects.toString(m.get("depAirportNm"), "").trim();
            String arrNm = Objects.toString(m.get("arrAirportNm"), "").trim();

            boolean depIsJeju = jejuId.equals(depId) || depNm.contains("제주");
            boolean arrIsJeju = jejuId.equals(arrId) || arrNm.contains("제주");

            // ✅ 제주가 출발이면 "제주 출발"
            if ("JEJU_OUT".equals(direction)) {
                if (depIsJeju) filtered.add(m);
            }
            // ✅ 제주가 도착이면 "선택공항 출발"(=제주 도착)
            else if ("JEJU_IN".equals(direction)) {
                if (arrIsJeju) filtered.add(m);
            }
        }

        // ✅ 페이지네이션(10개씩)
        int pageSize = 10;
        int total = filtered.size();
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages == 0) totalPages = 1;

        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, total);

        List<Map<String, Object>> paged = (fromIndex < total)
                ? filtered.subList(fromIndex, toIndex)
                : Collections.emptyList();

        model.addAttribute("result", paged);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);

        return "transport/flight";
    }



    // (원하면 검색도 유지 가능) - 검색도 페이지네이션 넣고 싶으면 여기도 동일하게 추가 가능
    @GetMapping("/flight/search")
    public String searchFlight(@RequestParam String depAirportId,
                               @RequestParam String arrAirportId,
                               @RequestParam String depPlandTime,
                               @RequestParam(defaultValue = "1") int page, // ✅ 추가
                               Model model) {

        List<?> all = transportService.searchFlight(depAirportId, arrAirportId, depPlandTime);
        if (all == null) all = Collections.emptyList();

        int pageSize = 10;
        int total = all.size();
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages == 0) totalPages = 1;

        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, total);

        List<?> paged = (fromIndex < total) ? all.subList(fromIndex, toIndex) : Collections.emptyList();

        model.addAttribute("depPlandTime", depPlandTime);
        model.addAttribute("result", paged);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);

        return "transport/flight";
    }
}



