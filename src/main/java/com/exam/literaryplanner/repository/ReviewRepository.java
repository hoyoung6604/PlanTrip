package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Integer> {

    // ===== 내 후기 =====
    @Query("SELECT r FROM Review r WHERE r.mIdx = :mIdx ORDER BY r.rvIdx DESC")
    List<Review> findByMIdxOrderByRvIdxDesc(@Param("mIdx") Integer mIdx);

    @Query("""
        SELECT r
        FROM Review r
        WHERE r.mIdx = :mIdx
          AND r.rvTitle LIKE CONCAT('%', :rvTitle, '%')
        ORDER BY r.rvIdx DESC
    """)
    List<Review> findByMIdxAndRvTitleContainingOrderByRvIdxDesc(
            @Param("mIdx") Integer mIdx,
            @Param("rvTitle") String rvTitle
    );

    // ===== 커뮤니티 검색 최신순 =====
    @Query("""
        SELECT r
        FROM Review r
        WHERE (:kw IS NULL OR :kw = '' OR r.rvTitle LIKE CONCAT('%', :kw, '%') OR r.rvCont LIKE CONCAT('%', :kw, '%'))
          AND (:minStar IS NULL OR r.rvStar >= :minStar)
          AND (:sIdx IS NULL OR r.sIdx = :sIdx)
        ORDER BY r.rvIdx DESC
    """)
    List<Review> searchOrderByLatestDesc(@Param("kw") String keyword,
                                        @Param("minStar") Integer minStar,
                                        @Param("sIdx") Integer sIdx);

    // ===== 커뮤니티 검색 별점순 =====
    @Query("""
        SELECT r
        FROM Review r
        WHERE (:kw IS NULL OR :kw = '' OR r.rvTitle LIKE CONCAT('%', :kw, '%') OR r.rvCont LIKE CONCAT('%', :kw, '%'))
          AND (:minStar IS NULL OR r.rvStar >= :minStar)
          AND (:sIdx IS NULL OR r.sIdx = :sIdx)
        ORDER BY r.rvStar DESC, r.rvIdx DESC
    """)
    List<Review> searchOrderByStarDesc(@Param("kw") String keyword,
                                      @Param("minStar") Integer minStar,
                                      @Param("sIdx") Integer sIdx);

    // 전체
    @Query("SELECT r FROM Review r ORDER BY r.rvIdx DESC")
    List<Review> findAllLatest();

    @Query("SELECT r FROM Review r ORDER BY r.rvStar DESC, r.rvIdx DESC")
    List<Review> findAllStar();
}

