package com.exam.literaryplanner.domain;

import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class PlanSaveRequest {
    private String title;
    private LocalDate start;
    private LocalDate end;
    private Integer pIdx;
    // 선택된 장소들(날짜/순서/메모 포함)
    private List<PlanItem> items;

    @Getter @Setter
    @NoArgsConstructor @AllArgsConstructor
    public static class PlanItem {
        private int sIdx;     // spotT PK
        private int day;      // 1일차, 2일차...
        private int seq;      // 같은 day 내 순서
        private String memo;  // optional
		public int getsIdx() {
			return sIdx;
		}
		public void setsIdx(int sIdx) {
			this.sIdx = sIdx;
		}
		public int getDay() {
			return day;
		}
		public void setDay(int day) {
			this.day = day;
		}
		public int getSeq() {
			return seq;
		}
		public void setSeq(int seq) {
			this.seq = seq;
		}
		public String getMemo() {
			return memo;
		}
		public void setMemo(String memo) {
			this.memo = memo;
		}
    }

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public LocalDate getStart() {
		return start;
	}

	public void setStart(LocalDate start) {
		this.start = start;
	}

	public LocalDate getEnd() {
		return end;
	}

	public void setEnd(LocalDate end) {
		this.end = end;
	}

	public List<PlanItem> getItems() {
		return items;
	}

	public void setItems(List<PlanItem> items) {
		this.items = items;
	}

	public Integer getpIdx() {
		return pIdx;
	}

	public void setpIdx(Integer pIdx) {
		this.pIdx = pIdx;
	}
}