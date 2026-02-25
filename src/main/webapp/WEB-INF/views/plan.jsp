<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>Plan</title>
  <style>
    .spot-card { border:1px solid #ddd; padding:12px; border-radius:10px; margin:10px 0; }
    .spot-title { font-weight:700; font-size:16px; margin-bottom:6px; }
    .muted { color:#666; font-size:13px; }
    .cat-btn { margin-right:8px; }
    .cat-btn.active { font-weight:700; text-decoration:underline; }
  </style>
</head>
<body>

<h2>여행 계획</h2>

<!-- 1) 도시 선택 -->
<label>도시 선택: </label>
<select id="citySelect">
  <c:forEach var="c" items="${cities}">
    <option value="${c.cIdx}" <c:if test="${c.cIdx == defaultCityId}">selected</c:if>>
      ${c.cName}
    </option>
  </c:forEach>
</select>

<hr/>

<!-- 2) 카테고리 선택 -->
<div id="catArea">
  <button type="button" class="cat-btn" data-cat="STAY">숙소</button>
  <button type="button" class="cat-btn" data-cat="ACT">액티비티</button>
  <button type="button" class="cat-btn" data-cat="FOOD">맛집</button>
  <button type="button" class="cat-btn" data-cat="TOUR">관광지</button>
</div>

<hr/>

<!-- 3) 결과 영역 -->
<div id="spotList" class="muted">도시/카테고리를 선택하면 장소가 표시됩니다.</div>

<script>
  const citySelect = document.getElementById('citySelect');
  const spotList = document.getElementById('spotList');
  const catButtons = Array.from(document.querySelectorAll('.cat-btn'));

  // 기본값
  let selectedCat = '${defaultCat}';

  function setActiveCatButton(cat) {
    catButtons.forEach(btn => {
      btn.classList.toggle('active', btn.dataset.cat === cat);
    });
  }

  async function loadSpots() {
    const cityId = citySelect.value;
    if (!cityId || !selectedCat) return;

    spotList.textContent = '불러오는 중...';

    try {
      const res = await fetch(`/plan/spots?cityId=${encodeURIComponent(cityId)}&cat=${encodeURIComponent(selectedCat)}`);
      if (!res.ok) throw new Error('HTTP ' + res.status);

      const data = await res.json();

      if (!data || data.length === 0) {
        spotList.innerHTML = `<div class="muted">해당 조건의 장소가 없습니다.</div>`;
        return;
      }

      spotList.innerHTML = data.map(s => `
        <div class="spot-card">
          <div class="spot-title">${escapeHtml(s.sName ?? '')}</div>
          <div class="muted">${escapeHtml(s.sAddr ?? '')}</div>
          <div class="muted">
            ${s.sHours ? '시간: ' + escapeHtml(s.sHours) : ''}
            ${s.sHoliday ? ' / 휴무: ' + escapeHtml(s.sHoliday) : ''}
          </div>
          <div class="muted">${s.sPrice ? '평점/가격: ' + escapeHtml(s.sPrice) : ''}</div>
          <div style="margin-top:6px;">${s.sInfo ? escapeHtml(s.sInfo) : ''}</div>
        </div>
      `).join('');
    } catch (e) {
      spotList.innerHTML = `<div class="muted">조회 실패: ${escapeHtml(String(e))}</div>`;
    }
  }

  // XSS 방지용(간단 버전)
  function escapeHtml(str) {
    return str
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }

  // 이벤트
  citySelect.addEventListener('change', loadSpots);

  catButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      selectedCat = btn.dataset.cat;
      setActiveCatButton(selectedCat);
      loadSpots();
    });
  });

  // 초기 렌더
  setActiveCatButton(selectedCat);
  loadSpots();
</script>

</body>
</html>