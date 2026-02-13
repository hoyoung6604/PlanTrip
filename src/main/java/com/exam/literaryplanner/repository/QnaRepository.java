package com.exam.literaryplanner.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.exam.literaryplanner.domain.Qna;

public interface QnaRepository extends JpaRepository<Qna, Integer> {

	@Query("select q from Qna q where q.member.id = :memberId order by q.qRegDate desc")
	List<Qna> findQnaByMemberId(@Param("memberId") Integer memberId);

	@Query("select count(q) from Qna q where q.qStatus = :status")
	int countPendingByStatus(@Param("status") Integer status);

}
