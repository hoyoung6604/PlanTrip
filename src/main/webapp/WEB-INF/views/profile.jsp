<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>프로필</title>
  
  <link rel="stylesheet" href="/css/theme-sky.css" />
<link rel="stylesheet" href="/css/home.css"/>
  <link rel="stylesheet" href="/css/auth-modal.css" />
  <link rel="stylesheet" href="/css/ui-toast.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/auth-modal.js"></script>
  <script defer src="/js/auth-guard.js"></script>

</head>
<body>
  <div class="container" style="padding:24px 0;">
    <h1 style="margin:0 0 12px; font-size:24px;">프로필</h1>
    <p style="margin:0 0 16px; color:#6b7280;">프로필 수정/조회 기능을 연결할 예정입니다.</p>
    <a class="btn solid" href="/">홈으로</a>
  </div>

  <%@ include file="/WEB-INF/views/common/authModal.jspf" %>

</body>
</html>
