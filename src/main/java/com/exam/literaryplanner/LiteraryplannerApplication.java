package com.exam.literaryplanner;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication

// Repository 스캔 (지금처럼 명시해도 되고, 생략해도 보통 자동 스캔됩니다)
@EnableJpaRepositories(basePackages = "com.exam.literaryplanner.repository")

// ✅ 루트 패키지 전체 스캔 (controller/service/config 등 전부 포함)
@ComponentScan(basePackages = "com.exam.literaryplanner")
public class LiteraryplannerApplication {

<<<<<<< HEAD
	public static void main(String[] args) {
		SpringApplication.run(LiteraryplannerApplication.class, args);
	}
//	21131212
	//aaaaaaaaaaaa
=======
    // ✅ BCrypt PasswordEncoder Bean 등록 (starter-security 없이 crypto만 써도 OK)
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    public static void main(String[] args) {
        SpringApplication.run(LiteraryplannerApplication.class, args);
    }
>>>>>>> origin/frontend
}
