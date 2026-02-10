package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.City;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CityRepository extends JpaRepository<City, Integer> {
    // 기본적으로 findAll(), findById() 등을 제공하므로 추가 코드가 없어도 작동합니다.
}