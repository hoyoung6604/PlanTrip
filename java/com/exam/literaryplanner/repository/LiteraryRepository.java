package com.exam.literaryplanner.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.exam.literaryplanner.domain.Member;

@Repository
public interface LiteraryRepository extends JpaRepository<Member, String> {
  // Spring Data JPA는 메서드 이름으로 쿼리를 자동 생성합니다.
    // 필요시 여기에 추가적인 커스텀 메서드를 정의할 수 있습니다.
    // 예: Member findByName(String name);
	
	// 아이디로 회원 찾기
    Optional<Member> findById(String id);
    
    Optional<Member> findByEmailAddress(String email_address);
    // 기본적으로 deleteById() 메서드가 제공됩니다.
}
