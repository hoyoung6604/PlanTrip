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
  
  @Query(value = """
		    SELECT s.s_name AS name, s.s_lat AS lat, s.s_lng AS lng
		    FROM planDetailT d
		    JOIN spotT s ON s.s_idx = d.s_idx
		    WHERE d.p_idx = :pIdx
		    ORDER BY d.p_day ASC, d.p_seq ASC
		    """, nativeQuery = true)
		List<Object[]> findPointsNative(@Param("pIdx") Integer pIdx);

  	@Query(value = """
  			SELECT
  				s.s_name AS name,
  			    s.s_lat  AS lat,
  			    s.s_lng  AS lng,
  			    d.p_day  AS day,
  			    d.p_seq  AS seq
  			FROM planDetailT d
  			    JOIN spotT s ON s.s_idx = d.s_idx
  			    WHERE d.p_idx = :pIdx
  			    ORDER BY d.p_day ASC, d.p_seq ASC
  			""", nativeQuery = true)
  			List<RoutePointView> findRoutePoints(@Param("pIdx") Integer pIdx);
}