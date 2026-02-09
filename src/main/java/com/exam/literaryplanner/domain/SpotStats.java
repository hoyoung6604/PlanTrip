package com.exam.literaryplanner.domain;

import jakarta.persistence.*;
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
    private Long id;

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

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Spot getSpot() {
		return spot;
	}

	public void setSpot(Spot spot) {
		this.spot = spot;
	}

	public int getViewCount() {
		return viewCount;
	}

	public void setViewCount(int viewCount) {
		this.viewCount = viewCount;
	}

	public int getWishCount() {
		return wishCount;
	}

	public void setWishCount(int wishCount) {
		this.wishCount = wishCount;
	}

	public BigDecimal getRatingAvg() {
		return ratingAvg;
	}

	public void setRatingAvg(BigDecimal ratingAvg) {
		this.ratingAvg = ratingAvg;
	}

	public int getRatingCount() {
		return ratingCount;
	}

	public void setRatingCount(int ratingCount) {
		this.ratingCount = ratingCount;
	}
}
