<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>

<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>관리자 메인 | PlanTrip</title>
<link rel="stylesheet" href="/css/home.css">

<style>
/* ===== 관리자 페이지: 흰 배경 고정(테마 상관없이 항상 잘 보이게) ===== */
:root{
  --admin-bg: #ffffff;
  --admin-text: #111111;
  --admin-muted: rgba(17,17,17,.70);
  --admin-border: rgba(0,0,0,.12);
  --admin-hover: rgba(0,0,0,.04);
}

.admin-wrap{
  max-width:1200px;
  margin:0 auto;
  padding:30px;
  display:grid;
  grid-template-columns:240px 1fr;
  gap:20px;
}

/* 카드 영역(좌측/메인/통계)은 흰색 */
.admin-side,
.admin-main,
.stat{
  background: var(--admin-bg) !important;
  color: var(--admin-text) !important;
  border: 1px solid var(--admin-border) !important;
  border-radius:14px;
}

.admin-side{ padding:18px; }
.admin-main{ padding:22px; }

.admin-side h3,
.admin-main h2,
.admin-main h4{
  margin: 0 0 10px;
  color: var(--admin-text) !important;
}

.admin-main p{
  margin: 0 0 14px;
  color: var(--admin-muted) !important;
}

.admin-link{
  display:block;
  padding:12px;
  border-radius:10px;
  margin-bottom:10px;
  text-decoration:none;
  background: #fff !important;
  color: var(--admin-text) !important;
  border: 1px solid var(--admin-border) !important;
}

.admin-link:hover{
  background: var(--admin-hover) !important;
}

.hr-admin{
  border:0;
  border-top:1px solid var(--admin-border);
  margin:14px 0;
}

/* 통계 */
.stat-box{
  display:grid;
  grid-template-columns:repeat(3,1fr);
  gap:12px;
  margin-top:16px;
}

.stat{
  padding:16px;
  border-radius:12px;
}

.stat-title{ color: var(--admin-muted) !important; font-size:13px; }
.stat-value{ color: var(--admin-text) !important; font-size:22px; font-weight:800; margin-top:6px; }

/* 반응형 */
@media (max-width: 960px){
  .admin-wrap{ grid-template-columns: 1fr; }
}

/* ===== 헤더도 흰색으로 보이게(선택: home.css가 다크에서 글씨 안 보이면 필요) ===== */
.header.is-solid{
  background:#fff !important;
  border-bottom: 1px solid rgba(0,0,0,.10);
}
.header.is-solid .nav a,
.header.is-solid .header-right,
.header.is-solid .header-auth{
  color:#111 !important;
}
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
      <a href="/admin" style="font-weight:700;">관리자</a>
	  <a href="/admin/members">회원관리</a>
    </nav>

    <div class="header-right">
      <!-- 너가 말한대로 MName 유지 -->
	  <div>${sessionScope.loginMember.getMName()} (ADMIN)</div>

      <form action="/members/logout" method="post" style="margin:0;">
        <button class="header-auth" type="submit">로그아웃</button>
      </form>

      <button type="button" class="theme-toggle" id="themeToggle">🌙</button>
    </div>
  </div>
</header>

<main class="admin-wrap">

  <!-- 좌측 메뉴 -->
  <aside class="admin-side">
    <h3>관리자 메뉴</h3>

    <a class="admin-link" href="/admin">🏠 대시보드</a>
    <a class="admin-link" href="/admin/notices">📢 공지사항</a>
    <a class="admin-link" href="/admin/faqs">❓ FAQ</a>
    <a class="admin-link" href="/admin/inquiries">✉ 문의 관리</a>
	<a class="admin-link" href="/admin/members">👥 회원 관리</a>

    <hr class="hr-admin">

    <a class="admin-link" href="/">← 사용자 페이지</a>
  </aside>

  <!-- 메인 -->
  <section class="admin-main">
    <h2>관리자 대시보드</h2>
    <p>PlanTrip 관리자 메인 페이지</p>
	<c:if test="${not empty msg}">
	  <div style="margin:12px 0; padding:12px; border:1px solid #e5e7eb; border-radius:12px; background:#fff;">
	    ${msg}
	  </div>
	</c:if>

    <div class="stat-box">
      <div class="stat">
        <div class="stat-title">미처리 문의</div>
        <div class="stat-value">${pendingQnaCount}</div>
      </div>
	</div>

    <div style="margin-top:26px;">
      <h4>빠른 이동</h4>
      <a class="admin-link" href="/admin/notices">공지 작성</a>
      <a class="admin-link" href="/admin/faqs">FAQ 작성</a>
      <a class="admin-link" href="/admin/inquiries">문의 답변</a>
    </div>
  </section>

</main>

<script>
(function(){
  const root = document.documentElement;
  const key = "plantrip-theme";

  function apply(t){
    root.dataset.theme = t;
    const btn = document.getElementById("themeToggle");
    if(btn) btn.textContent = (t === "light") ? "☀️" : "🌙";
  }

  apply(localStorage.getItem(key) || "dark");

  document.getElementById("themeToggle")?.addEventListener("click", function(){
    const next = (root.dataset.theme === "light") ? "dark" : "light";
    localStorage.setItem(key, next);
    apply(next);
  });
})();
</script>

</body>
</html>
