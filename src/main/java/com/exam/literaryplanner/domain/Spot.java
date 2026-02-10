package com.exam.literaryplanner.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import lombok.*;


@Entity
@Table(name = "spotT")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Spot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "s_idx")
    private Integer id;      // 장소 고유 번호

    @Column(name = "cat_code", nullable = false)
    private String catCode;    // 카테고리 코드 (FOOD, STAY, TOUR, ACT)

    @Column(name = "s_name", nullable = false)
    private String name;      // 장소 이름

    @Column(name = "s_addr")
    private String addr;      // 장소 주소

    @Column(name = "s_lat")
    private Double lat;       // 위도

    @Column(name = "s_lng")
    private Double lng;       // 경도

    @Column(name = "s_hours")
    private String hours;     // 영업 시간

    @Column(name = "s_holiday")
    private String holiday;   // 휴무일

    @Column(name = "s_price")
    private String price;     // 별점/평점

    @Column(name = "s_info")
    private String info;      // 특징 및 정보

    @OneToOne(mappedBy = "spot", fetch = FetchType.LAZY)
    private SpotStats stats; // ✅ getStats() 자동 생성됨

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "c_idx")
    private City city;

}
