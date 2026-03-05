<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>여행 계획 수정</title>

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
<script src="/js/ui-toast.js"></script>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="wrap">

  <h2>여행 계획 수정</h2>
  <p class="muted">기본 정보(제목/날짜/도시/목적)를 수정한 뒤 저장하면, 다음 단계로 장소 선택/경로 수정 화면으로 이동해.</p>

  <div class="card">
    <form id="planForm" method="post" action="${pageContext.request.contextPath}/plans/edit">
      <!-- ✅ 어떤 계획을 수정할지 필수 -->
      <input type="hidden" name="pIdx" value="${plan.pIdx}" />

      <!-- 계획 이름 -->
      <div style="margin-bottom: 14px;">
        <label for="planName">계획 이름</label>
        <input type="text" id="planName" name="planName"
               placeholder="예) 3월 제주 여행" maxlength="50" required
               value="<c:out value='${plan.pTitle}'/>" />
        <div class="muted">내 계획 목록에서 보여줄 이름이야.</div>
      </div>

      <!-- 도시 -->
      <div style="margin-bottom: 14px;">
        <label for="cId">여행지(도시)</label>
        <select id="cId" name="cId" required>
          <option value="">-- 도시를 선택하세요 --</option>

          <!--
            ✅ selectedCityId 를 model로 내려주면 선택값 자동 표시 가능
            (없으면 그냥 직접 다시 선택하면 됨)
          -->
          <c:forEach var="c" items="${cities}">
            <option value="${c.id}"
              <c:if test="${not empty selectedCityId and selectedCityId == c.id}">selected</c:if>>
              ${c.name}
            </option>
          </c:forEach>
        </select>

        <div class="muted">도시/목적은 계획 테이블에 저장돼 있어야 자동 선택이 가능합니다.</div>

        <c:if test="${empty cities}">
          <div class="warn">⚠ 도시 목록이 비어 있습니다. cityT에 데이터가 들어있는지 확인해 주세요.</div>
        </c:if>
      </div>

      <!-- 여행 날짜(캘린더) -->
      <div style="margin-bottom: 14px;">
        <label>여행 날짜</label>
        <div class="row">
          <div>
            <div class="muted" style="margin:0 0 6px;">시작일</div>
            <input type="date" id="startDate" name="startDate" required value="${plan.pStart}" />
          </div>
          <div>
            <div class="muted" style="margin:0 0 6px;">종료일</div>
            <input type="date" id="endDate" name="endDate" required value="${plan.pEnd}" />
          </div>
        </div>
        <div class="muted">시작일 ≤ 종료일로 선택해 주세요.</div>
      </div>

      <!-- 목적(복수) -->
      <div style="margin-bottom: 14px;">
        <label>여행 목적 (복수 선택)</label>

        <!--
          ✅ selectedPurposes (List<String>)를 model로 내려주면 자동 체크 가능
          ex) ["TOUR","FOOD"]
          (없으면 그냥 다시 체크하면 됨)
        -->
        <div class="checks">
          <label class="checkItem">
            <input type="checkbox" name="purposes" value="TOUR"
              <c:if test="${not empty selectedPurposes and selectedPurposes.contains('TOUR')}">checked</c:if>>
            관광
          </label>

          <label class="checkItem">
            <input type="checkbox" name="purposes" value="FOOD"
              <c:if test="${not empty selectedPurposes and selectedPurposes.contains('FOOD')}">checked</c:if>>
            맛집
          </label>

          <label class="checkItem">
            <input type="checkbox" name="purposes" value="ACTIVITY"
              <c:if test="${not empty selectedPurposes and selectedPurposes.contains('ACTIVITY')}">checked</c:if>>
            액티비티
          </label>
        </div>

        <div class="muted">하나 이상 선택해 주세요. (예: 관광+맛집)</div>
      </div>

      <div class="btns">
        <button type="button" onclick="history.back()">뒤로</button>
        <button type="submit" class="primary">저장하고 장소 선택/경로 수정으로</button>
      </div>

      <c:if test="${not empty error}">
        <div class="warn"><c:out value="${error}"/></div>
      </c:if>
    </form>
  </div>

  <div class="card">
    <b>다음 단계</b>
    <p class="muted" style="margin-top: 8px;">
      저장되면 route 페이지로 이동해서, 기존에 저장된 장소를 불러오고 수정할 수 있게 수정할 수 있습니다.
    </p>
  </div>

</div>

<script>
  const startEl = document.getElementById('startDate');
  const endEl   = document.getElementById('endDate');

  // 페이지 로드시에도 min 세팅 (기존 값 있을 때 중요)
  if (startEl.value) endEl.min = startEl.value;

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

    if (!planName) { e.preventDefault(); UIToast.show('계획 이름을 입력해 주세요.', { type: 'warning' }); return; }
    if (!cId) { e.preventDefault(); UIToast.show('도시를 선택해 주세요.', { type: 'warning' }); return; }
    if (!startDate || !endDate) { e.preventDefault(); UIToast.show('여행 날짜를 선택해 주세요.', { type: 'warning' }); return; }
    if (endDate < startDate) { e.preventDefault(); UIToast.show('종료일은 시작일보다 빠를 수 없습니다.', { type: 'warning' }); return; }
    if (!checked.length) { e.preventDefault(); UIToast.show('여행 목적을 최소 1개 선택해 주세요.', { type: 'warning' }); return; }
  });
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
</body>
</html>