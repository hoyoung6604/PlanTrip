package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LiteraryRepository extends JpaRepository<Member, Long> {

    // 로그인 ID로 찾기 (m_id)
    @Query("SELECT m FROM Member m WHERE m.mId = :mId")
    Optional<Member> findByMId(@Param("mId") String mId);

    // 이메일로 찾기 (m_email)
    @Query("SELECT m FROM Member m WHERE m.mEmail = :mEmail")
    Optional<Member> findByMEmail(@Param("mEmail") String mEmail);

    // ID 중복 체크
    @Query("SELECT CASE WHEN COUNT(m) > 0 THEN true ELSE false END FROM Member m WHERE m.mId = :mId")
    boolean existsByMId(@Param("mId") String mId);
}
