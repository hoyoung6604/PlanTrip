package com.exam.literaryplanner.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new AdminInterceptor())
                .addPathPatterns("/admin/**");
    }

    // ✅ 외부 업로드 폴더를 정적 리소스로 매핑 (/upload/**)
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String uploadDir = System.getProperty("user.dir") + "/upload/";
        registry.addResourceHandler("/upload/**")
                .addResourceLocations("file:" + uploadDir);
    }
}
