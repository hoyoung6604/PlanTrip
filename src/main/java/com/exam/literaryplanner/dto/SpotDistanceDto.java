package com.exam.literaryplanner.dto;

public class SpotDistanceDto {

    private Integer sIdx;
    private String sName;
    private Double sLat;
    private Double sLng;
    private Double distance;

    public SpotDistanceDto(Integer sIdx, String sName, Double sLat, Double sLng, Double distance) {
        this.sIdx = sIdx;
        this.sName = sName;
        this.sLat = sLat;
        this.sLng = sLng;
        this.distance = distance;
    }

    public Integer getsIdx() { return sIdx; }
    public String getsName() { return sName; }
    public Double getsLat() { return sLat; }
    public Double getsLng() { return sLng; }
    public Double getDistance() { return distance; }
}