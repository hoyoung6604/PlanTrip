package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.Spot;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface SpotRepository extends JpaRepository<Spot, Long> {

    @Query("""
        select s from Spot s
        left join fetch s.city c
        where (:keyword is null or :keyword = '' or lower(s.name) like lower(concat('%', :keyword, '%')))
          and (:cat is null or :cat = '' or s.catCode = :cat)
          and (:cityId is null or s.city.id = :cityId)
    """)
    Page<Spot> search(@Param("keyword") String keyword,
                      @Param("cat") String catCode,
                      @Param("cityId") Long cityId,
                      Pageable pageable);

    @Query("""
        select s from Spot s
        left join fetch s.city
        where s.id = :id
    """)
    java.util.Optional<Spot> findDetail(@Param("id") Long id);
}
