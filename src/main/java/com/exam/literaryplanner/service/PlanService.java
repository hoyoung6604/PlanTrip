package com.exam.literaryplanner.service;

import java.time.LocalDate;
import java.util.List;

import com.exam.literaryplanner.domain.TravelPlan;

public interface PlanService {

	Integer createPlan(String city, Integer mIdx, List<String> purposes, LocalDate start, LocalDate end);

    TravelPlan getPlan(Integer planId);
    
    
}