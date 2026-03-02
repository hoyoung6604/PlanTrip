package com.exam.literaryplanner.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.exam.literaryplanner.repository.PlanDetailRepository;
import com.exam.literaryplanner.repository.RoutePointView;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PlanMapService {

    private final PlanDetailRepository planDetailRepository;

    // ObjectMapper는 Spring Bean으로 주입해도 되는데, 지금 방식 유지해도 OK
    private final ObjectMapper om = new ObjectMapper();

    // =========================
    // ✅ 동선용(숙소 제외) JSON
    // - 기존 buildPointsJson 이름 유지
    // =========================
    public String buildPointsJson(Integer pIdx) {
        var rows = planDetailRepository.findRoutePointsExcludeStay(pIdx);

        System.out.println("[MAP-ROUTE] pIdx=" + pIdx + " rows=" + (rows == null ? 0 : rows.size()));
        if (rows != null && !rows.isEmpty()) {
            var r0 = rows.get(0);
            System.out.println("[MAP-ROUTE] first=" + r0.getName() + " lat=" + r0.getLat() + " lng=" + r0.getLng() + " day=" + r0.getDay());
        }

        try {
            return om.writeValueAsString(rows == null ? List.of() : rows);
        } catch (Exception e) {
            return "[]";
        }
    }

    // =========================
    // ✅ 숙소용 JSON (마커 전용)
    // =========================
    public String buildStaysJson(Integer pIdx) {
        var rows = planDetailRepository.findStayPoints(pIdx);

        System.out.println("[MAP-STAY] pIdx=" + pIdx + " rows=" + (rows == null ? 0 : rows.size()));
        if (rows != null && !rows.isEmpty()) {
            var r0 = rows.get(0);
            System.out.println("[MAP-STAY] first=" + r0.getName() + " lat=" + r0.getLat() + " lng=" + r0.getLng() + " day=" + r0.getDay());
        }

        try {
            return om.writeValueAsString(rows == null ? List.of() : rows);
        } catch (Exception e) {
            return "[]";
        }
    }

    // =========================
    // ✅ 목적지 이름(숙소 제외)
    // =========================
    public List<String> getSpotNames(Integer pIdx) {
        return planDetailRepository.findRoutePointsExcludeStay(pIdx).stream()
                .map(RoutePointView::getName)
                .filter(n -> n != null && !n.isBlank())
                .toList();
    }

    // =========================
    // ✅ 목적지 이름 day별(숙소 제외)
    // =========================
    public Map<Integer, List<String>> getSpotNamesByDay(Integer pIdx) {
        var rows = planDetailRepository.findRoutePointsExcludeStay(pIdx);

        Map<Integer, List<String>> byDay = new LinkedHashMap<>();
        for (var r : rows) {
            if (r.getDay() == null) {
				continue;
			}

            String name = r.getName();
            if (name == null || name.isBlank()) {
				continue;
			}

            byDay.computeIfAbsent(r.getDay(), k -> new ArrayList<>()).add(name);
        }
        return byDay;
    }

    // =========================
    // ✅ 숙소 이름 day별(숙소만)
    // =========================
    public Map<Integer, List<String>> getStayNamesByDay(Integer pIdx) {
        var rows = planDetailRepository.findStayPoints(pIdx);

        Map<Integer, List<String>> byDay = new LinkedHashMap<>();
        for (var r : rows) {
            if (r.getDay() == null) {
				continue;
			}

            String name = r.getName();
            if (name == null || name.isBlank()) {
				continue;
			}

            byDay.computeIfAbsent(r.getDay(), k -> new ArrayList<>()).add(name);
        }
        return byDay;
    }
}