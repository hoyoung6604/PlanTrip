package com.exam.literaryplanner.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "spotT") // DB의 spotT 테이블과 매칭
@Getter @Setter
public class Spot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "s_idx")
    private Integer sIdx;      // 장소 고유 번호

    @Column(name = "c_idx")
    private Integer cIdx;      // 도시 번호 (FK)

    @Column(name = "cat_code")
    private String catCode;    // 카테고리 코드 (FOOD, STAY, TOUR, ACT)

    @Column(name = "s_name")
    private String sName;      // 장소 이름

    @Column(name = "s_addr")
    private String sAddr;      // 장소 주소

    @Column(name = "s_lat")
    private Double sLat;       // 위도

    @Column(name = "s_lng")
    private Double sLng;       // 경도

    @Column(name = "s_hours")
    private String sHours;     // 영업 시간

    @Column(name = "s_holiday")
    private String sHoliday;   // 휴무일

    @Column(name = "s_price")
    private String sPrice;     // 별점/평점 (엑셀 데이터 기반)

    @Column(name = "s_info")
    private String sInfo;      // 특징 및 정보
}
