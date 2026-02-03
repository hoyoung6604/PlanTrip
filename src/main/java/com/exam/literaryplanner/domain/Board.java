package com.exam.literaryplanner.domain;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(name = "boardT")
public class Board {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "b_idx")
    private Long bIdx;

    @Column(name = "b_type", nullable = false, length = 10)
    private String bType; // NOTICE / FAQ

    @Column(name = "b_title", nullable = false, length = 200)
    private String bTitle;

    @Lob
    @Column(name = "b_cont", nullable = false)
    private String bCont;

    @Column(name = "b_is_top", nullable = false)
    private Integer bIsTop = 0; // 0/1

    @CreationTimestamp
    @Column(name="b_reg_date", updatable = false)
    private LocalDateTime bRegDate;

    public Board() {}

    public Long getBIdx() { return bIdx; }
    public void setBIdx(Long bIdx) { this.bIdx = bIdx; }

    public String getBType() { return bType; }
    public void setBType(String bType) { this.bType = bType; }

    public String getBTitle() { return bTitle; }
    public void setBTitle(String bTitle) { this.bTitle = bTitle; }

    public String getBCont() { return bCont; }
    public void setBCont(String bCont) { this.bCont = bCont; }

    public Integer getBIsTop() { return bIsTop; }
    public void setBIsTop(Integer bIsTop) { this.bIsTop = bIsTop; }

    public LocalDateTime getBRegDate() { return bRegDate; }
    public void setBRegDate(LocalDateTime bRegDate) { this.bRegDate = bRegDate; }
    
}
