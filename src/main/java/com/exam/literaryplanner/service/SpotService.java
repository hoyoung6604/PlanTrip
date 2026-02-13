package com.exam.literaryplanner.service;

import com.exam.literaryplanner.domain.*;
import com.exam.literaryplanner.repository.*;
import lombok.RequiredArgsConstructor;

import java.math.BigDecimal;

import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SpotService {

	private final SpotRepository spotRepository;
	private final SpotStatsRepository spotStatsRepository;
	
	public Spot findById(Integer id) {
        return spotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 장소가 존재하지 않습니다. id=" + id));
    }

	@Transactional(readOnly = true)
	public Page<Spot> list(String keyword, String catCode, Integer cityId, int page, int size) {
		Pageable pageable = PageRequest.of(page, size, Sort.by("id").descending());
		return spotRepository.search(keyword, catCode, cityId, pageable);
	}

	@Transactional
	public Spot detailAndIncreaseView(Integer id) {
		Spot spot = spotRepository.findDetail(id)
				.orElseThrow(() -> new IllegalArgumentException("존재하지 않는 장소입니다. s_idx=" + id));

		SpotStats stats = spot.getStats();

		if (stats == null) {
			stats = new SpotStats();
			stats.setId(spot.getId()); // Spot 도메인의 sIdx를 id로 바꿨으므로 getId() 사용
			stats.setSpot(spot);
			stats.setViewCount(0);
			stats.setWishCount(0);
			stats.setRatingCount(0);
			stats.setRatingAvg(BigDecimal.ZERO);
		}

		stats.setViewCount(stats.getViewCount() + 1);
		spotStatsRepository.save(stats);

		return spot;
	}
}
