package com.exam.literaryplanner.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "reviewT")
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rv_idx")
    private Integer rvIdx;

    @Column(name = "s_idx")
    private Integer sIdx;

    @Column(name = "m_idx")
    private String memberId;

    @Column(name = "rv_star", nullable = false)
    private Integer rvStar;

    @Column(name = "rv_cont", nullable = false, columnDefinition = "TEXT")
    private String rvCont;

    // ✅ getter / setter (정상)
    public Integer getRvIdx() {
        return rvIdx;
    }

    public void setRvIdx(Integer rvIdx) {
        this.rvIdx = rvIdx;
    }

    public Integer getSIdx() {          // 🔥 수정
        return sIdx;
    }

    public void setSIdx(Integer sIdx) { // 🔥 수정
        this.sIdx = sIdx;
    }

    public String getMemberId() {
        return memberId;
    }

    public void setMemberId(String memberId) {
        this.memberId = memberId;
    }

    public Integer getRvStar() {
        return rvStar;
    }

    public void setRvStar(Integer rvStar) {
        this.rvStar = rvStar;
    }

    public String getRvCont() {
        return rvCont;
    }

    public void setRvCont(String rvCont) {
        this.rvCont = rvCont;
    }
}
