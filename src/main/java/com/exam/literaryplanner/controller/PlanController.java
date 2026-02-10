package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.Review;
import com.exam.literaryplanner.repository.LiteraryRepository;
import com.exam.literaryplanner.repository.ReviewRepository;
import com.exam.literaryplanner.service.MemberDeleteService;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/plan")
public class PlanController {

	 @GetMapping("")
	    public String plan() {
	        return "plan/plan";
	    }


}

