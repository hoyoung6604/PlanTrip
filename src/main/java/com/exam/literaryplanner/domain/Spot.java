package com.exam.literaryplanner.domain;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "spotT")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Spot {

    @Id
    @Column(name = "s_idx")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // spotT.c_idx -> cityT.c_idx (nullable)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "c_idx")
    private City city;

    @Column(name = "cat_code", nullable = false, length = 20)
    private String catCode;

    @Column(name = "s_name", nullable = false, length = 200)
    private String name;

    @Column(name = "s_addr", length = 500)
    private String addr;

    @Column(name = "s_lat", precision = 15, scale = 10)
    private BigDecimal lat;

    @Column(name = "s_lng", precision = 15, scale = 10)
    private BigDecimal lng;

    @Column(name = "s_hours", length = 255)
    private String hours;

    @Column(name = "s_holiday", length = 255)
    private String holiday;

    @Column(name = "s_price", length = 255)
    private String price;

    @Column(name = "s_info", length = 1000)
    private String info;

    // spotStatsT 1:1
    @OneToOne(mappedBy = "spot", fetch = FetchType.LAZY, optional = true)
    private SpotStats stats;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public City getCity() {
		return city;
	}

	public void setCity(City city) {
		this.city = city;
	}

	public String getCatCode() {
		return catCode;
	}

	public void setCatCode(String catCode) {
		this.catCode = catCode;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getAddr() {
		return addr;
	}

	public void setAddr(String addr) {
		this.addr = addr;
	}

	public BigDecimal getLat() {
		return lat;
	}

	public void setLat(BigDecimal lat) {
		this.lat = lat;
	}

	public BigDecimal getLng() {
		return lng;
	}

	public void setLng(BigDecimal lng) {
		this.lng = lng;
	}

	public String getHours() {
		return hours;
	}

	public void setHours(String hours) {
		this.hours = hours;
	}

	public String getHoliday() {
		return holiday;
	}

	public void setHoliday(String holiday) {
		this.holiday = holiday;
	}

	public String getPrice() {
		return price;
	}

	public void setPrice(String price) {
		this.price = price;
	}

	public String getInfo() {
		return info;
	}

	public void setInfo(String info) {
		this.info = info;
	}

	public SpotStats getStats() {
		return stats;
	}

	public void setStats(SpotStats stats) {
		this.stats = stats;
	}
}
