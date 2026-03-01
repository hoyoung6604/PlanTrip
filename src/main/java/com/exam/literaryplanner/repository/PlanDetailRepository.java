package com.exam.literaryplanner.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.exam.literaryplanner.domain.PlanDetail;
import com.exam.literaryplanner.domain.Spot;

@Repository
public interface PlanDetailRepository extends JpaRepository<PlanDetail, Integer> {

  void deleteByPIdx(Integer pIdx);

  List<PlanDetail> findByPIdxOrderByPDayAscPSeqAsc(Integer pIdx);

  @Query("select coalesce(max(d.pSeq), 0) from PlanDetail d where d.pIdx = :pIdx")
  int findMaxSeq(@Param("pIdx") int pIdx);

  // (유지) 그냥 native rows 필요할 때
  @Query(value = """
      SELECT s.s_name AS name, s.s_lat AS lat, s.s_lng AS lng
      FROM planDetailT d
      JOIN spotT s ON s.s_idx = d.s_idx
      WHERE d.p_idx = :pIdx
      ORDER BY d.p_day ASC, d.p_seq ASC
      """, nativeQuery = true)
  List<Object[]> findPointsNative(@Param("pIdx") Integer pIdx);

  // =========================
  // ✅ 동선용(숙소 제외) RoutePointView
  // =========================
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
        AND s.cat_code <> 'STAY'
      ORDER BY d.p_day ASC, d.p_seq ASC
      """, nativeQuery = true)
  List<RoutePointView> findRoutePointsExcludeStay(@Param("pIdx") Integer pIdx);

  // =========================
  // ✅ 숙소용(숙소만) RoutePointView
  // =========================
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
        AND s.cat_code = 'STAY'
      ORDER BY d.p_day ASC, d.p_seq ASC
      """, nativeQuery = true)
  List<RoutePointView> findStayPoints(@Param("pIdx") Integer pIdx);

  // =========================
  // (유지) JPQL로 Spot 전체 가져오기
  // =========================
  @Query("""
      SELECT s
      FROM PlanDetail d
      JOIN Spot s ON d.sIdx = s.id
      WHERE d.pIdx = :pIdx
      ORDER BY d.pDay ASC, d.pSeq ASC
    """)
  List<Spot> findSpotsByPlan(@Param("pIdx") Integer pIdx);

  @Query("""
      SELECT d.pDay, s
      FROM PlanDetail d
      JOIN Spot s ON d.sIdx = s.id
      WHERE d.pIdx = :pIdx
      ORDER BY d.pDay ASC, d.pSeq ASC
    """)
  List<Object[]> findSpotsWithDayByPlan(@Param("pIdx") Integer pIdx);
}