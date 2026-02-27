package com.exam.literaryplanner.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.exam.literaryplanner.domain.TravelPlan;
import com.exam.literaryplanner.dto.TravelPlanViewRow;

@Repository
public interface TravelPlanRepository extends JpaRepository<TravelPlan, Integer> {
	// 🔥 내 계획 목록 (m_idx 기준)
    @Query("SELECT t FROM TravelPlan t WHERE t.mIdx = :mIdx ORDER BY t.pRegDate DESC")
    List<TravelPlan> findMyPlans(@Param("mIdx") Integer mIdx);

    @Query("SELECT t FROM TravelPlan t WHERE t.pIdx = :pIdx AND t.mIdx = :mIdx")
    Optional<TravelPlan> findMyPlan(@Param("pIdx") Integer pIdx, @Param("mIdx") Integer mIdx);

    @Modifying
    @org.springframework.transaction.annotation.Transactional
    @Query("DELETE FROM TravelPlan t WHERE t.pIdx = :pIdx AND t.mIdx = :mIdx")
    int deleteMyPlan(@Param("pIdx") Integer pIdx, @Param("mIdx") Integer mIdx);
    
    @Query(value = """
            SELECT
              tp.p_idx     AS pIdx,
              tp.m_idx     AS mIdx,
              tp.p_title   AS pTitle,
              tp.p_start   AS pStart,
              tp.p_end     AS pEnd,
              tp.tp_title  AS tpTitle,
              tp.p_regDate AS pRegDate
            FROM travelPlanT tp
            WHERE tp.p_idx = :pIdx
              AND tp.m_idx = :mIdx
            """, nativeQuery = true)
        Optional<TravelPlanViewRow> findMyPlanView(@Param("pIdx") Integer pIdx,
                                                  @Param("mIdx") Integer mIdx);
}