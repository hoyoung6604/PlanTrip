package com.exam.literaryplanner.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "travelPlanT")
public class TravelPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "p_idx", nullable = false)
    private Integer pIdx;

    @Column(name = "m_idx", nullable = false)
    private Integer mIdx;

    @Column(name = "p_title", nullable = false, length = 200)
    private String pTitle;

    @Column(name = "p_start", nullable = false)
    private LocalDate pStart;

    @Column(name = "p_end", nullable = false)
    private LocalDate pEnd;

    @Column(name = "p_regDate", nullable = false, insertable = false, updatable = false)
    private LocalDateTime pRegDate;
    
    @Column(name = "tp_title", nullable = false, length = 200)
    private String tpTitle;

    public TravelPlan() {}
    
    public String getTpTitle() { return tpTitle; }
    public void setTpTitle(String tpTitle) { this.tpTitle = tpTitle; }

    public Integer getPIdx() { return pIdx; }
    public void setPIdx(Integer pIdx) { this.pIdx = pIdx; }

    public Integer getMIdx() { return mIdx; }
    public void setMIdx(Integer mIdx) { this.mIdx = mIdx; }

    public String getPTitle() { return pTitle; }
    public void setPTitle(String pTitle) { this.pTitle = pTitle; }

    public LocalDate getPStart() { return pStart; }
    public void setPStart(LocalDate pStart) { this.pStart = pStart; }

    public LocalDate getPEnd() { return pEnd; }
    public void setPEnd(LocalDate pEnd) { this.pEnd = pEnd; }

    public LocalDateTime getPRegDate() { return pRegDate; }
}