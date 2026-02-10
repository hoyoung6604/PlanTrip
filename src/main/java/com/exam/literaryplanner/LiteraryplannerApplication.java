package com.exam.literaryplanner;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
// 1. Repository 스캔 경로 설정 (기본적으로 루트 패키지 하위는 자동 스캔되지만 명시해 두어도 좋습니다)
@EnableJpaRepositories(basePackages = "com.exam.literaryplanner.repository")
// 2. 컨트롤러, 서비스 등 빈 스캔 설정
@ComponentScan(basePackages = "com.exam.literaryplanner")
public class LiteraryplannerApplication {

    // ✅ main 메서드는 클래스 내부에 딱 하나만 존재해야 합니다.
    public static void main(String[] args) {
        SpringApplication.run(LiteraryplannerApplication.class, args);
    }

    // ✅ BCrypt PasswordEncoder Bean 등록 (보안 기능을 위해 프론트 팀원이 추가한 설정입니다)
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}