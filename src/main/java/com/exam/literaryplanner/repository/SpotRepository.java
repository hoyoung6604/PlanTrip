package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.Spot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SpotRepository extends JpaRepository<Spot, Integer> {
    
    // 카테고리 코드(FOOD, STAY 등)로 장소 리스트를 찾는 메서드 추가
    List<Spot> findByCatCode(String catCode);
}