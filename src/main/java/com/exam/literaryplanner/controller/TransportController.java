package com.exam.literaryplanner.controller;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

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
    // ✅ 페이지 진입 시: 기본으로 "오늘 날짜" 제주↔전국 공항 운항편 자동 표시
    @GetMapping("/flight")
    public String flight(
            @RequestParam(required = false) String depPlandTime,
            @RequestParam(required = false) String airportId, // ✅ 버튼에서 넘어오는 값
            Model model
    ) {
        String date = (depPlandTime == null || depPlandTime.isBlank())
                ? LocalDate.now(ZoneId.of("Asia/Seoul")).format(DateTimeFormatter.BASIC_ISO_DATE)
                : depPlandTime;

        // ✅ 버튼 목록(이름+ID) 항상 넘김
        model.addAttribute("airports", transportService.getAirports());
        model.addAttribute("depPlandTime", date);

        // ✅ 기본 선택 공항 (첫 공항 or 김포 등)
        String selected = (airportId == null || airportId.isBlank())
                ? transportService.getDefaultAirportId()
                : airportId;

        model.addAttribute("selectedAirportId", selected);

        // ✅ 선택 공항 ↔ 제주만 조회
        model.addAttribute("result", transportService.searchJejuRouteByAirport(selected, date));

        return "transport/flight";
    }


    // (원하면 검색도 유지 가능)
    @GetMapping("/flight/search")
    public String searchFlight(@RequestParam String depAirportId,
                               @RequestParam String arrAirportId,
                               @RequestParam String depPlandTime,
                               Model model) {
        model.addAttribute("depPlandTime", depPlandTime);
        model.addAttribute("result", transportService.searchFlight(depAirportId, arrAirportId, depPlandTime));
        return "transport/flight";
    }
}


