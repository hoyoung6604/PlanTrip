package com.exam.literaryplanner.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.exam.literaryplanner.domain.TravelPlan;

@Repository
public interface TravelPlanRepository extends JpaRepository<TravelPlan, Integer> {
}