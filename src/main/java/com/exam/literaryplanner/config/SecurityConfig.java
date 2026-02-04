package com.exam.literaryplanner.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain filterChain(HttpSecurity http,
    		OAuth2LoginSuccessHandler successHandler) throws Exception {
        http
            // 너는 기존 세션 로그인/컨트롤러를 쓰고 있으니 일단 전부 열어둠
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/", "/css/**", "/js/**", "/images/**",
                    "/members/**",
                    "/oauth2/**", "/login/oauth2/**"
                ).permitAll()
                .anyRequest().permitAll()
            )

            // ✅ 이게 있어야 /oauth2/authorization/google 이 살아남
            .oauth2Login(o -> o.successHandler(successHandler))

            // (선택) 기본 로그인폼/Basic 끄기
            .formLogin(form -> form.disable())
            .httpBasic(basic -> basic.disable());

        return http.build();
    }
}
