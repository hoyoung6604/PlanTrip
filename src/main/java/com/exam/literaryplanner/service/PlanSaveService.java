package com.exam.literaryplanner.service;

import com.exam.literaryplanner.domain.PlanDetail;
import com.exam.literaryplanner.domain.PlanSaveRequest;
import com.exam.literaryplanner.domain.PlanSaveRequest.PlanItem;
import com.exam.literaryplanner.domain.TravelPlan;
import com.exam.literaryplanner.repository.PlanDetailRepository;
import com.exam.literaryplanner.repository.TravelPlanRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;

@Service
public class PlanSaveService {

    private final TravelPlanRepository travelPlanRepository;
    private final PlanDetailRepository planDetailRepository;

    public PlanSaveService(TravelPlanRepository travelPlanRepository,
                           PlanDetailRepository planDetailRepository) {
        this.travelPlanRepository = travelPlanRepository;
        this.planDetailRepository = planDetailRepository;
    }

    @Transactional
    public Integer saveRoutePlan(Integer mIdx, PlanSaveRequest req) {

        if (mIdx == null) throw new IllegalArgumentException("로그인이 필요합니다.");
        if (req == null) throw new IllegalArgumentException("요청이 비었습니다.");
        if (req.getItems() == null || req.getItems().isEmpty())
            throw new IllegalArgumentException("저장할 장소가 없습니다.");

        Integer pIdx = req.getpIdx();
        if (pIdx == null || pIdx <= 0) {
            throw new IllegalArgumentException("pIdx가 필요합니다.");
        }

        // ✅ (선택) 다른 사람 플랜 수정 못하게 체크
        TravelPlan plan = travelPlanRepository.findById(pIdx)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 플랜입니다."));
        if (!Integer.valueOf(mIdx).equals(plan.getMIdx())) {
            throw new IllegalArgumentException("권한이 없습니다.");
        }

        // ✅ (추천) 기존 detail 싹 지우고 다시 저장 (중복 방지)
        planDetailRepository.deleteByPIdx(pIdx);

        // ✅ detail 저장
        for (PlanSaveRequest.PlanItem item : req.getItems()) {
            PlanDetail d = new PlanDetail();
            d.setpIdx(pIdx);
            d.setsIdx(item.getsIdx());
            d.setpDay(item.getDay());
            d.setpSeq(item.getSeq());
            d.setpMemo(item.getMemo());

            planDetailRepository.save(d);
        }

        return pIdx;
    }
    
    
}