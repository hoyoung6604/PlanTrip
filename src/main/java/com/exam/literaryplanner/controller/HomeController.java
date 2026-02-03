package com.exam.literaryplanner.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
// http://localhost:8080/ 요청을 처리하여 "index"라는 뷰 이름을 반환합니다.
	@GetMapping({"/", "/index"})
	public String home() {
// View Resolver가 /WEB-INF/views/index.jsp 로 변환하여 찾아줍니다.
		return "index";
	}
	
}
