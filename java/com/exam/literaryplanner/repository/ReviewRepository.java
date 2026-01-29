package com.exam.literaryplanner.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.exam.literaryplanner.domain.Review;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Integer> {
	
    List<Review> findAllByOrderByRvIdxDesc();

    List<Review> findByMemberIdOrderByRvIdxDesc(String memberId);
    
    List<Review> findByMemberId(String memberId);
}


