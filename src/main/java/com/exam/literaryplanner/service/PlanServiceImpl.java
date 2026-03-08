package com.exam.literaryplanner.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.exam.literaryplanner.domain.TravelPlan;
import com.exam.literaryplanner.repository.TravelPlanRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PlanServiceImpl implements PlanService {

    private final TravelPlanRepository travelPlanRepository;

//    public PlanServiceImpl(TravelPlanRepository travelPlanRepository) {
//    	this.travelPlanRepository = travelPlanRepository;
//    }

    @Override
    @Transactional
    public Integer createPlan(String city, Integer mIdx, List<String> purposes,
                              LocalDate start, LocalDate end) {

        if (mIdx == null) {
			throw new IllegalArgumentException("mIdx is required");
		}
        if (start == null || end == null) {
			throw new IllegalArgumentException("start/end is required");
		}
        if (end.isBefore(start)) {
			throw new IllegalArgumentException("end date must be >= start date");
		}

        String safeCity = (city == null) ? "" : city.trim();
        String safePurposes = (purposes == null || purposes.isEmpty()) ? "" : String.join(",", purposes);

        String title = "여행계획";
        if (!safeCity.isBlank() || !safePurposes.isBlank()) {
            title = String.format("여행계획 (%s) [%s]", safeCity, safePurposes);
        }

        TravelPlan plan = new TravelPlan();
        plan.setMIdx(mIdx);
        plan.setPTitle(title);
     // ✅ 트리거 대신 서비스단에서 title 동기화
        plan.setPStart(start);
        plan.setPEnd(end);

        return travelPlanRepository.save(plan).getPIdx();
    }

    @Override
    @Transactional(readOnly = true)
    public TravelPlan getPlan(Integer planId) {
        return travelPlanRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("해당 계획이 존재하지 않습니다. id=" + planId));
    }
}