package com.exam.literaryplanner.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.PlanSaveRequest;
import com.exam.literaryplanner.service.PlanSaveService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/route")
public class RouteSaveController {

    private final PlanSaveService planSaveService;

    public RouteSaveController(PlanSaveService planSaveService) {
        this.planSaveService = planSaveService;
    }

    @PostMapping("/save")
    public ResponseEntity<?> save(@RequestBody PlanSaveRequest req, HttpSession session) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return ResponseEntity.status(401).body(Map.of("ok", false, "msg", "로그인이 필요합니다."));
        }

        Integer savedPIdx = planSaveService.saveRoutePlan(loginMember.getMIdx(), req);

        return ResponseEntity.ok(Map.of("ok", true, "pIdx", savedPIdx));
    }
}
