package com.exam.literaryplanner.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.exam.literaryplanner.domain.ReviewPhoto;

//Repository 추가
public interface ReviewPhotoRepository extends JpaRepository<ReviewPhoto, Integer> {
    List<ReviewPhoto> findByRvIdxOrderByRpIdxAsc(Integer long1);

	/*
	 * Optional<ReviewPhoto> findById(Integer rpIdx);
	 * 
	 * void deleteById(Integer rpIdx);
	 */}