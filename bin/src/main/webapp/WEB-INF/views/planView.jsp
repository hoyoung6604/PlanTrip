<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
  <title>일정 상세</title>
  <link rel="stylesheet" href="/css/plan.css" />
</head>
<body>

<div class="container">
  <div class="header">
    <div>
      <h2 class="title">일정 상세</h2>
      <p class="sub">6가지 사전결정 + 권역 + 안전장치 요약과 상세 일정을 함께 보여줘요.</p>
    </div>
    <div class="top-actions">
      <a class="btn" href="/plans">목록으로</a>
      <form method="post" action="/plans/delete" style="display:inline;">
        <input type="hidden" name="tpIdx" value="${plan.tpIdx}" />
        <button type="submit" class="btn danger">삭제</button>
      </form>
    </div>
  </div>

  <div class="panel">
    <div class="section">
      <div class="section-head">
        <div>
          <div class="section-title"><span class="step">A</span>기본</div>
          <div class="section-desc">제목/기간</div>
        </div>
      </div>

      <div class="row">
        <div class="field wide">
          <label>제목</label>
          <input value="${plan.tpTitle}" readonly />
        </div>
        <div class="field">
          <label>시작일</label>
          <input value="${plan.tpStartDate}" readonly />
        </div>
        <div class="field">
          <label>종료일</label>
          <input value="${plan.tpEndDate}" readonly />
        </div>
      </div>
    </div>

    <div class="section">
      <div class="section-head">
        <div>
          <div class="section-title"><span class="step">B</span>요약(가이드 입력)</div>
          <div class="section-desc">저장 시 tp_meta로 같이 저장된 내용</div>
        </div>
      </div>
      <textarea readonly style="width:100%; min-height:160px;"><c:out value="${plan.tpMeta}"/></textarea>
    </div>

    <div class="section">
      <div class="section-head">
        <div>
          <div class="section-title"><span class="step">C</span>상세 일정</div>
          <div class="section-desc">SpotID는 숫자, 메모 중심</div>
        </div>
      </div>

      <c:if test="${empty details}">
        <p class="sub">상세 일정이 없습니다.</p>
      </c:if>

      <c:if test="${not empty details}">
        <table class="table">
          <thead>
            <tr>
              <th style="width:90px;">Day</th>
              <th style="width:110px;">Order</th>
              <th style="width:160px;">Spot ID</th>
              <th>메모</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="d" items="${details}">
              <tr>
                <td>${d.dayNo}</td>
                <td>${d.orderNo}</td>
                <td><c:out value="${d.sIdx}"/></td>
                <td><c:out value="${d.memo}"/></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </c:if>
    </div>
  </div>
</div>

</body>
</html>
