package com.exam.literaryplanner.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.exam.literaryplanner.domain.City;
import com.exam.literaryplanner.repository.CityRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CityService {

    private final CityRepository cityRepository;

//    public CityService(CityRepository cityRepository) {
//    	this.cityRepository = cityRepository;
//    }

    public List<City> getCities() {
        return cityRepository.findAllByOrderByNameAsc();
    }
}