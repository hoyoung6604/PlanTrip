package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.repository.SpotRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/spots")
public class SpotController {

    @Autowired
    private SpotRepository spotRepository;

    @GetMapping("/list")
    public String getCategoryList(@RequestParam("category") String category, Model model) {
        // 1. DB에서 해당 카테고리(맛집, 숙소 등) 데이터 가져오기
        List<Spot> spotList = spotRepository.findByCatCode(category);
        
        // 2. 화면에 데이터 전달 (이름표: list)
        model.addAttribute("list", spotList);
        
        // 3. 한글 타이틀 변환 (화면에 '맛집' 이렇게 띄우기 위해)
        String title = switch(category) {
            case "FOOD" -> "맛집";
            case "TOUR" -> "관광지";
            case "STAY" -> "숙소";
            case "ACT" -> "문화/체험";
            default -> "추천 장소";
        };
        model.addAttribute("title", title);

        // 4. spots.jsp 페이지 열기
        return "spots"; 
    }
}