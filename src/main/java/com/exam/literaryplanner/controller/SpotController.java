package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.City;
import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.service.SpotService;

import jakarta.servlet.http.HttpSession;

import com.exam.literaryplanner.repository.CityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/spots")
@RequiredArgsConstructor
public class SpotController {

    private final SpotService spotService;
    private final CityRepository cityRepository;

    @GetMapping("/spot")
    public String getCityDetail(
            @RequestParam(value = "cityId", required = false) Integer cityId, 
            HttpSession session, 
            Model model) {

        // 1. 파라미터로 cityId가 들어오면 세션에 저장, 안 들어오면 세션에서 꺼내 쓰기
        if (cityId != null) {
            session.setAttribute("selectedCityId", cityId);
        } else {
            cityId = (Integer) session.getAttribute("selectedCityId");
            // 만약 세션에도 없다면 그때만 진짜 기본값(예: 4)을 줍니다.
            if (cityId == null) cityId = 4; 
        }

        // 2. 이후 로직은 동일
        City city = cityRepository.findById(cityId).orElseThrow();
        model.addAttribute("city", city);
        model.addAttribute("selectedCity", cityId); // JSP의 ${selectedCity}에 들어갈 값

        model.addAttribute("tourList", spotService.list(null, "TOUR", cityId, 0, 10).getContent());
        model.addAttribute("stayList", spotService.list(null, "STAY", cityId, 0, 10).getContent());
        model.addAttribute("actList", spotService.list(null, "ACT", cityId, 0, 10).getContent());
        model.addAttribute("foodList", spotService.list(null, "FOOD", cityId, 0, 10).getContent());

        return "spot/spot"; 
    }
    
	/*
	 * // 2. 나중에 API 작업을 할 테스트 페이지 주소 미리 생성
	 * 
	 * @GetMapping("/spot2") public String getCityDetailTest(
	 * 
	 * @RequestParam(value = "cityId", required = false) Integer cityId, HttpSession
	 * session, Model model) {
	 * 
	 * // 위와 동일한 도시 정보 세팅 로직 if (cityId != null)
	 * session.setAttribute("selectedCityId", cityId); else cityId = (Integer)
	 * session.getAttribute("selectedCityId"); if (cityId == null) cityId = 1;
	 * 
	 * City city = cityRepository.findById(cityId).orElseThrow();
	 * model.addAttribute("city", city);
	 * 
	 * // [수정] 리턴 경로를 spot/spot2로 변경 return "spot/spot2"; }
	 */
    
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
    
    @GetMapping("/detail/{id}")
    public String getSpotDetail(@PathVariable("id") Integer id, Model model) {
        // 1. ID로 해당 관광지의 모든 정보(이름, 주소, 설명, 이미지 등)를 가져옵니다.
        Spot spot = spotService.findById(id); 
        model.addAttribute("spot", spot);
        
        // 2. 상세 페이지(detail.jsp)로 이동합니다.
        return "spot/detail"; 
    }
    
    @GetMapping("/all")
    public String getAllSpots(
            @RequestParam("cityId") Integer cityId, // 여기서 부산(2번)을 받음
            @RequestParam("catCode") String catCode,
            Model model) {
        
        City city = cityRepository.findById(cityId).orElseThrow();
        List<Spot> spotList = spotService.list(null, catCode, cityId, 0, 100).getContent();

        model.addAttribute("city", city);
        model.addAttribute("catCode", catCode);
        model.addAttribute("spotList", spotList);
        
        // 중요: 현재 선택된 도시 ID를 다시 모델에 담아 JSP에 전달
        model.addAttribute("selectedCity", cityId); 

        return "spot/all";
    }
}