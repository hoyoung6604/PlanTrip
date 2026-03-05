package com.exam.literaryplanner.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

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

    // ✅ JSP EL/Projection 호환용(TravelPlanViewRow는 getpIdx() 형태라서, JSP에서 ${plan.pIdx}를 그대로 쓰기 위해 추가)
    public Integer getpIdx() { return getPIdx(); }
    public void setpIdx(Integer pIdx) { setPIdx(pIdx); }

    public Integer getmIdx() { return getMIdx(); }
    public void setmIdx(Integer mIdx) { setMIdx(mIdx); }

    public String getpTitle() { return getPTitle(); }
    public void setpTitle(String pTitle) { setPTitle(pTitle); }

    public java.time.LocalDate getpStart() { return getPStart(); }
    public void setpStart(java.time.LocalDate pStart) { setPStart(pStart); }

    public java.time.LocalDate getpEnd() { return getPEnd(); }
    public void setpEnd(java.time.LocalDate pEnd) { setPEnd(pEnd); }



}