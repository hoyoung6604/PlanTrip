package com.exam.literaryplanner.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table(name = "planDetailT")
public class PlanDetail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "pd_idx", nullable = false)
    private Integer pdIdx;

    @Column(name = "tp_idx", nullable = false)
    private Integer tpIdx; // TravelPlan FK 역할(숫자로만)

    @Column(name = "day_no", nullable = false)
    private Integer dayNo; // 1일차, 2일차...

    @Column(name = "order_no", nullable = false)
    private Integer orderNo; // 그날 순서

    @Column(name = "s_idx")
    private Integer sIdx; // Spot FK 역할 (없으면 null 가능)

    @Lob
    @Column(name = "memo", columnDefinition = "TEXT")
    private String memo;

    public PlanDetail() {}

    // ===== getters / setters =====

    public Integer getPdIdx() {
        return pdIdx;
    }

    public void setPdIdx(Integer pdIdx) {
        this.pdIdx = pdIdx;
    }

    public Integer getTpIdx() {
        return tpIdx;
    }

    public void setTpIdx(Integer tpIdx) {
        this.tpIdx = tpIdx;
    }

    public Integer getDayNo() {
        return dayNo;
    }

    public void setDayNo(Integer dayNo) {
        this.dayNo = dayNo;
    }

    public Integer getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(Integer orderNo) {
        this.orderNo = orderNo;
    }

    public Integer getSIdx() {
        return sIdx;
    }

    public void setSIdx(Integer sIdx) {
        this.sIdx = sIdx;
    }

    public String getMemo() {
        return memo;
    }

    public void setMemo(String memo) {
        this.memo = memo;
    }
}
