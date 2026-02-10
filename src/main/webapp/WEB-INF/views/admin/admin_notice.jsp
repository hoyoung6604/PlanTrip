<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>공지 작성 | 관리자</title>
  <link rel="stylesheet" href="/css/home.css"/>
  <style>
    .wrap{max-width:900px;margin:0 auto;padding:24px;}
    .card{background:#fff;color:#111;border:1px solid rgba(0,0,0,.12);border-radius:14px;padding:18px;}
    .row{margin:12px 0;}
    .label{font-weight:700;margin-bottom:6px;}
    .input,.textarea{width:100%;padding:12px;border-radius:10px;border:1px solid rgba(0,0,0,.15);outline:none;}
    .textarea{min-height:220px;resize:vertical;}
    .actions{display:flex;gap:10px;justify-content:flex-end;margin-top:14px;}
    .btn{padding:10px 12px;border-radius:10px;border:1px solid rgba(0,0,0,.15);background:#fff;cursor:pointer;}
    .btn.primary{background:#111;color:#fff;border-color:#111;}
  </style>
</head>
<body>

<header class="header is-solid">
  <div class="container header-inner">
    <a href="/admin" class="brand-top"><img class="brand-logo-img" src="/img/PlanTriplog.png" alt="PlanTrip"></a>
    <nav class="nav">
      <a href="/admin/notices">공지사항</a>
      <a href="/admin/notice" style="font-weight:700;">공지 작성</a>
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
    <h2 style="margin:0 0 6px;">공지 작성</h2>
    <p style="margin:0;opacity:.7;">작성 완료 후 공지사항 목록에서 확인할 수 있어요.</p>

    <form action="/admin/notice" method="post">
      <div class="row">
        <div class="label">제목</div>
        <input class="input" type="text" name="title" maxlength="200" required />
      </div>

      <div class="row">
        <label style="display:flex;align-items:center;gap:8px;">
          <input type="checkbox" name="isTop" value="1">
          <span>상단 고정</span>
        </label>
      </div>

      <div class="row">
        <div class="label">내용</div>
        <textarea class="textarea" name="cont" required></textarea>
      </div>

      <div class="actions">
        <a class="btn" href="/admin/notices" style="text-decoration:none;color:#111;">취소</a>
        <button class="btn primary" type="submit">작성 완료</button>
      </div>
    </form>
  </div>
</main>

</body>
</html>
