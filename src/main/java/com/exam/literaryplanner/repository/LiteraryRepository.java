package com.exam.literaryplanner.repository;

import com.exam.literaryplanner.domain.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
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
    
    @Query("select count(m) > 0 from Member m where m.mEmail = :email")
    boolean existsByEmail(@Param("email") String email);
    
    @Query("select m from Member m order by m.mRegDate desc")
    List<Member> findAllOrderByRegDateDesc();
    
    @Query("""
    		select m
    		from Member m
    		where lower(m.mId) like lower(concat('%', :kw, '%'))
    		   or lower(m.mName) like lower(concat('%', :kw, '%'))
    		   or lower(m.mEmail) like lower(concat('%', :kw, '%'))
    		order by m.mRegDate desc
    		""")
    		List<Member> searchMembers(@Param("kw") String kw);
    
    // ✅ 회원 수 카운트
    @Query("select count(m) from Member m")
    long countMembers();
    
}
