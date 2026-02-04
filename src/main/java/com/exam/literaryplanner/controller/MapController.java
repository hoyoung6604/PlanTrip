package com.exam.literaryplanner.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MapController {

    @GetMapping("/maps")
    public String maps() {
        return "maps";
    }
}
