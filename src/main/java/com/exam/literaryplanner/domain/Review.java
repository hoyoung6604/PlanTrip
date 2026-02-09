package com.exam.literaryplanner.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "reviewT")
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rv_idx", nullable = false)
    private Integer rvIdx; // BIGINT AI

    @Column(name = "s_idx", nullable = false)
    private Integer sIdx; // FK -> spotT(s_idx)

    @Column(name = "m_idx", nullable = false)
    private Integer mIdx; // FK -> memberT(m_idx)

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
