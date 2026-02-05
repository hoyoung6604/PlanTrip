<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>FAQ 상세 | 관리자</title>
  <link rel="stylesheet" href="/css/home.css"/>
  <style>
    .wrap{max-width:900px;margin:0 auto;padding:24px;}
    .card{background:#fff;color:#111;border:1px solid rgba(0,0,0,.12);border-radius:14px;padding:18px;}
    .meta{color:#6b7280;font-size:13px;margin-top:8px;margin-bottom:14px;}
    .pill{display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #e5e7eb;margin-left:8px;}
    .btn{padding:10px 12px;border-radius:10px;border:1px solid rgba(0,0,0,.15);background:#fff;cursor:pointer;text-decoration:none;color:#111;}
  </style>
</head>
<body>

<header class="header is-solid">
  <div class="container header-inner">
    <a href="/admin" class="brand-top"><img class="brand-logo-img" src="/img/PlanTriplog.png" alt="PlanTrip"></a>
    <nav class="nav">
      <a href="/admin/faqs" style="font-weight:700;">FAQ</a>
    </nav>
    <div class="header-right">
      <div>${sessionScope.loginMember.MName} (ADMIN)</div>
      <form action="/members/logout" method="post" style="margin:0;">
        <button class="header-auth" type="submit">로그아웃</button>
      </form>
    </div>
  </div>
</header>

<main class="wrap">
  <div class="card">
    <div style="display:flex;justify-content:space-between;gap:10px;align-items:center;">
      <h2 style="margin:0;">FAQ 상세</h2>
      <div style="display:flex;gap:8px;">
        <a class="btn" href="${pageContext.request.contextPath}/admin/faqs">목록</a>
        <a class="btn" href="${pageContext.request.contextPath}/admin/faqs/${faq.getBIdx()}/edit">수정</a>
        <form action="${pageContext.request.contextPath}/admin/faqs/${faq.getBIdx()}/delete"
              method="post" style="margin:0;" onsubmit="return confirm('정말 삭제할까요?');">
          <button class="btn" type="submit">삭제</button>
        </form>
      </div>
    </div>

    <div style="font-weight:800;font-size:18px;margin-top:12px;">
      Q. ${faq.getBTitle()}
    </div>

    <div class="meta">
      등록일: ${faq.getBRegDate()}
      <c:if test="${faq.getBIsTop() == 1}">
        <span class="pill">TOP</span>
      </c:if>
    </div>

    <div style="white-space:pre-wrap;line-height:1.7;">
      A. ${faq.getBCont()}
    </div>
  </div>
</main>

</body>
</html>
