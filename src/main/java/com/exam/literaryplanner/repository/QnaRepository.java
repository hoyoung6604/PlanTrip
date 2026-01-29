package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.Qna;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface QnaRepository extends JpaRepository<Qna, Long> {

    @Query("select q from Qna q where q.member.mIdx = :mIdx order by q.qIdx desc")
    List<Qna> findMyQna(@Param("mIdx") Long mIdx);
}
