package com.exam.literaryplanner.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

@Entity
@Table(name = "reviewT")
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rv_idx", nullable = false)
    private Integer rvIdx; // BIGINT AI

    @Column(name = "s_idx", nullable = false)
    private Integer sIdx; // FK -> spotT(s_idx)
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "s_idx", insertable = false, updatable = false)
    private Spot spot;

    public Spot getSpot() { return spot; }

    @Column(name = "m_idx", nullable = false)
    private Integer mIdx; // FK -> memberT(m_idx)
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "m_idx", insertable = false, updatable = false)
    private Member member;

    public Member getMember() { return member; }
    
    @Column(name = "rv_star", nullable = false)
    private Integer rvStar; // 1~5 (DB CHECK)

    @Lob
    @Column(name = "rv_cont", nullable = false, columnDefinition = "TEXT")
    private String rvCont;

    @Lob
    @Column(name = "rv_title", nullable = false, columnDefinition = "TEXT")
    private String rvTitle;

    public Review() {}

    // ===== getter / setter =====
    public Integer getRvIdx() { return rvIdx; }
    public void setRvIdx(Integer rvIdx) { this.rvIdx = rvIdx; }

    public Integer getSIdx() { return sIdx; }
    public void setSIdx(Integer sIdx) { this.sIdx = sIdx; }

    public Integer getMIdx() { return mIdx; }
    public void setMIdx(Integer mIdx) { this.mIdx = mIdx; }

    public Integer getRvStar() { return rvStar; }
    public void setRvStar(Integer rvStar) { this.rvStar = rvStar; }

    public String getRvCont() { return rvCont; }
    public void setRvCont(String rvCont) { this.rvCont = rvCont; }

    public String getRvTitle() { return rvTitle; }
    public void setRvTitle(String rvTitle) { this.rvTitle = rvTitle; }
    
    
}
