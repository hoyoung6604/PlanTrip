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

        return literaryRepository.findById(id)
                .filter(m -> m.getPassword() != null && m.getPassword().equals(password));
    }

    public void register(Member member) {
        if (member == null) throw new IllegalArgumentException("회원 정보가 비어 있습니다.");

        if (member.getId() == null || member.getId().isBlank()) {
            throw new IllegalArgumentException("아이디를 입력해 주세요.");
        }
        if (member.getPassword() == null || member.getPassword().isBlank()) {
            throw new IllegalArgumentException("비밀번호를 입력해 주세요.");
        }
        if (member.getName() == null || member.getName().isBlank()) {
            throw new IllegalArgumentException("이름을 입력해 주세요.");
        }
        if (member.getEmailAddress() == null || member.getEmailAddress().isBlank()) {
            throw new IllegalArgumentException("이메일을 입력해 주세요.");
        }

        if (literaryRepository.existsById(member.getId())) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }

        // 이메일 중복 체크가 필요하면 아래 주석 해제
        // if (literaryRepository.findByEmailAddress(member.getEmailAddress()).isPresent()) {
        //     throw new IllegalArgumentException("이미 가입된 이메일입니다.");
        // }

        literaryRepository.save(member);
    }
}
