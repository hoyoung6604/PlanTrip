package com.exam.literaryplanner.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.exam.literaryplanner.domain.City;

@Repository
public interface CityRepository extends JpaRepository<City, Integer> {

    // ✅ 첫 도시 1개(그대로 두면 됨)
    Optional<City> findFirstByOrderByIdAsc();

    // ✅ 정렬 기준은 엔티티 필드명(name)
    List<City> findAllByOrderByNameAsc();
}