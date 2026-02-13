package com.exam.literaryplanner.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.exam.literaryplanner.domain.Member;

@Repository
public interface LiteraryRepository extends JpaRepository<Member, Integer> {

    // 1. 로그인 ID로 찾기 (m_id)
    @Query("SELECT m FROM Member m WHERE m.mId = :mId")
    Optional<Member> findByMId(@Param("mId") String mId);

    // 2. 이메일로 찾기 (m_email)
    @Query("SELECT m FROM Member m WHERE m.mEmail = :mEmail")
    Optional<Member> findByMEmail(@Param("mEmail") String mEmail);

    // 3. ID 중복 체크
    @Query("SELECT CASE WHEN COUNT(m) > 0 THEN true ELSE false END FROM Member m WHERE m.mId = :mId")
    boolean existsByMId(@Param("mId") String mId);

    // 4. 이메일 중복 체크 (추가됨)
    @Query("select count(m) > 0 from Member m where m.mEmail = :email")
    boolean existsByEmail(@Param("email") String email);

    // 5. 가입일 순 정렬 (추가됨)
    @Query("select m from Member m order by m.mRegDate desc")
    List<Member> findAllOrderByRegDateDesc();

    // 6. 회원 검색 (ID, 이름, 이메일) (추가됨)
    @Query("""
    		select m
    		from Member m
    		where lower(m.mId) like lower(concat('%', :kw, '%'))
    		   or lower(m.mName) like lower(concat('%', :kw, '%'))
    		   or lower(m.mEmail) like lower(concat('%', :kw, '%'))
    		order by m.mRegDate desc
    		""")
    List<Member> searchMembers(@Param("kw") String kw);

    // 7. 전체 회원 수 카운트 (추가됨)
    @Query("select count(m) from Member m")
    int countMembers();

    // 8. 네이티브 쿼리를 이용한 회원 삭제 (추가됨)
    @Modifying
    @Transactional
    @Query(value = "DELETE FROM memberT WHERE m_idx = ?1", nativeQuery = true)
    int deleteMemberNative(Integer mIdx);

    // 9. 소셜 로그인 연동 (SNS ID로 찾기) (추가됨)
    Optional<Member> findBySnsId(String snsId);
}