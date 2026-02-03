<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>FAQ 상세 | 고객센터</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0; max-width:900px;">
  <div style="display:flex;justify-content:space-between;gap:12px;align-items:center;margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:22px;">FAQ</h1>
      <p style="margin:6px 0 0; color:#6b7280;">상세</p>
    </div>
    <a class="btn" href="${pageContext.request.contextPath}/support/faq">목록으로</a>
  </div>

  <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:18px;">
    <div style="font-weight:800; font-size:18px; margin-bottom:8px;">
      Q. ${faq.getBTitle()}
    </div>

    <div style="color:#6b7280; font-size:13px; margin-bottom:14px;">
      등록일: ${faq.getBRegDate()}
      <c:if test="${faq.getBIsTop() == 1}">
        <span style="margin-left:8px;display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #e5e7eb;">TOP</span>
      </c:if>
    </div>

    <div style="white-space:pre-wrap; line-height:1.7;">
      A. ${faq.getBCont()}
    </div>
  </div>
</div>

</body>
</html>
