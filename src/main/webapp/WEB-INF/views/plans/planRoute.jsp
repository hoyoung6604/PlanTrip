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
    body { background-color: #f8f9fa; }
    .wrap { max-width: 800px; margin: 40px auto; padding: 0 20px; animation: fadeIn 0.5s ease-out; }
    .card { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); margin-bottom: 20px; }
    h2 { margin-bottom: 8px; color: #333; }
    .muted { color: #666; font-size: 14px; margin-bottom: 24px; }
    label { font-weight: 600; display: block; margin-bottom: 8px; color: #222; }
    input[type="text"], input[type="date"], select { width: 100%; padding: 12px; border: 1px solid #e1e4e8; border-radius: 10px; box-sizing: border-box; transition: border 0.3s; }
    input:focus { border-color: #2979ff; outline: none; }
    .row { display: flex; gap: 16px; }
    .row > div { flex: 1; }
    .checks { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 10px; }
    .checkItem { border: 1px solid #e1e4e8; border-radius: 10px; padding: 12px 16px; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; }
    .checkItem:hover { border-color: #2979ff; background: #f0f7ff; }
    .btns { display: flex; gap: 12px; margin-top: 24px; }
    button { padding: 12px 20px; border-radius: 10px; cursor: pointer; border: none; font-weight: 600; transition: transform 0.2s, background 0.2s; }
    button:active { transform: scale(0.98); }
    button.primary { background: #2979ff; color: #fff; flex: 2; }
    button.secondary { background: #eee; color: #333; flex: 1; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    @media (max-width: 600px) { .row { flex-direction: column; gap: 10px; } }
  </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<div class="wrap">
  <h2>여행 계획 만들기</h2>
  <p class="muted">세부 정보를 입력하여 나만의 여행을 시작하세요.</p>
  <div class="card">
    <form id="planForm" method="post" action="${pageContext.request.contextPath}/plans/planRoute">
      <div style="margin-bottom: 20px;">
        <label for="planName">계획 이름</label>
        <input type="text" id="planName" name="planName" placeholder="예) 3월 제주 여행" required />
      </div>
      <div style="margin-bottom: 20px;">
        <label for="cId">여행지(도시)</label>
        <select id="cId" name="cId" required>
          <option value="">-- 도시를 선택하세요 --</option>
          <c:forEach var="c" items="${cities}">
            <option value="${c.id}">${c.name}</option>
          </c:forEach>
        </select>
      </div>
      <div style="margin-bottom: 20px;">
        <label>여행 날짜</label>
        <div class="row">
          <div><input type="date" id="startDate" name="startDate" required /></div>
          <div><input type="date" id="endDate" name="endDate" required /></div>
        </div>
      </div>
      <div style="margin-bottom: 20px;">
        <label>여행 목적</label>
        <div class="checks">
          <label class="checkItem"><input type="checkbox" name="purposes" value="TOUR"> 관광</label>
          <label class="checkItem"><input type="checkbox" name="purposes" value="FOOD"> 맛집</label>
          <label class="checkItem"><input type="checkbox" name="purposes" value="ACTIVITY"> 액티비티</label>
        </div>
      </div>
      <div class="btns">
        <button type="button" class="secondary" onclick="history.back()">뒤로</button>
        <button type="submit" class="primary">다음 단계로 이동</button>
      </div>
    </form>
  </div>
</div>
<script>
  const startEl = document.getElementById('startDate');
  const endEl   = document.getElementById('endDate');
  startEl.addEventListener('change', () => {
    if (startEl.value) endEl.min = startEl.value;
  });
</script>
<%@ include file="/WEB-INF/views/common/footer.jspf" %>
</body>
</html>