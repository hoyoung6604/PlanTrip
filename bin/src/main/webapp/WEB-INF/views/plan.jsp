<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>여행 계획</title>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/plan.css?v=20260209_12" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/plan_wizard.css?v=20260209_12" />

  </head>
  <!-- <script src="${pageContext.request.contextPath}/js/plan-wizard.js?v=20260209_12"></script> -->

<body>
  <div class="container">
    <div class="header">
      <div>
        <h2 class="title">여행 일정 만들기</h2>
        <p class="sub">Step 0부터 차례대로 입력하면, 다음 버튼으로 하나씩 넘어가요.</p>
      </div>
      <div class="top-actions">
        <a class="btn" href="${pageContext.request.contextPath}/plans">내 일정 목록</a>
      </div>
    </div>

    <div class="panel">
      <form method="post" action="${pageContext.request.contextPath}/plan/save" id="planForm">

        <!-- =========================
             Step 0
        ========================= -->
        <div class="pt-step">
          <div class="section">
            <div class="section-head">
              <div>
                <div class="section-title"><span class="step">0</span>기본 정보</div>
                <div class="section-desc">제목 + 기간</div>
              </div>
              <div class="badge">필수</div>
            </div>

            <div class="row">
              <div class="field wide">
                <label>일정 제목(필수)</label>
                <input type="text" name="tpTitle" placeholder="예: 부산 2박3일 맛집+해변" required />
              </div>
              <div class="field">
                <label>출발날짜(필수)</label>
                <input type="date" name="tpStartDate" id="tpStartDate" />
              </div>
              <div class="field">
                <label>종료일</label>
                <input type="date" name="tpEndDate" id="tpEndDate" />
              </div>
            </div>
			
			<div class="row" style="margin-top:10px;">
					      <div class="field wide">
					        <label>여행 목적(1~2개 추천)</label>
					        <div class="pills">
					          <label class="pill"><input type="checkbox" name="goals" value="휴식" /> 휴식</label>
					          <label class="pill"><input type="checkbox" name="goals" value="맛집" /> 맛집</label>
					          <label class="pill"><input type="checkbox" name="goals" value="관광" /> 관광</label>
					          <label class="pill"><input type="checkbox" name="goals" value="쇼핑" /> 쇼핑</label>
					          <label class="pill"><input type="checkbox" name="goals" value="자연" /> 자연</label>
					          <label class="pill"><input type="checkbox" name="goals" value="액티비티" /> 액티비티</label>
					        </div>
					      </div>

					      <div class="field">
					        <label>이동 수단</label>
					        <div class="pills">
					          <label class="pill"><input type="radio" name="transport" value="대중교통" checked /> 대중교통</label>
					          <label class="pill"><input type="radio" name="transport" value="렌터카" /> 렌터카</label>
					          <label class="pill"><input type="radio" name="transport" value="도보 위주" /> 도보 위주</label>
					        </div>

            
		<a href="/">홈으로</a>

		      </div>
            </div>

			    <div class="hint">
			      다음 단계에서 <strong>Day(일자) 생성</strong>을 할 거예요. 지금은 여행 스타일만 간단히 정하면 돼요.
			    </div>
			  </div>
			</div>

        <!-- =========================
             Step 1: Day 및 일정 항목 동적 제어 로직
        ========================= -->
		<div class="pt-step">
		  <div class="section">
		    <div class="section-head">
		      <div>
		        <div class="section-title"><span class="step">2</span>코스 정하기</div>
		        <div class="section-desc">원하는 만큼 Day를 추가하고 일정을 적어보세요.</div>
		      </div>
		      <div class="btns">
		        <button type="button" class="btn primary" onclick="addDayCard()">Day 생성</button> 
		      </div>
		    </div>

		    <div id="dayRegionWrap" style="display: flex; gap: 20px; overflow-x: auto; padding: 10px; min-height: 100px;">
		        </div>
		  </div>
		</div>
		
       
  <!-- =========================
       기존 JS 함수들(너가 쓰던 것 유지)
  ========================= -->
  <script>
	  /* ================================================= */
	  /* 공통 유틸리티                                     */
	  /* ================================================= */
	  function _parseDate(v){
	    if(!v) return null;
	    const d = new Date(v + "T00:00:00");
	    return isNaN(d.getTime()) ? null : d;
	  }

	  function _daysBetweenInclusive(start, end){
	    const ms = 24*60*60*1000;
	    return Math.floor((end.getTime() - start.getTime())/ms) + 1;
	  }

	  /* ================================================= */
	  /* Step 2: Day 및 일정 항목 동적 제어 로직              */
	  /* ================================================= */
	  let dayCount = 0;

	  // 1. Day 카드 생성 함수
	  window.addDayCard = function() {
	      dayCount++;
	      const wrap = document.getElementById("dayRegionWrap");
	      
	      if (!wrap) {
	          console.error("dayRegionWrap 요소를 찾을 수 없습니다.");
	          return;
	      }
	      
	      const cardUnit = document.createElement("div");
	      cardUnit.className = "day-unit";
	      cardUnit.style = "display: flex; align-items: center; gap: 15px; flex-shrink: 0; margin-bottom:10px;";
	      cardUnit.id = `dayUnit_${dayCount}`;
	      
	      cardUnit.innerHTML = `
	          <div class="day-card" style="width: 400px; background: rgba(255,255,255,0.05); border: 1px solid var(--line2); padding: 20px; border-radius: 14px;">
	              <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
	                  <h4 style="margin:0; color:var(--accent);">Day ${dayCount} 코스 설계</h4>
	                  <button type="button" class="btn danger" style="padding:4px 8px; font-size:11px;" onclick="removeDayUnit(${dayCount})">삭제</button>
	              </div>
	              <div id="mustGoContainer_${dayCount}">
	                  <div class="field" style="margin-top:10px;">
	                      <label>일정(필수) 1</label>
	                      <input type="text" name="mustGo_${dayCount}" placeholder="예: 18:00 요트투어 예약" />
	                  </div>
	                  <div class="field" style="margin-top:10px;">
	                      <label>일정(필수) 2</label>
	                      <input type="text" name="mustGo_${dayCount}" placeholder="예: 해운대 암소갈비 점심" />
	                  </div>
	              </div>
	              <button type="button" class="btn" style="width:100%; font-size:12px; margin-top:12px;" onclick="addMustGo(${dayCount})">+ 일정 추가</button>
	              <div class="row" style="margin-top:15px;">
	                  <div class="field"><label>활동 가능 시간</label><input type="text" name="activeTime_${dayCount}" placeholder="예: 09:00" /></div>
	                  <div class="field"><label>이동 수단</label><input type="text" name="transport_${dayCount}" placeholder="예: 렌터카" /></div>
	              </div>
	          </div>
	          
	          <div class="add-next-day" style="cursor: pointer; display: flex; align-items: center; justify-content: center; width: 50px; height: 150px; background: rgba(255,255,255,0.03); border: 2px dashed var(--line2); border-radius: 12px;" onclick="addDayCard()">
	              <span style="font-size: 30px; color: var(--accent);">+</span>
	          </div>
	      `;
	      wrap.appendChild(cardUnit);
	      cardUnit.scrollIntoView({ behavior: "smooth", block: "nearest", inline: "end" });
	  };

	  // ✅ 위저드 JS와의 호환성을 위해 별칭 생성
	  window.wizardGenerateDays = window.addDayCard;

	  window.addMustGo = function(dayNum) {
	      const container = document.getElementById(`mustGoContainer_${dayNum}`);
	      const currentCount = container.querySelectorAll('.field').length + 1;
	      const field = document.createElement("div");
	      field.className = "field";
	      field.style.marginTop = "10px";
	      field.innerHTML = `
	          <label>일정(필수) ${currentCount}</label>
	          <input type="text" name="mustGo_${dayNum}" placeholder="추가 일정을 입력하세요" />
	      `;
	      container.appendChild(field);
	  };

	  window.removeDayUnit = function(dayNum) {
	      const unit = document.getElementById(`dayUnit_${dayNum}`);
	      if(unit) unit.remove();
	  };

	  /* ================================================= */
	  /* Step 5 데이터 연동 로직                             */
	  /* ================================================= */
	  window.syncStep2ToStep5 = function() {
	      const tbody = document.getElementById("detailTbody");
	      if (!tbody) return;
	      tbody.innerHTML = ""; 

	      const cards = document.querySelectorAll(".day-card");
	      cards.forEach((card, index) => {
	          const displayDay = index + 1; 
	          const mustGoInputs = card.querySelectorAll(`input[name^="mustGo_"]`);
	          
	          mustGoInputs.forEach((input) => {
	              const val = input.value.trim();
	              if (val) {
	                  addDetailRow(displayDay, `[필수] ${val}`);
	              }
	          });
	      });

	      if (tbody.children.length === 0) addRow();
	  };

	  function addDetailRow(day, memo) {
	      const tbody = document.getElementById("detailTbody");
	      const tr = document.createElement("tr");
	      tr.innerHTML = `
	          <td><input type="number" name="dayNo" value="${day}" /></td>
	          <td><input type="number" name="orderNo" value="${tbody.children.length + 1}" /></td>
	          <td><input type="number" name="sIdx" placeholder="예: 101" /></td>
	          <td><input type="text" name="memo" value="${memo}" style="width:100%;" /></td>
	      `;
	      tbody.appendChild(tr);
	  }

	  window.addRow = function(){
	    const tbody = document.getElementById("detailTbody");
	    const tr = document.createElement("tr");
	    tr.innerHTML = `
	      <td><input type="number" name="dayNo" value="1" min="1" /></td>
	      <td><input type="number" name="orderNo" value="${tbody.children.length + 1}" min="1" /></td>
	      <td><input type="number" name="sIdx" placeholder="예: 101" /></td>
	      <td><input type="text" name="memo" placeholder="예: 일정 메모" style="width:100%;" /></td>
	    `;
	    tbody.appendChild(tr);
	  }

	  window.removeLastRow = function(){
	    const tbody = document.getElementById("detailTbody");
	    if (tbody.children.length <= 1) return;
	    tbody.removeChild(tbody.lastElementChild);
	  }
	  
  
	</script>
  <!-- ✅ 위저드 JS 로드 (컨텍스트패스 + 캐시버스터) -->
  <script src="${pageContext.request.contextPath}/js/plan-wizard.js?v=20260209_10"></script>
</body>
</html>
