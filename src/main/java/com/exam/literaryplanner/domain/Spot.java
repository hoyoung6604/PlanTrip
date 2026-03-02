package com.exam.literaryplanner.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;



@Entity
@Table(name = "spotT")
@Getter
@Setter
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

    @Column(name = "s_image")
    private String image;      // 사진정보

    @OneToOne(mappedBy = "spot", fetch = FetchType.LAZY)
    @JsonIgnore
    private SpotStats stats;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "c_idx")
    private City city;

    @Transient // JPA가 이 필드는 DB 컬럼과 매핑하지 않도록 무시하게 합니다.
    @Builder.Default
    private boolean isHearted = false;

    public boolean getIsHearted() {
        return this.isHearted;
    }

    public void setIsHearted(boolean isHearted) {
        this.isHearted = isHearted;
    }

}
