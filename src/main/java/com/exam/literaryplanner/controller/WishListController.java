package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.service.WishListService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/wish")
@RequiredArgsConstructor
public class WishListController {

    private final WishListService wishListService;

    @PostMapping("/toggle")
    public ResponseEntity<Map<String, Object>> toggleWish(
            @RequestBody Map<String, Integer> requestBody,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        // 1. 세션에서 로그인 회원 정보 확인 (세션 키는 본인의 프로젝트에 맞게 수정: 예: "loginMember")
        // 만약 세션에 멤버 객체가 통째로 있다면 객체를 꺼낸 후 getMIdx()를 호출해야 합니다.
        Object loginMember = session.getAttribute("loginMember"); 

        if (loginMember == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요한 서비스입니다.");
            return ResponseEntity.status(401).body(response);
        }

        // 로그인된 객체에서 mIdx 추출 (객체 타입에 따라 형변환 필요)
        // 예: Integer mIdx = ((Member)loginMember).getMIdx();
        // 여기서는 편의상 mIdx가 세션에 직접 있다고 가정하거나 형변환을 수행합니다.
        Integer mIdx = extractMIdx(loginMember); 
        Integer sIdx = requestBody.get("sIdx");

        // 2. 서비스 호출 (토글 실행)
        boolean isHearted = wishListService.toggleWish(mIdx, sIdx);

        // 3. 결과 반환
        response.put("success", true);
        response.put("isHearted", isHearted); // true면 꽉 찬 하트, false면 빈 하트
        return ResponseEntity.ok(response);
    }

    // 세션 객체에서 mIdx를 안전하게 꺼내는 보조 메서드 (본인의 Member 클래스에 맞게 수정하세요)
    private Integer extractMIdx(Object loginMember) {
        // 예시: return ((Member)loginMember).getMIdx();
        // 지금은 테스트를 위해 mIdx를 필드로 가진 객체라고 가정합니다.
        try {
            return (Integer) loginMember.getClass().getMethod("getMIdx").invoke(loginMember);
        } catch (Exception e) {
            return null; 
        }
    }
}