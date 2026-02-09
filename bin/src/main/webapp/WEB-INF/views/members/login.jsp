<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>로그인 | 여행 플래너</title>
  <link rel="stylesheet" href="/css/login.css">
  <script src="/js/alert.js"></script>
</head>
<body>
  <div class="auth-wrap">
    <div class="auth-left">
      <div class="brand">
        <div class="logo">TP</div>
        <div class="title">여행 플래너</div>
      </div>

      <form class="form" action="/members/login" method="post">
        <div class="label">아이디</div>
        <input class="input" name="id" type="text" placeholder="아이디" required />

        <div class="label">비밀번호</div>
        <div class="input-row">
          <input class="input" name="password" type="password" placeholder="비밀번호" required />
          <span class="eye">👁</span>
        </div>

        <div style="text-align:right; margin-top: -6px;">
          <a class="underline small" href="#">비밀번호를 잊으셨나요?</a>
        </div>

        <button class="primary-btn" type="submit">로그인</button>

        <div class="social-row">
          <button class="social-btn" type="button">
            <span class="social-dot"></span> 구글
          </button>
          <button class="social-btn" type="button">
            <span class="social-dot"></span> 페이스북
          </button>
        </div>

        <div class="auth-footer">
          계정이 없으신가요? <a class="underline" href="/members/register"><b>회원가입</b></a>
        </div>

        <div class="auth-footer" style="margin-top:6px;">
          <a class="underline" href="/"><b>홈으로</b></a>
        </div>
      </form>
    </div>

    <div class="auth-right bg-mountain"></div>
  </div>

  <c:if test="${param.error eq 'true' || not empty loginError}">
    <script>
      showLoginError();
    </script>
  </c:if>

  <c:if test="${param.logout eq 'true'}">
    <script>
      showLogoutMessage();
    </script>
  </c:if>

</body>
</html>

