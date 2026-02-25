package com.exam.literaryplanner.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor  // 🔥 이거 핵심 (생성자 자동 생성)
public class SpotPickDto {

    private Integer id;
    private String name;
    private String catCode;

//    public SpotPickDto(Integer id, String name, String catCode) {
//        this.id = id;
//        this.name = name;
//        this.catCode = catCode;
//    }

//    public SpotPickDto() {}
}