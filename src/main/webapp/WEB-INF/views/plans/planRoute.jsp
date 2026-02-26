<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>여행 계획 만들기</title>

  <link rel="stylesheet" href="/css/header.css" />
  <script src="/js/theme.js"></script>
  <script defer src="/js/nav-wave.js"></script>

  <style>
    .wrap { max-width: 920px; margin: 28px auto; padding: 0 12px; }
    .card { border: 1px solid #e5e5e5; border-radius: 12px; padding: 18px; margin-bottom: 14px; }
    label { font-weight: 700; display:block; margin-bottom: 6px; }
    input[type="text"], input[type="date"], select {
      padding: 10px 12px; border: 1px solid #ccc; border-radius: 10px;
    }
    input[type="text"] { min-width: 320px; }
    select { min-width: 260px; }
    .row { display:flex; gap: 14px; flex-wrap: wrap; align-items: center; }
    .checks { display:flex; gap: 14px; flex-wrap: wrap; margin-top: 8px; }
    .checkItem { border: 1px solid #ddd; border-radius: 10px; padding: 10px 12px; cursor: pointer; user-select: none; }
    .checkItem input { margin-right: 6px; }
    .muted { color:#777; font-size: 13px; margin-top: 6px; }
    .warn { color:#b00020; font-size: 13px; margin-top: 10px; }
    .btns { display:flex; gap: 10px; margin-top: 16px; }
    button { padding: 10px 12px; border: 1px solid #ccc; border-radius: 10px; background:#fff; cursor:pointer; }
    button.primary { border-color:#222; font-weight: 800; }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="wrap">

  <h2>여행 계획 만들기</h2>
  <p class="muted">도시/목적/날짜를 정해서 저장하면 바로 장소 선택+경로 페이지로 이동해.</p>

  <div class="card">
    <form id="planForm" method="post" action="${pageContext.request.contextPath}/plans/planRoute">
      <!-- (스프링 시큐리티 CSRF 사용 시)
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
      -->

      <!-- 계획 이름 -->
      <div style="margin-bottom: 14px;">
        <label for="planName">계획 이름</label>
        <input type="text" id="planName" name="planName"
               placeholder="예) 3월 제주 여행" maxlength="50" required />
        <div class="muted">내 계획 목록에서 보여줄 이름이야.</div>
      </div>

      <!-- 도시 -->
      <div style="margin-bottom: 14px;">
        <label for="cId">여행지(도시)</label>
        <select id="cId" name="cId" required>
          <option value="">-- 도시를 선택하세요 --</option>
          <c:forEach var="c" items="${cities}">
            <option value="${c.id}">${c.name}</option>
          </c:forEach>
        </select>
        <div class="muted">DB(cityT)에 저장된 도시 목록이 출력돼.</div>
        <c:if test="${empty cities}">
          <div class="warn">⚠ 도시 목록이 비어있어. cityT에 데이터가 들어있는지 확인해줘.</div>
        </c:if>
      </div>

      <!-- 여행 날짜(캘린더) -->
      <div style="margin-bottom: 14px;">
        <label>여행 날짜</label>
        <div class="row">
          <div>
            <div class="muted" style="margin:0 0 6px;">시작일</div>
            <input type="date" id="startDate" name="startDate" required />
          </div>
          <div>
            <div class="muted" style="margin:0 0 6px;">종료일</div>
            <input type="date" id="endDate" name="endDate" required />
          </div>
        </div>
        <div class="muted">시작일 ≤ 종료일로 선택해줘.</div>
      </div>

      <!-- 목적(복수) -->
      <div style="margin-bottom: 14px;">
        <label>여행 목적 (복수 선택)</label>
        <div class="checks">
          <label class="checkItem">
            <input type="checkbox" name="purposes" value="TOUR"> 관광
          </label>
          <label class="checkItem">
            <input type="checkbox" name="purposes" value="FOOD"> 맛집
          </label>
          <label class="checkItem">
            <input type="checkbox" name="purposes" value="ACTIVITY"> 액티비티
          </label>
        </div>
        <div class="muted">하나 이상 선택해줘. (예: 관광+맛집)</div>
      </div>

      <div class="btns">
        <button type="button" onclick="history.back()">뒤로</button>
        <button type="submit" class="primary">계획 저장하고 장소 선택/경로로</button>
      </div>

      <c:if test="${not empty error}">
        <div class="warn">${error}</div>
      </c:if>
    </form>
  </div>

  <div class="card">
    <b>다음 단계</b>
    <p class="muted" style="margin-top: 8px;">
      저장되면 route 페이지로 이동해서, 체크박스로 장소를 고르고 지도에서 선으로 경로를 확인해.
    </p>
  </div>

</div>

<script>
  const startEl = document.getElementById('startDate');
  const endEl   = document.getElementById('endDate');

  // 시작일 바꾸면 종료일 최소값도 같이 맞춰줌
  startEl.addEventListener('change', () => {
    if (startEl.value) endEl.min = startEl.value;
    if (endEl.value && startEl.value && endEl.value < startEl.value) endEl.value = startEl.value;
  });

  document.getElementById('planForm').addEventListener('submit', function(e) {
    const planName = document.getElementById('planName').value.trim();
    const cId = document.getElementById('cId').value;
    const checked = document.querySelectorAll('input[name="purposes"]:checked');
    const startDate = startEl.value;
    const endDate = endEl.value;

    if (!planName) { e.preventDefault(); alert('계획 이름을 입력해줘!'); return; }
    if (!cId) { e.preventDefault(); alert('도시를 선택해줘!'); return; }
    if (!startDate || !endDate) { e.preventDefault(); alert('여행 날짜를 선택해줘!'); return; }
    if (endDate < startDate) { e.preventDefault(); alert('종료일은 시작일보다 빠를 수 없어!'); return; }
    if (!checked.length) { e.preventDefault(); alert('여행 목적을 최소 1개 선택해줘!'); return; }
  });
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>

</body>
</html>