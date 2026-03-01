package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.service.SpotService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class MapController {

    private final SpotService spotService;

    @GetMapping("/maps")
    public String maps(HttpSession session, Model model) {
        Object loginMember = session.getAttribute("loginMember");
        List<Map<String, Object>> wishSpots = new ArrayList<>();

        if (loginMember != null) {
            try {
                Integer mIdx = (Integer) loginMember.getClass().getMethod("getMIdx").invoke(loginMember);
                List<Spot> list = spotService.getWishSpots(mIdx); 
                
                for (Spot spot : list) {
                    if (spot.getLat() != null && spot.getLng() != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("id", spot.getId());
                        map.put("name", spot.getName().replace("\"", "\\\"").replace("'", "\\'"));
                        map.put("addr", spot.getAddr() != null ? spot.getAddr().replace("\"", "\\\"").replace("'", "\\'") : "");
                        map.put("lat", spot.getLat());
                        map.put("lng", spot.getLng());
                        map.put("catCode", spot.getCatCode());
                        map.put("image", spot.getImage() != null ? spot.getImage() : "");
                        
                        // ✅ 네이버 지도 스타일 상세 정보를 위해 추가된 데이터
                        map.put("price", spot.getPrice() != null ? spot.getPrice() : "0.0");
                        map.put("hours", spot.getHours() != null ? spot.getHours().replace("\"", "\\\"").replace("'", "\\'") : "정보 없음");
                        map.put("holiday", spot.getHoliday() != null ? spot.getHoliday().replace("\"", "\\\"").replace("'", "\\'") : "연중무휴");
                        
                        // info 데이터의 줄바꿈과 따옴표를 안전하게 처리
                        String safeInfo = spot.getInfo() != null ? spot.getInfo().replaceAll("[\\r\\n]+", " ") : "상세 정보가 없습니다.";
                        map.put("info", safeInfo.replace("\"", "\\\"").replace("'", "\\'"));
                        
                        wishSpots.add(map);
                    }
                }
            } catch (Exception e) {
                // 에러 무시
            }
        }

        model.addAttribute("wishSpots", wishSpots);

        return "maps";
    }
}