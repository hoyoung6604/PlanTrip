package com.exam.literaryplanner.service;

import com.exam.literaryplanner.domain.Member;
import com.exam.literaryplanner.repository.LiteraryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@Transactional
public class LiteraryService {

    private final LiteraryRepository literaryRepository;
    private final PasswordHasher passwordHasher;

    public LiteraryService(LiteraryRepository literaryRepository, PasswordHasher passwordHasher) {
        this.literaryRepository = literaryRepository;
        this.passwordHasher = passwordHasher;
    }

    public Optional<Member> login(String id, String password) {
        if (id == null || id.isBlank() || password == null) return Optional.empty();

        return literaryRepository.findByMId(id).filter(m -> {
            String saved = m.getMPw();
            if (saved == null || saved.isBlank()) return false;

            boolean looksHashed = saved.startsWith("$2a$") || saved.startsWith("$2b$") || saved.startsWith("$2y$");

            if (looksHashed) {
                // ✅ 해시 저장 계정
                return passwordHasher.matches(password, saved);
            } else {
                // ✅ 예전 평문 저장 계정
                boolean ok = saved.equals(password);
                if (ok) {
                    // 로그인 성공하면 해시로 자동 업그레이드
                    m.setMPw(passwordHasher.bcrypt(password));
                    literaryRepository.save(m);
                }
                return ok;
            }
        });
    }

    public void register(Member member) {
        if (member == null) throw new IllegalArgumentException("회원 정보가 비어 있습니다.");

        if (member.getMId() == null || member.getMId().isBlank()) {
            throw new IllegalArgumentException("아이디를 입력해 주세요.");
        }
        if (member.getMPw() == null || member.getMPw().isBlank()) {
            throw new IllegalArgumentException("비밀번호를 입력해 주세요.");
        }
        if (member.getMName() == null || member.getMName().isBlank()) {
            throw new IllegalArgumentException("이름을 입력해 주세요.");
        }
        if (member.getMEmail() == null || member.getMEmail().isBlank()) {
            throw new IllegalArgumentException("이메일을 입력해 주세요.");
        }

        if (literaryRepository.existsByMId(member.getMId())) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }

        // 이메일 중복 체크는 너가 @Query로 고친 메서드명에 맞춰 사용
        // 예: if (literaryRepository.existsByEmail(member.getMEmail())) ...
        // (existsByMEmail이 파싱 이슈 있었으니 @Query로 만든 메서드를 쓰는 걸 추천)
        // if (literaryRepository.existsByEmail(member.getMEmail())) {
        //     throw new IllegalArgumentException("이미 가입된 이메일입니다.");
        // }

        if (member.getMRole() == null) {
            member.setMRole(1);
        }

        // ✅ 저장 전 BCrypt로 암호화
        member.setMPw(passwordHasher.bcrypt(member.getMPw()));

        literaryRepository.save(member);
    }
    
}


