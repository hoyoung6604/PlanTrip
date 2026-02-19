package com.exam.literaryplanner.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.exam.literaryplanner.domain.City;
import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.repository.CityRepository;
import com.exam.literaryplanner.service.SpotService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/spots")
@RequiredArgsConstructor
public class SpotController {

    private final SpotService spotService;
    private final CityRepository cityRepository;
    
    public SpotController(SpotService spotService, CityRepository cityRepository) {
    	this.spotService = spotService;
    	this.cityRepository = cityRepository;
    }

    /**
     * 메인(index.jsp)에서 /spots?cat=CITY|HOTEL|ACT|FOOD 형태로 접근합니다.
     * 기존 컨트롤러는 /spots/list만 있어서 /spots 요청이 404(정적 리소스 탐색)로 떨어졌습니다.
     *
     * - CITY  -> TOUR
     * - HOTEL -> STAY
     * - ACT   -> ACT
     * - FOOD  -> FOOD
     *
     * cat 값은 이후 UI에서 “선택된 카테고리” 표시 등에 쓸 수 있도록 세션에 저장해둡니다.
     */
    @GetMapping({"", "/"})
    public String spotsRoot(@RequestParam(value = "cat", required = false) String cat,
                            HttpSession session) {

        if (cat != null) {
            String mapped;
            switch (cat.toUpperCase()) {
                case "CITY": mapped = "TOUR"; break;
                case "HOTEL": mapped = "STAY"; break;
                case "ACT": mapped = "ACT"; break;
                case "FOOD": mapped = "FOOD"; break;
                default: mapped = cat; // 예외 케이스는 그대로 저장
            }
            session.setAttribute("selectedCat", mapped);
        }

        // 기존 화면 진입 루트는 /spots/list
        return "redirect:/spots/list";
    }
//    
//    @GetMapping("/list")
//    public String getCityDetail(@RequestParam(value = "cityId", defaultValue = "4") Integer cityId, Model model) {
//        //도시 정보 (제목용)
//    	City city = cityRepository.findById(cityId).orElse(null);
//        if (city == null) {
//            city = cityRepository.findFirstByOrderByIdAsc().orElse(null);
//            
//            //도시 데이터가 없거나 잘못된 cityId가 들어오는 경우 : 첫 도시로 풀백
//            if (city == null) {
//                model.addAttribute("errorMessage", "도시 데이터가 없습니다. cityT 테이블을 확인해주세요.");
//                return "plan/plan";
//            }
//            cityId = city.getId();
//        }
//    
//        model.addAttribute("city", city);
//        model.addAttribute("selectedCity", cityId);
//
//        // 2. JSP의 j:forEach items="${tourList}"와 이름이 똑같아야 합니다!
//       model.addAttribute("stayList", spotService.list(null, "STAY", cityId, 0, 10).getContent());
//       model.addAttribute("actList", spotService.list(null, "ACT", cityId, 0, 10).getContent());
//       model.addAttribute("foodList", spotService.list(null, "FOOD", cityId, 0, 10).getContent());
//
//       return "plan/plan";
//   }

    @GetMapping("/list")
    public String getCityDetail(
            @RequestParam(value = "cityId", required = false) Integer cityId,
            HttpSession session,
            Model model) {

	        // 1) cityId가 들어오면 세션에 저장, 없으면 세션에서 꺼내 사용
	        if (cityId != null) {
	            session.setAttribute("selectedCityId", cityId);
	        } else {
	            cityId = (Integer) session.getAttribute("selectedCityId");
	        }

	        // 2) 파라미터/세션 모두 없으면: DB 첫 도시로 기본값 세팅
	        //    (⚠️ cityId가 null인 상태로 findById를 호출하면 500이 터지므로 여기서 반드시 방어)
	        if (cityId == null) {
	            City firstCity = cityRepository.findFirstByOrderByIdAsc().orElse(null);
	            if (firstCity == null) {
	                model.addAttribute("errorMessage", "도시 데이터가 없습니다. cityT 테이블을 확인해주세요.");
	                return "plan/plan";
	            }
	            cityId = firstCity.getId();
	            session.setAttribute("selectedCityId", cityId);
	        }
    

	        // 3. 이후 로직은 동일
        City city = cityRepository.findById(cityId).orElse(null);
        if (city == null) {
            // 도시 데이터가 없거나 잘못된 cityId가 넘어온 경우: 첫 도시로 폴백
            city = cityRepository.findFirstByOrderByIdAsc().orElse(null);
            if (city == null) {
                model.addAttribute("errorMessage", "도시 데이터가 없습니다. cityT 테이블을 확인해주세요.");
                return "plan/plan";
            }
            cityId = city.getId();
        }
        model.addAttribute("city", city);
        model.addAttribute("selectedCity", cityId); // JSP의 ${selectedCity}에 들어갈 값

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

    @GetMapping("/detail/{id}")
    public String getSpotDetail(@PathVariable("id") Integer id, Model model) {
        // 1. ID로 해당 관광지의 모든 정보(이름, 주소, 설명, 이미지 등)를 가져옵니다.
        Spot spot = spotService.findById(id);
        model.addAttribute("spot", spot);

        // 2. 상세 페이지(detail.jsp)로 이동합니다.
        return "plan/detail";
    }

    @GetMapping("/all")
    public String getAllSpots(
            @RequestParam("cityId") Integer cityId, // 여기서 부산(2번)을 받음
            @RequestParam("catCode") String catCode,
            Model model) {

        City city = cityRepository.findById(cityId).orElse(null);
        if (city == null) {
            // 도시 데이터가 없거나 잘못된 cityId가 넘어온 경우: 첫 도시로 폴백
            city = cityRepository.findFirstByOrderByIdAsc().orElse(null);
            if (city == null) {
                model.addAttribute("errorMessage", "도시 데이터가 없습니다. cityT 테이블을 확인해주세요.");
                return "plan/plan";
            }
            cityId = city.getId();
        }
        List<Spot> spotList = spotService.list(null, catCode, cityId, 0, 100).getContent();

        model.addAttribute("city", city);
        model.addAttribute("catCode", catCode);
        model.addAttribute("spotList", spotList);

        // 중요: 현재 선택된 도시 ID를 다시 모델에 담아 JSP에 전달
        model.addAttribute("selectedCity", cityId);

        return "plan/plan";
    }
}
