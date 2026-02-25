package com.exam.literaryplanner.domain;

import java.math.BigDecimal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "spotStatsT")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class SpotStats {

    @Id
    @Column(name = "s_idx")
    private Integer id;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "s_idx")
    @JsonIgnore
    private Spot spot;

    @Column(name = "v_count", nullable = false)
    private int viewCount;

    @Column(name = "w_count", nullable = false)
    private int wishCount;

    @Column(name = "r_avg", nullable = false, precision = 3, scale = 2)
    private BigDecimal ratingAvg;

    @Column(name = "r_count", nullable = false)
    private int ratingCount;




}