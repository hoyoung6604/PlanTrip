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

    public LiteraryService(LiteraryRepository literaryRepository) {
        this.literaryRepository = literaryRepository;
    }

    public Optional<Member> login(String id, String password) {
        if (id == null || id.isBlank() || password == null) return Optional.empty();

        return literaryRepository.findByMId(id)
                .filter(m -> m.getMPw() != null && m.getMPw().equals(password));
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

        // 이메일 중복 체크 필요하면 사용
        // if (literaryRepository.findByMEmail(member.getMEmail()).isPresent()) {
        //     throw new IllegalArgumentException("이미 가입된 이메일입니다.");
        // }

        if (member.getMRole() == null) {
            member.setMRole(1);
        }

        
        literaryRepository.save(member);
    }
}

