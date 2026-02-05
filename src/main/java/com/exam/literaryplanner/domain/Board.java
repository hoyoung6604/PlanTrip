package com.exam.literaryplanner.domain;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "boardT")
public class Board {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "b_idx", nullable = false)
    private Long bIdx;   // 게시글 PK

    // NOTICE / FAQ
    @Column(name = "b_type", nullable = false, length = 10)
    private String bType;

    @Column(name = "b_title", nullable = false, length = 200)
    private String bTitle;

    @Lob
    @Column(name = "b_cont", nullable = false)
    private String bCont;

    // 상단 고정 (0/1)
    @Column(name = "b_is_top", nullable = false)
    private Integer bIsTop = 0;

    // DB DEFAULT CURRENT_TIMESTAMP 사용
    @Column(name = "b_regDate", nullable = false, insertable = false, updatable = false)
    private LocalDateTime bRegDate;

    // ===== 선택 확장 =====
    // 만약 boardT에 m_idx 추가했다면 아래 활성화
    /*
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="m_idx")
    private Member member;
    */

    public Board() {}

    // --- getters/setters ---

    public Long getBIdx() {
        return bIdx;
    }

    public void setBIdx(Long bIdx) {
        this.bIdx = bIdx;
    }

    public String getBType() {
        return bType;
    }

    public void setBType(String bType) {
        this.bType = bType;
    }

    public String getBTitle() {
        return bTitle;
    }

    public void setBTitle(String bTitle) {
        this.bTitle = bTitle;
    }

    public String getBCont() {
        return bCont;
    }

    public void setBCont(String bCont) {
        this.bCont = bCont;
    }

    public Integer getBIsTop() {
        return bIsTop;
    }

    public void setBIsTop(Integer bIsTop) {
        this.bIsTop = bIsTop;
    }

    public LocalDateTime getBRegDate() {
        return bRegDate;
    }

    public void setBRegDate(LocalDateTime bRegDate) {
        this.bRegDate = bRegDate;
    }

    /*
    public Member getMember() {
        return member;
    }

    public void setMember(Member member) {
        this.member = member;
    }
    */
}
