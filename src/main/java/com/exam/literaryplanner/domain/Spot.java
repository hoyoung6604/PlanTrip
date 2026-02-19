package com.exam.literaryplanner.domain;

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
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


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

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
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

	public Double getLat() {
		return lat;
	}

	public void setLat(Double lat) {
		this.lat = lat;
	}

	public Double getLng() {
		return lng;
	}

	public void setLng(Double lng) {
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

	public City getCity() {
		return city;
	}

	public void setCity(City city) {
		this.city = city;
	}

}
