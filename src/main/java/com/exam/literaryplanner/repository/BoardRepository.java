package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.Board;
import com.exam.literaryplanner.domain.Qna;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BoardRepository extends JpaRepository<Board, Long> {
	@Query("select b from Board b where b.bType = :bType order by b.bIsTop desc, b.bIdx desc")
    List<Board> findByTypeSorted(@Param("bType") String bType);
}
