package com.exam.literaryplanner.domain;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table(name = "travelPlanT")
public class TravelPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "tp_idx", nullable = false)
    private Integer tpIdx;

    @Column(name = "m_idx", nullable = false)
    private Integer mIdx;

    @Column(name = "tp_title", nullable = false, length = 200)
    private String tpTitle;

    @Column(name = "tp_start_date", length = 20)
    private String tpStartDate;

    @Column(name = "tp_end_date", length = 20)
    private String tpEndDate;

    // ✅ 6가지 입력 + 권역 + 안전장치 등을 요약 텍스트로 저장
    @Lob
    @Column(name = "tp_meta", columnDefinition = "TEXT")
    private String tpMeta;

    @Column(name = "tp_created_at", nullable = false)
    private LocalDateTime tpCreatedAt = LocalDateTime.now();

    public TravelPlan() {}

    public Integer getTpIdx() { return tpIdx; }
    public void setTpIdx(Integer tpIdx) { this.tpIdx = tpIdx; }

    public Integer getMIdx() { return mIdx; }
    public void setMIdx(Integer mIdx) { this.mIdx = mIdx; }

    public String getTpTitle() { return tpTitle; }
    public void setTpTitle(String tpTitle) { this.tpTitle = tpTitle; }

    public String getTpStartDate() { return tpStartDate; }
    public void setTpStartDate(String tpStartDate) { this.tpStartDate = tpStartDate; }

    public String getTpEndDate() { return tpEndDate; }
    public void setTpEndDate(String tpEndDate) { this.tpEndDate = tpEndDate; }

    public String getTpMeta() { return tpMeta; }
    public void setTpMeta(String tpMeta) { this.tpMeta = tpMeta; }

    public LocalDateTime getTpCreatedAt() { return tpCreatedAt; }
    public void setTpCreatedAt(LocalDateTime tpCreatedAt) { this.tpCreatedAt = tpCreatedAt; }
}
