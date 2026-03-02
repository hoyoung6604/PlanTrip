package com.exam.literaryplanner.controller;

import java.util.ArrayList;
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
import com.exam.literaryplanner.service.WishListService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/spots")
@RequiredArgsConstructor
public class SpotController {

    private final SpotService spotService;
    private final CityRepository cityRepository;
    private final WishListService wishListService; // 찜 기능 서비스 의존성 추가

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
            if (cityId == null) {
                cityId = 4;
            }
        }

        // 로그인 사용자 정보 추출
        Object loginMember = session.getAttribute("loginMember");
        Integer mIdx = extractMIdx(loginMember);

        // 2. 이후 로직
        City city = cityRepository.findById(cityId).orElseThrow();
        model.addAttribute("city", city);
        model.addAttribute("selectedCity", cityId);

        // 각 리스트 조회
        List<Spot> tourList = spotService.list(null, "TOUR", cityId, 0, 10).getContent();
        List<Spot> stayList = spotService.list(null, "STAY", cityId, 0, 10).getContent();
        List<Spot> actList = spotService.list(null, "ACT", cityId, 0, 10).getContent();
        List<Spot> foodList = spotService.list(null, "FOOD", cityId, 0, 10).getContent();

        // 찜 상태 반영
        applyWishListStatus(tourList, mIdx);
        applyWishListStatus(stayList, mIdx);
        applyWishListStatus(actList, mIdx);
        applyWishListStatus(foodList, mIdx);

        model.addAttribute("tourList", tourList);
        model.addAttribute("stayList", stayList);
        model.addAttribute("actList", actList);
        model.addAttribute("foodList", foodList);

        return "spot/spot";
    }

    // 도시 버튼을 누를 때 데이터만 보내주는 메서드
    @GetMapping("/api/contents")
    @ResponseBody
    public Map<String, Object> getCityContents(
            @RequestParam(value = "cityId") Integer cityId,
            HttpSession session) {

        Map<String, Object> map = new HashMap<>();

        // 로그인 사용자 정보 추출
        Object loginMember = session.getAttribute("loginMember");
        Integer mIdx = extractMIdx(loginMember);

        // 카테고리별 데이터 조회
        List<Spot> tourList = spotService.list(null, "TOUR", cityId, 0, 10).getContent();
        List<Spot> stayList = spotService.list(null, "STAY", cityId, 0, 10).getContent();
        List<Spot> actList = spotService.list(null, "ACT", cityId, 0, 10).getContent();
        List<Spot> foodList = spotService.list(null, "FOOD", cityId, 0, 10).getContent();

        // 찜 상태 반영
        applyWishListStatus(tourList, mIdx);
        applyWishListStatus(stayList, mIdx);
        applyWishListStatus(actList, mIdx);
        applyWishListStatus(foodList, mIdx);

        map.put("tourList", tourList);
        map.put("stayList", stayList);
        map.put("actList", actList);
        map.put("foodList", foodList);

        return map;
    }

    @GetMapping("/detail/{id}")
    public String getSpotDetail(@PathVariable("id") Integer id, HttpSession session, Model model) {
        Spot spot = spotService.findById(id);

        // 상세 페이지 찜 여부 체크
        Object loginMember = session.getAttribute("loginMember");
        Integer mIdx = extractMIdx(loginMember);
        if (mIdx != null) {
            spot.setIsHearted(wishListService.isHearted(mIdx, spot.getId()));
        }

        model.addAttribute("spot", spot);
        return "spot/detail";
    }

    @GetMapping("/all")
    public String getAllSpots(
            @RequestParam("cityId") Integer cityId,
            @RequestParam("catCode") String catCode,
            HttpSession session,
            Model model) {

        City city = cityRepository.findById(cityId).orElseThrow();
        List<Spot> spotList = spotService.list(null, catCode, cityId, 0, 100).getContent();

        // 로그인 사용자 정보 추출 및 찜 상태 반영
        Object loginMember = session.getAttribute("loginMember");
        Integer mIdx = extractMIdx(loginMember);
        applyWishListStatus(spotList, mIdx);

        model.addAttribute("city", city);
        model.addAttribute("catCode", catCode);
        model.addAttribute("spotList", spotList);
        model.addAttribute("selectedCity", cityId);

        return "spot/all";
    }

    @GetMapping("/api/recommend")
    @ResponseBody
    public List<Map<String, Object>> getRecommend(@RequestParam("category") String category, HttpSession session) {
        List<Spot> spots = spotService.getRandomSpotsByCategory(category);
        List<Map<String, Object>> result = new ArrayList<>();

        Object loginMember = session.getAttribute("loginMember");
        Integer mIdx = extractMIdx(loginMember);

        for (Spot s : spots) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", s.getId());
            map.put("name", s.getName());
            map.put("image", s.getImage());
            map.put("cityName", (s.getCity() != null) ? s.getCity().getName() : "기타");

            // 찜 상태 추가
            boolean hearted = (mIdx != null) && wishListService.isHearted(mIdx, s.getId());
            map.put("isHearted", hearted);

            result.add(map);
        }
        return result;
    }

    // 공통 보조 메서드 1: 리스트 내부의 각 Spot에 대해 찜 여부를 체크하여 세팅
    private void applyWishListStatus(List<Spot> spots, Integer mIdx) {
        if (mIdx == null || spots == null || spots.isEmpty()) {
            return;
        }
        for (Spot s : spots) {
            boolean hearted = wishListService.isHearted(mIdx, s.getId());
            s.setIsHearted(hearted);
        }
    }

    // 공통 보조 메서드 2: 세션 객체에서 mIdx 추출
    private Integer extractMIdx(Object loginMember) {
        if (loginMember == null) {
            return null;
        }
        try {
            return (Integer) loginMember.getClass().getMethod("getMIdx").invoke(loginMember);
        } catch (Exception e) {
            return null;
        }
    }
}