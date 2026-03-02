package com.exam.literaryplanner.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.exam.literaryplanner.domain.Spot;
import com.exam.literaryplanner.dto.RouteSpotDto;
import com.exam.literaryplanner.repository.SpotRepository;

import lombok.RequiredArgsConstructor;

//com.exam.literaryplanner.service.RouteService
@Service
@RequiredArgsConstructor
public class RouteService {

 private final SpotRepository spotRepository;

// public RouteService(SpotRepository spotRepository) {
//	 this.spotRepository = spotRepository;
// }

 public List<RouteSpotDto> getRouteSpotsInOrder(List<Integer> spotIds) {
     if (spotIds == null || spotIds.isEmpty()) {
		return List.of();
	 }

     // 한번에 조회
     List<Spot> spots = spotRepository.findAllById(spotIds);

     // id -> Spot 매핑
     Map<Integer, Spot> map = new HashMap<>();
     for (Spot s : spots) {
		map.put(s.getId(), s);
	 }

     // 요청한 순서대로 DTO 구성 (없는 id는 제외)
     List<RouteSpotDto> result = new ArrayList<>();
     for (Integer id : spotIds) {
         Spot s = map.get(id);
         if ((s == null) || s.getLat() == null || s.getLng() == null) {
			continue;
		 }

         result.add(new RouteSpotDto(
                 s.getId(),
                 s.getName(),
                 s.getLat(),
                 s.getLng()
         ));
     }
     return result;
 }
}