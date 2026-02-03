package com.exam.literaryplanner.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PageController {

    @GetMapping("/plan")
    public String plan() {
        return "plan";
    }

    @GetMapping("/profile")
    public String profile() {
        return "profile";
    }

    @GetMapping("/reservations")
    public String reservations() {
        // 추후 예약 페이지로 교체
        return "support";
    }
    
}
