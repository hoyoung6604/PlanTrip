package com.exam.literaryplanner.service;

import com.exam.literaryplanner.domain.WishList;
import com.exam.literaryplanner.repository.WishListRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class WishListService {

    private final WishListRepository wishListRepository;

    /**
     * 찜 토글 로직
     * @return true: 찜 추가됨, false: 찜 해제됨
     */
    @Transactional
    public boolean toggleWish(Integer mIdx, Integer sIdx) {
        // 1. 이미 찜했는지 확인
        Optional<WishList> wishOpt = wishListRepository.findByMIdxAndSIdx(mIdx, sIdx);

        if (wishOpt.isPresent()) {
            // 2. 이미 있다면 삭제 (찜 해제)
            wishListRepository.delete(wishOpt.get());
            return false; 
        } else {
            // 3. 없다면 저장 (찜 추가)
            WishList wish = new WishList(mIdx, sIdx);
            wishListRepository.save(wish);
            return true;
        }
    }

    /**
     * 특정 사용자가 해당 장소를 찜했는지 여부 확인
     */
    @Transactional(readOnly = true)
    public boolean isHearted(Integer mIdx, Integer sIdx) {
        if (mIdx == null) return false;
        return wishListRepository.existsByMIdxAndSIdx(mIdx, sIdx);
    }
}