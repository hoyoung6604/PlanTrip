package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.WishList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

public interface WishListRepository extends JpaRepository<WishList, Integer> {
    
    // 1. 조회 (이름 규칙 에러 방지를 위해 @Query 사용)
    @Query("SELECT w FROM WishList w WHERE w.mIdx = :mIdx AND w.sIdx = :sIdx")
    Optional<WishList> findByMIdxAndSIdx(@Param("mIdx") Integer mIdx, @Param("sIdx") Integer sIdx);
    
    // 2. 존재 여부 확인
    @Query("SELECT COUNT(w) > 0 FROM WishList w WHERE w.mIdx = :mIdx AND w.sIdx = :sIdx")
    boolean existsByMIdxAndSIdx(@Param("mIdx") Integer mIdx, @Param("sIdx") Integer sIdx);

    // 3. 삭제 (삭제 쿼리는 @Modifying과 @Transactional이 필요합니다)
    @Modifying
    @Transactional
    @Query("DELETE FROM WishList w WHERE w.mIdx = :mIdx AND w.sIdx = :sIdx")
    void deleteByMIdxAndSIdx(@Param("mIdx") Integer mIdx, @Param("sIdx") Integer sIdx);
}