package com.exam.literaryplanner;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
//JPA Repository 스캔 경로 명시
//@EnableJpaRepositories(basePackages = "com.exam.literaryplanner.repository") 
////JPA Repository 스캔 경로 명시
//@ComponentScan(basePackages = {"com.exam.literaryplanner.controller", 
//"com.exam.literaryplanner.service"})
public class LiteraryplannerApplication {

	public static void main(String[] args) {
		SpringApplication.run(LiteraryplannerApplication.class, args);
	}

}
