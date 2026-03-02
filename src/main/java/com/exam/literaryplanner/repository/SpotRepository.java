package com.exam.literaryplanner.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.dto.SpotCardView;
import com.exam.literaryplanner.dto.SpotDistanceDto;

@Repository
public interface SpotRepository extends JpaRepository<Spot, Integer> {

    /* 1) 기본 조회 */
    List<Spot> findByCatCode(String catCode);

    /* 2) 검색 기능 (페이징 포함) */
    @Query("""
        select s from Spot s
        left join fetch s.city c
        where (:keyword is null or :keyword = '' or lower(s.name) like lower(concat('%', :keyword, '%')))
          and (:cat is null or :cat = '' or s.catCode = :cat)
          and (:cityId is null or s.city.id = :cityId)
    """)
    Page<Spot> search(@Param("keyword") String keyword,
                      @Param("cat") String catCode,
                      @Param("cityId") Integer cityId,
                      Pageable pageable);

    /* 3) 상세 정보 조회 (City와 Fetch Join) */
    @Query("""
        select s from Spot s
        left join fetch s.city
        where s.id = :id
    """)
    Optional<Spot> findDetail(@Param("id") Integer id);

    /* 4) 추천 카드: 통계/도시 join 한방쿼리 (프론트 카드용) */
    @Query(value = """
        select
          s.s_idx    as id,
          s.s_name   as name,
          s.s_image  as image,
          c.c_name   as cityName,
          ss.r_avg   as rAvg,
          ss.r_count as rCount,
          ss.v_count as vCount
        from spotT s
        join cityT c on c.c_idx = s.c_idx
        left join spotStatsT ss on ss.s_idx = s.s_idx
        where s.cat_code = :cat
        order by ss.v_count desc
    """, nativeQuery = true)
    List<SpotCardView> findRecommendCards(@Param("cat") String cat, Pageable pageable);

    /* 5) 가까운 숙소 20개 (거리 계산) - native query */
    @Query(value = """
        SELECT s.s_idx as sIdx,
               s.s_name as sName,
               s.s_lat as sLat,
               s.s_lng as sLng,
               (6371 * acos(
                 cos(radians(:lat))
                 * cos(radians(s.s_lat))
                 * cos(radians(s.s_lng) - radians(:lng))
                 + sin(radians(:lat))
                 * sin(radians(s.s_lat))
               )) AS distance
        FROM spotT s
        WHERE s.cat_code = 'STAY'
        ORDER BY distance ASC
        LIMIT 20
    """, nativeQuery = true)
    List<SpotDistanceDto> findNearestStay(@Param("lat") double lat,
                                          @Param("lng") double lng);

    /* 6) (필요 시) 카테고리 상위 N개 + city fetch */
    @Query("""
        select s
        from Spot s
        join fetch s.city
        where s.catCode = :cat
        order by s.id desc
    """)
    List<Spot> findTopWithCityByCat(@Param("cat") String cat, Pageable pageable);

    /* 7) (필요 시) 인기 스팟 + city fetch */
    @Query("""
        select s
        from Spot s
        join fetch s.city
        where s.catCode = :cat
        order by s.id desc
    """)
    List<Spot> findPopularSpotsWithCity(@Param("cat") String cat, Pageable pageable);

    Optional<Spot> findFirstByCity_IdOrderByIdAsc(Integer cityId);

    List<Spot> findByCity_IdAndCatCodeInOrderByNameAsc(Integer cityId, List<String> catCodes);

    List<Spot> findByIdIn(List<Integer> id);

    /* 8) 전체 찜한 목록 조회 (도시 정보 포함) */
    @Query("""
        SELECT s
        FROM Spot s
        LEFT JOIN FETCH s.city
        WHERE s.id IN (SELECT w.sIdx FROM WishList w WHERE w.mIdx = :mIdx)
    """)
    List<Spot> findWishSpotsByMemberIdx(@Param("mIdx") Integer mIdx);

    /* 9) 최근 찜한 장소 조회 (도시 정보 포함) */
    @Query("""
        SELECT s
        FROM Spot s
        LEFT JOIN FETCH s.city
        JOIN WishList w ON s.id = w.sIdx
        WHERE w.mIdx = :mIdx
        ORDER BY w.wDate DESC
    """)
    Page<Spot> findRecentWishSpots(@Param("mIdx") Integer mIdx, Pageable pageable);

    /* RouteController 등에서 Pageable 없이 호출할 때(20개 고정) */
    default List<SpotDistanceDto> findNearestStayDefault(double lat, double lng) {
        return findNearestStay(lat, lng);
    }
}
