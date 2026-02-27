package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.service.SpotService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
@RequiredArgsConstructor // SpotService를 자동으로 주입받기 위해 추가합니다.
public class HomeController {

    private final SpotService spotService;

    // "/"와 "/index" 요청을 모두 처리합니다.
    @GetMapping({"/", "/index"})
    public String home(Model model) {
        // 1. 오늘의 인기 여행지 6개 데이터를 가져옵니다.
        List<Spot> popularSpots = spotService.getTodayPopularSpots();
        
        // 2. JSP에서 사용할 수 있도록 모델에 담습니다.
        model.addAttribute("popularSpots", popularSpots);

        // View Resolver가 /WEB-INF/views/index.jsp 로 변환하여 찾아줍니다.
        return "index";
    }
}