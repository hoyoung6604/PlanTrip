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
    
    public SpotService(SpotRepository spotRepository,
            SpotStatsRepository spotStatsRepository) {
    			this.spotRepository = spotRepository;
    			this.spotStatsRepository = spotStatsRepository;
    }

    @Transactional(readOnly = true)
    public Page<Spot> list(String keyword, String catCode, Long cityId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("id").descending());
        return spotRepository.search(keyword, catCode, cityId, pageable);
    }

    @Transactional
    public Spot detailAndIncreaseView(Long id) {
        Spot spot = spotRepository.findDetail(id)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 장소입니다. s_idx=" + id));

        SpotStats stats = spot.getStats();
        if (stats == null) {
        	stats = new SpotStats();
        	stats.setId(spot.getId());
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
