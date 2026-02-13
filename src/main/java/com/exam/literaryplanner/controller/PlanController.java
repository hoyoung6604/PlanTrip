package com.exam.literaryplanner.controller;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.domain.PlanDetail;
import com.exam.literaryplanner.domain.TravelPlan;
import com.exam.literaryplanner.service.PlanService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@Controller
public class PlanController {

    private final PlanService planService;

    public PlanController(PlanService planService) {
        this.planService = planService;
    }

    @GetMapping("/plans")
    public String myPlans(HttpSession session, Model model) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        List<TravelPlan> plans = planService.listMyPlans(loginMember.getMIdx());
        model.addAttribute("plans", plans);
        return "plans";
    }

    @PostMapping("/plan/save")
    public String savePlan(
            @RequestParam String tpTitle,
            @RequestParam(required = false) String tpStartDate,
            @RequestParam(required = false) String tpEndDate,

            // Step1(6가지)
            @RequestParam(required = false) String arrivalTime,
            @RequestParam(required = false) String departTime,
            @RequestParam(required = false) String[] goals,
            @RequestParam(required = false) String lodgingArea,
            @RequestParam(required = false) String transport,
            @RequestParam(required = false) String paceStyle,
            @RequestParam(required = false) String rhythmStyle,
            @RequestParam(required = false) String fixedBookings,

            // Step2(권역)
            @RequestParam(required = false) String[] dayRegion1,
            @RequestParam(required = false) String[] dayRegion2,

            // Step4(안전장치)
            @RequestParam(required = false) String bufferHours,
            @RequestParam(required = false) String planB,
            @RequestParam(required = false) String foodAlt1,
            @RequestParam(required = false) String foodAlt2,

            // 기존 상세
            @RequestParam(required = false) Integer[] dayNo,
            @RequestParam(required = false) Integer[] orderNo,
            @RequestParam(required = false) Integer[] sIdx,
            @RequestParam(required = false) String[] memo,

            HttpSession session
    ) {

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        // --- meta 요약 텍스트 만들기(가볍게) ---
        StringBuilder meta = new StringBuilder();
        meta.append("[6가지 사전결정]\n");
        meta.append("- 도착/출발: ").append(nz(arrivalTime)).append(" / ").append(nz(departTime)).append("\n");
        meta.append("- 목적: ").append(join(goals)).append("\n");
        meta.append("- 숙소 위치(중심): ").append(nz(lodgingArea)).append("\n");
        meta.append("- 이동수단: ").append(nz(transport)).append("\n");
        meta.append("- 성향(빡빡/여유): ").append(nz(paceStyle)).append(" / (아침/올빼미): ").append(nz(rhythmStyle)).append("\n");
        meta.append("- 고정예약: ").append(nz(fixedBookings)).append("\n\n");

        meta.append("[하루 권역]\n");
        if (dayRegion1 != null) {
            for (int i = 0; i < dayRegion1.length; i++) {
                String r1 = dayRegion1[i];
                String r2 = (dayRegion2 != null && i < dayRegion2.length) ? dayRegion2[i] : "";
                meta.append("- Day ").append(i + 1).append(": ")
                        .append(nz(r1));
                if (r2 != null && !r2.isBlank()) meta.append(" / ").append(r2);
                meta.append("\n");
            }
        } else {
            meta.append("- (미입력)\n");
        }

        meta.append("\n[안전장치]\n");
        meta.append("- 예비시간: ").append(nz(bufferHours)).append("\n");
        meta.append("- Plan B: ").append(nz(planB)).append("\n");
        meta.append("- 식당 후보 2개: ").append(nz(foodAlt1)).append(" / ").append(nz(foodAlt2)).append("\n");

        // --- 상세 일정 만들기 ---
        List<PlanDetail> details = new ArrayList<>();

        if (dayNo != null && orderNo != null) {
            int len = Math.min(dayNo.length, orderNo.length);
            for (int i = 0; i < len; i++) {
                PlanDetail d = new PlanDetail();
                d.setDayNo(dayNo[i] == null ? 1 : dayNo[i]);
                d.setOrderNo(orderNo[i] == null ? (i + 1) : orderNo[i]);
                if (sIdx != null && i < sIdx.length) d.setSIdx(sIdx[i]);
                if (memo != null && i < memo.length) d.setMemo(memo[i]);
                details.add(d);
            }
        }

        planService.createPlan(
                loginMember.getMIdx(),
                tpTitle,
                tpStartDate,
                tpEndDate,
                meta.toString(),
                details
        );

        return "redirect:/plans";
    }

    @GetMapping("/plans/view")
    public String viewPlan(@RequestParam Integer tpIdx, HttpSession session, Model model) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        TravelPlan plan = planService.getPlan(tpIdx);
        if (!plan.getMIdx().equals(loginMember.getMIdx())) return "redirect:/plans";

        model.addAttribute("plan", plan);
        model.addAttribute("details", planService.getPlanDetails(tpIdx));
        return "planView";
    }

    @PostMapping("/plans/delete")
    public String deletePlan(@RequestParam Integer tpIdx, HttpSession session) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/members/login";

        TravelPlan plan = planService.getPlan(tpIdx);
        if (!plan.getMIdx().equals(loginMember.getMIdx())) return "redirect:/plans";

        planService.deletePlan(tpIdx);
        return "redirect:/plans";
    }

    private String nz(String s) {
        return (s == null || s.isBlank()) ? "-" : s.trim();
    }

    private String join(String[] arr) {
        if (arr == null || arr.length == 0) return "-";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < arr.length; i++) {
            if (arr[i] == null || arr[i].isBlank()) continue;
            if (sb.length() > 0) sb.append(", ");
            sb.append(arr[i].trim());
        }
        return sb.length() == 0 ? "-" : sb.toString();
    }
}
