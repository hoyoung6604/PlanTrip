package com.exam.literaryplanner.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.exam.literaryplanner.domain.PlanDetail;
import com.exam.literaryplanner.domain.TravelPlan;

@Repository
public interface PlanDetailRepository extends JpaRepository<PlanDetail, Integer> {
  void deleteByPIdx(Integer pIdx);
  List<PlanDetail> findByPIdxOrderByPDayAscPSeqAsc(Integer pIdx);
  
  @Query("select coalesce(max(d.pSeq), 0) from PlanDetail d where d.pIdx = :pIdx")
  int findMaxSeq(@Param("pIdx") int pIdx);
}