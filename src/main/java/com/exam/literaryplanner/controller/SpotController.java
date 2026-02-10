package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.City;
import com.exam.literaryplanner.service.SpotService;
import com.exam.literaryplanner.repository.CityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/spots")
@RequiredArgsConstructor
public class SpotController {

    private final SpotService spotService;
    private final CityRepository cityRepository;

    @GetMapping("/list")
    public String getCityDetail(@RequestParam(value = "cityId", defaultValue = "4") Integer cityId, Model model) {
        // 1. 도시 정보 (제목용)
        City city = cityRepository.findById(cityId).orElseThrow();
        model.addAttribute("city", city);
        model.addAttribute("selectedCity", cityId);

        // 2. JSP의 j:forEach items="${tourList}"와 이름이 똑같아야 합니다!
        model.addAttribute("tourList", spotService.list(null, "TOUR", cityId, 0, 10).getContent());
        model.addAttribute("stayList", spotService.list(null, "STAY", cityId, 0, 10).getContent());
        model.addAttribute("actList", spotService.list(null, "ACT", cityId, 0, 10).getContent());
        model.addAttribute("foodList", spotService.list(null, "FOOD", cityId, 0, 10).getContent());

        return "plan/plan"; 
    }

    // ✅ 2. 도시 버튼을 누를 때 데이터만 보내주는 메서드
    @GetMapping("/api/contents")
    @ResponseBody // 페이지 이동 없이 JSON 데이터만 반환
    public Map<String, Object> getCityContents(@RequestParam(value = "cityId") Integer cityId) {
        Map<String, Object> map = new HashMap<>();
        
        // 원하셨던 순서대로 데이터를 담습니다: 관광지 -> 숙소 -> 액티비티 -> 맛집
        map.put("tourList", spotService.list(null, "TOUR", cityId, 0, 10).getContent());
        map.put("stayList", spotService.list(null, "STAY", cityId, 0, 10).getContent());
        map.put("actList", spotService.list(null, "ACT", cityId, 0, 10).getContent());
        map.put("foodList", spotService.list(null, "FOOD", cityId, 0, 10).getContent());
        
        return map;
    }
}