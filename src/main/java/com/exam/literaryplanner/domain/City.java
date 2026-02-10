package com.exam.literaryplanner.domain;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "cityT")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class City {

    @Id
    @Column(name = "c_idx")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "c_area_code", nullable = false, unique = true, length = 40)
    private String areaCode;

    @Column(name = "c_name", nullable = false, length = 100)
    private String name;

    @Column(name = "c_lat", precision = 15, scale = 10)
    private BigDecimal lat;

    @Column(name = "c_lng", precision = 15, scale = 10)
    private BigDecimal lng;
}
