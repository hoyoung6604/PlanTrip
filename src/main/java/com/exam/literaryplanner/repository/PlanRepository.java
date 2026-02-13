package com.exam.literaryplanner.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.exam.literaryplanner.domain.TravelPlan;

public interface PlanRepository extends JpaRepository<TravelPlan, Integer> {

    @Query("SELECT p FROM TravelPlan p WHERE p.mIdx = :mIdx ORDER BY p.tpIdx DESC")
    List<TravelPlan> findByMIdxLatest(@Param("mIdx") Integer mIdx);
}
