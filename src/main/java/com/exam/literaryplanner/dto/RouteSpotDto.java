package com.exam.literaryplanner.dto;

//com.exam.literaryplanner.dto.RouteSpotDto
public class RouteSpotDto {
 private Integer sIdx;
 private String sName;
 private double lat;
 private double lng;

 public RouteSpotDto(Integer sIdx, String sName, double lat, double lng) {
     this.sIdx = sIdx;
     this.sName = sName;
     this.lat = lat;
     this.lng = lng;
 }

 public Integer getsIdx() { return sIdx; }
 public String getsName() { return sName; }
 public double getLat() { return lat; }
 public double getLng() { return lng; }
}