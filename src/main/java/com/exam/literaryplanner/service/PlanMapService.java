package com.exam.literaryplanner.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.exam.literaryplanner.domain.PlanDetail;
import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.dto.MapPoint;
import com.exam.literaryplanner.repository.PlanDetailRepository;
import com.exam.literaryplanner.repository.RoutePointView;
import com.exam.literaryplanner.repository.SpotRepository;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PlanMapService {

    private final PlanDetailRepository planDetailRepository;
    private final SpotRepository spotRepository;

    private final ObjectMapper om = new ObjectMapper();

    public String buildPointsJson(Integer pIdx) {
        var rows = planDetailRepository.findRoutePoints(pIdx);

        System.out.println("[MAP] pIdx=" + pIdx + " rows=" + (rows == null ? 0 : rows.size()));
        if (rows != null && !rows.isEmpty()) {
            var r0 = rows.get(0);
            System.out.println("[MAP] first=" + r0.getName() + " lat=" + r0.getLat() + " lng=" + r0.getLng());
        }

        try {
            return om.writeValueAsString(rows == null ? java.util.List.of() : rows);
        } catch (Exception e) {
            return "[]";
        }
    }

    public List<String> getSpotNames(Integer pIdx) {
        return planDetailRepository.findRoutePoints(pIdx).stream()
                .map(RoutePointView::getName)
                .filter(n -> n != null && !n.isBlank())
                .toList();
    }
    
    public Map<Integer, List<String>> getSpotNamesByDay(Integer pIdx) {
        var rows = planDetailRepository.findRoutePoints(pIdx);

        Map<Integer, List<String>> byDay = new LinkedHashMap<>();
        for (var r : rows) {
            if (r.getDay() == null) continue;
            String name = r.getName();
            if (name == null || name.isBlank()) continue;

            byDay.computeIfAbsent(r.getDay(), k -> new ArrayList<>()).add(name);
        }
        return byDay;
    }
}