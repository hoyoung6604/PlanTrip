<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>FAQ | 관리자</title>
  <link rel="stylesheet" href="/css/home.css"/>
  <style>
    .wrap{max-width:1100px;margin:0 auto;padding:24px;}
    .card{background:#fff;color:#111;border:1px solid rgba(0,0,0,.12);border-radius:14px;padding:18px;}
    .topbar{display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:14px;}
    .btn{display:inline-block;padding:10px 12px;border-radius:10px;border:1px solid rgba(0,0,0,.15);background:#111;color:#fff;text-decoration:none;}
    table{width:100%;border-collapse:collapse;}
    th,td{padding:12px;border-bottom:1px solid rgba(0,0,0,.08);text-align:left;}
    .pill{display:inline-block;font-size:12px;padding:4px 8px;border-radius:999px;border:1px solid rgba(0,0,0,.15);}
  </style>
</head>
<body>

<header class="header is-solid">
  <div class="container header-inner">
    <a href="/admin" class="brand-top"><img class="brand-logo-img" src="/img/PlanTriplog.png" alt="PlanTrip"></a>
    <nav class="nav">
      <a href="/admin">관리자</a>
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
    <div class="topbar">
      <div>
        <h2 style="margin:0;">FAQ</h2>
        <p style="margin:6px 0 0;opacity:.7;">등록된 FAQ를 관리합니다.</p>
      </div>
      <a class="btn" href="${pageContext.request.contextPath}/admin/faq">+ FAQ 작성</a>
    </div>

    <table>
      <thead>
      <tr style="color:#6b7280;font-size:12px;">
        <th style="width:90px;">고정</th>
        <th>질문(제목)</th>
        <th style="width:180px;">등록일</th>
      </tr>
      </thead>
      <tbody>
      <c:if test="${empty faqList}">
        <tr><td colspan="3" style="opacity:.7;">등록된 FAQ가 없습니다.</td></tr>
      </c:if>

      <c:forEach var="f" items="${faqList}">
        <tr>
          <td>
            <c:if test="${f.getBIsTop() == 1}">
              <span class="pill">TOP</span>
            </c:if>
          </td>
          <td>
            <a href="${pageContext.request.contextPath}/admin/faqs/${f.getBIdx()}"
               style="color:inherit;text-decoration:none;">
              ${f.getBTitle()}
            </a>
          </td>
          <td style="color:#6b7280;">${f.getBRegDate()}</td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</main>

</body>
</html>
