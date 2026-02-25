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

@Repository
public interface SpotRepository extends JpaRepository<Spot, Integer> { // ✅ Integer 사용

    // 1. 카테고리 코드로 장소 리스트 찾기
    List<Spot> findByCatCode(String catCode);

    // 2. 검색 기능 (페이징 포함)
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

    // 3. 상세 정보 조회 (City와 Fetch Join)
    @Query("""
        select s from Spot s
        left join fetch s.city
        where s.id = :id
    """)
    Optional<Spot> findDetail(@Param("id") Integer id);

}