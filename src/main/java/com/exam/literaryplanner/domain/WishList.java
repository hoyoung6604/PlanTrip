package com.exam.literaryplanner.domain;

import java.time.LocalDateTime;
import org.hibernate.annotations.CreationTimestamp;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "wishListT")
@Getter @Setter
@NoArgsConstructor // 파라미터가 없는 기본 생성자 자동 생성 (public WishList() {})
public class WishList {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "w_idx")
    private Integer wIdx;

    @Column(name = "m_idx", nullable = false)
    private Integer mIdx;

    @Column(name = "s_idx", nullable = false)
    private Integer sIdx;

    @CreationTimestamp
    @Column(name = "w_date", updatable = false)
    private LocalDateTime wDate;

    // 특정 정보를 넣어서 바로 만들고 싶을 때 사용하는 생성자만 남겨두면 좋습니다.
    public WishList(Integer mIdx, Integer sIdx) {
        this.mIdx = mIdx;
        this.sIdx = sIdx;
    }
}