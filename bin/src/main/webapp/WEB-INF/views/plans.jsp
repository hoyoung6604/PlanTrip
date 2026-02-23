<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>내 일정 목록</title>
  <link rel="stylesheet" href="/css/plan.css" />
</head>

<div class="container">
  <div class="header">
    <div>
      <h2 class="title">내 일정 목록</h2>
      <p class="sub">저장한 일정들을 확인하고 상세로 들어갈 수 있어요.</p>
    </div>
    <div class="top-actions">
      <a class="btn primary" href="/plan">+ 새 일정 만들기</a>
    </div>
  </div>

  <div class="panel">
    <c:if test="${empty plans}">
      <p class="sub">저장된 일정이 없습니다.</p>
    </c:if>

    <c:forEach var="p" items="${plans}">
      <div class="section">
        <div class="section-head">
          <div>
            <div class="section-title"><span class="step">#</span>${p.tpTitle}</div>
            <div class="section-desc">${p.tpStartDate} ~ ${p.tpEndDate}</div>
          </div>
          <div class="btns">
            <a class="btn" href="/plans/view?tpIdx=${p.tpIdx}">상세보기</a>
            <form method="post" action="/plans/delete" style="display:inline;">
              <input type="hidden" name="tpIdx" value="${p.tpIdx}" />
              <button type="submit" class="btn danger">삭제</button>
            </form>
          </div>
        </div>
      </div>
    </c:forEach>
  </div>
</div>
	
	<p><a href="/plan">일정만들기로 돌아가기</a></p>
	<a href="/">홈으로</a>

	</body>
	</html>