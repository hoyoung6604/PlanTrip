<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8"/>
<title>문의 상세 | 고객센터</title>
<link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0; max-width:900px;">

<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
  <h2>문의 상세</h2>
  <a class="btn" href="${pageContext.request.contextPath}/support/qna">목록</a>
</div>

<div style="background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:16px;">
  <div style="font-weight:800;font-size:18px;">${qna['qTitle']}</div>

  <div style="margin-top:6px;color:#6b7280;font-size:12px;">
    등록일: ${qna['qRegDate']} · 상태: ${qna['qStatusLabel']}
  </div>

  <div style="margin-top:14px;white-space:pre-wrap;">
    ${qna['qCont']}
  </div>

  <div style="display:flex;justify-content:flex-end;gap:8px;margin-top:16px;">
    <a class="btn" href="${pageContext.request.contextPath}/support/qna/${qna['qIdx']}/edit">수정</a>

    <form action="${pageContext.request.contextPath}/support/qna/${qna['qIdx']}/delete"
          method="post" style="margin:0;"
          onsubmit="return confirm('정말 삭제할까요?');">
      <button class="btn" type="submit">삭제</button>
    </form>
  </div>
</div>

<div style="background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:16px;margin-top:14px;">
  <h4>관리자 답변</h4>

  <c:choose>
    <c:when test="${not empty qna['qAnswer']}">
      <div style="white-space:pre-wrap;">
        ${qna['qAnswer']}
      </div>
    </c:when>
    <c:otherwise>
      <div style="color:#6b7280;">아직 답변이 없습니다.</div>
    </c:otherwise>
  </c:choose>
</div>

</div>
</body>
</html>
