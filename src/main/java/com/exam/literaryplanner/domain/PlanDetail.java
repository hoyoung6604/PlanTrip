package com.exam.literaryplanner.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name="planDetailT")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class PlanDetail {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name="pd_idx")
  private Integer pdIdx;

  @Column(name="p_idx", nullable=false)
  private Integer pIdx;

  @Column(name="s_idx", nullable=false)
  private Integer sIdx;

  @Column(name="p_day", nullable=false)
  private Integer pDay;

  @Column(name="p_seq", nullable=false)
  private Integer pSeq;

  @Column(name="p_memo")
  private String pMemo;

  public Integer getPdIdx() {
	return pdIdx;
  }

  public void setPdIdx(Integer pdIdx) {
	this.pdIdx = pdIdx;
  }

  public Integer getpIdx() {
	return pIdx;
  }

  public void setpIdx(Integer pIdx) {
	this.pIdx = pIdx;
  }

  public Integer getsIdx() {
	return sIdx;
  }

  public void setsIdx(Integer sIdx) {
	this.sIdx = sIdx;
  }

  public Integer getpDay() {
	return pDay;
  }

  public void setpDay(Integer pDay) {
	this.pDay = pDay;
  }

  public Integer getpSeq() {
	return pSeq;
  }

  public void setpSeq(Integer pSeq) {
	this.pSeq = pSeq;
  }

  public String getpMemo() {
	return pMemo;
  }

  public void setpMemo(String pMemo) {
	this.pMemo = pMemo;
  }

}