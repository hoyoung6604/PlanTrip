package com.exam.literaryplanner.repository;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MapPoint {
    private double lat;
    private double lng;
    private String name;
    private int day;
    private int seq;
}