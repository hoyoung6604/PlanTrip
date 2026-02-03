package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.Qna;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface QnaRepository extends JpaRepository<Qna, Long> {

	@Query("select q from Qna q where q.member.id = :memberId order by q.qRegDate desc")
	List<Qna> findQnaByMemberId(@Param("memberId") Long memberId);

	@Query("select count(q) from Qna q where q.qStatus = :status")
	long countPendingByStatus(@Param("status") Integer status);

}
