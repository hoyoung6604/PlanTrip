package com.exam.literaryplanner.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.exam.literaryplanner.domain.PlanDetail;
import com.exam.literaryplanner.domain.TravelPlan;
import com.exam.literaryplanner.repository.PlanDetailRepository;
import com.exam.literaryplanner.repository.PlanRepository;

@Service
public class PlanService {

    private final PlanRepository planRepository;
    private final PlanDetailRepository planDetailRepository;

    public PlanService(PlanRepository planRepository, PlanDetailRepository planDetailRepository) {
        this.planRepository = planRepository;
        this.planDetailRepository = planDetailRepository;
    }

    public List<TravelPlan> listMyPlans(Integer mIdx) {
        return planRepository.findByMIdxLatest(mIdx);
    }

    public TravelPlan getPlan(Integer tpIdx) {
        return planRepository.findById(tpIdx).orElseThrow();
    }

    public List<PlanDetail> getPlanDetails(Integer tpIdx) {
        return planDetailRepository.findByTpIdxOrdered(tpIdx);
    }

    @Transactional
    public Integer createPlan(Integer mIdx, String title, String startDate, String endDate,
                           String metaText,
                           List<PlanDetail> details) {

        TravelPlan p = new TravelPlan();
        p.setMIdx(mIdx);
        p.setTpTitle(title);
        p.setTpStartDate(startDate);
        p.setTpEndDate(endDate);
        p.setTpMeta(metaText);

        TravelPlan saved = planRepository.save(p);

        if (details != null) {
            for (PlanDetail d : details) {
                d.setTpIdx(saved.getTpIdx());
                planDetailRepository.save(d);
            }
        }

        return saved.getTpIdx();
    }

    @Transactional
    public void deletePlan(Integer tpIdx) {
        planDetailRepository.deleteByTpIdx(tpIdx);
        planRepository.deleteById(tpIdx);
    }
}
