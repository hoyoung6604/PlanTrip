package com.exam.literaryplanner.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.*;
import java.math.BigDecimal;

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