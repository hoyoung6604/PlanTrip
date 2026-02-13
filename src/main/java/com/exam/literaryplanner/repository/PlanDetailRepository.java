package com.exam.literaryplanner.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.exam.literaryplanner.domain.PlanDetail;

public interface PlanDetailRepository extends JpaRepository<PlanDetail, Integer> {

    @Query("SELECT d FROM PlanDetail d WHERE d.tpIdx = :tpIdx ORDER BY d.dayNo ASC, d.orderNo ASC")
    List<PlanDetail> findByTpIdxOrdered(@Param("tpIdx") Integer tpIdx);

    void deleteByTpIdx(Integer tpIdx);
}
