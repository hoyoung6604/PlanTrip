package com.exam.literaryplanner.repository;

import java.time.LocalDate;
import java.time.LocalDateTime;

public interface TravelPlanViewRow {
    Integer getpIdx();
    Integer getmIdx();
    String getpTitle();
    LocalDate getpStart();
    LocalDate getpEnd();
    String getTpTitle();
    LocalDateTime getpRegDate();
}