package com.exam.literaryplanner.domain;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

/**
 * ✅ communityT 기반 후기(커뮤니티) 엔티티
 * - DB 설계서: communityT (c_idx, c_title, c_cont, c_img, c_region, c_update, c_v_count, m_idx, s_idx)
 * - 기존 코드에서 Community 라는 도메인명을 사용하고 있어서, 클래스명은 유지하고 테이블만 communityT로 정렬.
 */
@Entity
@Table(name = "communityT")
public class Community {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "c_idx")
    private Integer rvIdx;          // communityT.c_idx

    @Column(name = "m_idx")
    private Integer mIdx;           // communityT.m_idx

    @Column(name = "s_idx")
    private Integer sIdx;           // communityT.s_idx

    @Column(name = "c_title")
    private String rvTitle;         // communityT.c_title

    // ✅ communityT.c_cont 는 DB(호영 스키마) 기준 TEXT(긴 글) 컬럼
    // Hibernate ddl-auto=update 를 쓰는 환경에서 VARCHAR/TINYTEXT 로 축소되는 경우가 있어
    // 컬럼 타입을 TEXT로 명시해서(또는 update 1회 실행 시 TEXT로 복구) 데이터 잘림을 방지한다.
    @Lob
    @Column(name = "c_cont", columnDefinition = "MEDIUMTEXT", nullable = false)
    private String rvCont;          // communityT.c_cont

    /**
     * 여러 장 업로드 시 파일명들을 구분자(|)로 합쳐 저장 (예: a.jpg|b.jpg|c.jpg)
     */
    @Column(name = "c_img", columnDefinition = "TEXT")
    private String rvImg;           // communityT.c_img

    @Column(name = "c_region")
    private String rvRegion;        // communityT.c_region

    // ✅ 등록일(communityT.c_regDate) : DB 설계서상 NOT NULL
    @Column(name = "c_regDate")
    private LocalDateTime rvRegDate;

    // ✅ 수정일(communityT.c_update) : NULL 허용
    @Column(name = "c_update")
    private LocalDateTime rvUpdate;

    @Column(name = "c_v_count")
    private Integer rvVCount;       // communityT.c_v_count (조회수)

    // =========================
    // 연관관계 (조회용)
    // - FK 컬럼(m_idx, s_idx)은 위에서 관리하고
    // - 아래 연관은 insert/update에는 관여하지 않도록 처리
    // =========================
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "m_idx", insertable = false, updatable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "s_idx", insertable = false, updatable = false)
    private Spot spot;

    // ⭐ 별점 기능 (DB 설계서에 컬럼이 없어서 일단 저장은 하지 않음)
	/*
	 * ✅ 별점
	 * 현재 plantripdb의 communityT 스키마에는 별점 컬럼이 없어서(DB 변경 없이 유지),
	 * 조회/목록 진입이 깨지지 않도록 transient로 유지합니다.
	 * (UI 표시/저장은 기존 로직 범위에서만 처리)
	 */
	@Transient
	private Integer rvStar;

    // -------------------------
    // getter / setter
    // -------------------------
    public Integer getRvIdx() { return rvIdx; }
    public void setRvIdx(Integer rvIdx) { this.rvIdx = rvIdx; }

    public Integer getMIdx() { return mIdx; }
    public void setMIdx(Integer mIdx) { this.mIdx = mIdx; }

    public Integer getSIdx() { return sIdx; }
    public void setSIdx(Integer sIdx) { this.sIdx = sIdx; }

    public String getRvTitle() { return rvTitle; }
    public void setRvTitle(String rvTitle) { this.rvTitle = rvTitle; }

    public String getRvCont() { return rvCont; }
    public void setRvCont(String rvCont) { this.rvCont = rvCont; }

    public String getRvImg() { return rvImg; }
    public void setRvImg(String rvImg) { this.rvImg = rvImg; }

    public String getRvRegion() { return rvRegion; }
    public void setRvRegion(String rvRegion) { this.rvRegion = rvRegion; }

    public LocalDateTime getRvRegDate() { return rvRegDate; }
    public void setRvRegDate(LocalDateTime rvRegDate) { this.rvRegDate = rvRegDate; }

    public LocalDateTime getRvUpdate() { return rvUpdate; }
    public void setRvUpdate(LocalDateTime rvUpdate) { this.rvUpdate = rvUpdate; }

    public Integer getRvVCount() { return rvVCount; }
    public void setRvVCount(Integer rvVCount) { this.rvVCount = rvVCount; }

    public Member getMember() { return member; }
    public void setMember(Member member) { this.member = member; }

    public Spot getSpot() { return spot; }
    public void setSpot(Spot spot) { this.spot = spot; }

    public Integer getRvStar() { return rvStar; }
    public void setRvStar(Integer rvStar) { this.rvStar = rvStar; }
}
