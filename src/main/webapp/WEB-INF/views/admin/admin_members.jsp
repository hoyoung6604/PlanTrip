<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>

<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>회원 관리 | PlanTrip</title>
<link rel="stylesheet" href="/css/home.css">

<style>
:root{
  --admin-bg:#fff; --admin-text:#111; --admin-muted:rgba(17,17,17,.70);
  --admin-border:rgba(0,0,0,.12); --admin-hover:rgba(0,0,0,.04);
}
.admin-wrap{max-width:1200px;margin:0 auto;padding:30px;display:grid;grid-template-columns:240px 1fr;gap:20px;}
.admin-side,.admin-main{background:var(--admin-bg)!important;color:var(--admin-text)!important;border:1px solid var(--admin-border)!important;border-radius:14px;}
.admin-side{padding:18px;} .admin-main{padding:22px;}
.admin-link{display:block;padding:12px;border-radius:10px;margin-bottom:10px;text-decoration:none;background:#fff!important;color:var(--admin-text)!important;border:1px solid var(--admin-border)!important;}
.admin-link:hover{background:var(--admin-hover)!important;}
.hr-admin{border:0;border-top:1px solid var(--admin-border);margin:14px 0;}
.header.is-solid{background:#fff!important;border-bottom:1px solid rgba(0,0,0,.10);}
.header.is-solid .nav a,.header.is-solid .header-right,.header.is-solid .header-auth{color:#111!important;}
.table{width:100%;border-collapse:collapse;font-size:14px;}
.table th,.table td{padding:10px 6px;text-align:left;}
.table thead tr{border-bottom:1px solid #e5e7eb;}
.table tbody tr{border-top:1px solid #f1f5f9;}
.badge{display:inline-block;padding:4px 10px;border-radius:999px;border:1px solid #e5e7eb;font-size:12px;color:#111;}
.search-row{display:flex;gap:8px;margin:12px 0 16px;}
.search-row input{flex:1;padding:10px;border:1px solid #e5e7eb;border-radius:10px;}
.search-row button{padding:10px 14px;border:1px solid #e5e7eb;border-radius:10px;background:#fff;cursor:pointer;}
.search-row button:hover{background:var(--admin-hover);}
</style>
</head>

<body>
<header class="header is-solid">
  <div class="container header-inner">
    <a href="/" class="brand-top" title="메인으로">
      <img class="brand-logo-img" src="/img/PlanTriplog.png" alt="PlanTrip">
    </a>

    <nav class="nav">
      <a href="/">메인</a>
      <a href="/admin">관리자</a>
      <a href="/admin/members" style="font-weight:700;">회원관리</a>
    </nav>

    <div class="header-right">
      <div>${sessionScope.loginMember.MName} (ADMIN)</div>
      <form action="/members/logout" method="post" style="margin:0;">
        <button class="header-auth" type="submit">로그아웃</button>
      </form>
    </div>
  </div>
</header>

<main class="admin-wrap">
  <aside class="admin-side">
    <h3>관리자 메뉴</h3>
    <a class="admin-link" href="/admin">🏠 대시보드</a>
    <a class="admin-link" href="/admin/members">👥 회원 관리</a>
    <a class="admin-link" href="/admin/notices">📢 공지사항</a>
    <a class="admin-link" href="/admin/faqs">❓ FAQ</a>
    <a class="admin-link" href="/admin/inquiries">✉ 문의 관리</a>
    <hr class="hr-admin">
    <a class="admin-link" href="/">← 사용자 페이지</a>
  </aside>

  <section class="admin-main">
    <h2>회원 관리</h2>
    <p style="color:var(--admin-muted);margin:0 0 10px;">가입한 회원을 조회하고 검색할 수 있습니다.</p>

    <form class="search-row" method="get" action="/admin/members">
      <input type="text" name="kw" value="${kw}" placeholder="아이디/이름/이메일로 검색" />
      <button type="submit">검색</button>
    </form>
	
	<div style="display:flex; gap:8px; margin:0 0 14px; align-items:center;">
	  <a href="/admin/blacklist"
	     style="display:inline-flex; align-items:center; gap:6px;
	            padding:10px 14px; border:1px solid #ef4444; border-radius:10px;
	            background:#fff; color:#ef4444; text-decoration:none; font-weight:600;">
	    ⛔ 블랙리스트 지정
	  </a>

	  <span style="color:var(--admin-muted); font-size:13px;">
	    (블랙리스트 등록/해제는 여기서만 합니다)
	  </span>
	</div>

    <div style="margin:0 0 10px;color:var(--admin-muted);">
      <span class="badge">총 ${members.size()}명</span>
    </div>

    <table class="table">
      <thead>
        <tr>
          <th>번호</th>
          <th>아이디</th>
          <th>이름</th>
          <th>이메일</th>
          <th>권한</th>
          <th>가입일</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="u" items="${members}">
          <tr>
            <td>${u.MIdx}</td>
            <td>${u.MId}</td>
            <td>${u.MName}</td>
            <td>${u.MEmail}</td>
            <td>
              <c:choose>
                <c:when test="${u.MRole == 9}"><span class="badge">ADMIN</span></c:when>
                <c:otherwise><span class="badge">USER</span></c:otherwise>
              </c:choose>
            </td>
            <td>${u.MRegDate}</td>
          </tr>
        </c:forEach>

        <c:if test="${empty members}">
          <tr>
            <td colspan="6" style="padding:14px;color:#6b7280;">검색 결과가 없습니다.</td>
          </tr>
        </c:if>
      </tbody>
    </table>
  </section>
</main>

</body>
</html>

