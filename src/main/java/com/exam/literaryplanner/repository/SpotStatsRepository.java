package com.exam.literaryplanner.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.exam.literaryplanner.domain.SpotStats;

public interface SpotStatsRepository extends JpaRepository<SpotStats, Integer> {}
