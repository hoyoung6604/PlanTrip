<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>회원가입 | 여행 플래너</title>
  <link rel="stylesheet" href="/css/signup.css">
</head>
<body>
  <div class="auth-wrap">
    <div class="auth-left">
      <div class="brand">
        <div class="logo">TP</div>
        <div class="title">여행 플래너</div>
      </div>

      <!-- ✅ Member 엔티티 필드명 기준: mName, mId, mEmail, mPw -->
      <form class="form" action="/members/register" method="post">
        <div class="label">이름</div>
        <input class="input" name="mName" type="text" placeholder="이름" required />

        <div class="label">아이디</div>
        <input class="input" name="mId" type="text" placeholder="아이디" required />

        <div class="label">이메일</div>
        <input class="input" name="mEmail" type="email" placeholder="이메일" required />

        <div class="label">비밀번호</div>
        <div class="input-row">
          <input class="input" name="mPw" type="password" placeholder="비밀번호" required />
          <span class="eye">👁</span>
        </div>

        <button class="primary-btn" type="submit">회원가입</button>

        <div class="auth-footer">
          이미 회원이신가요? <a class="underline" href="/members/login"><b>로그인</b></a>
        </div>

        <div class="auth-footer" style="margin-top:6px;">
          <a class="underline" href="/"><b>홈으로</b></a>
        </div>
      </form>
    </div>

    <div class="auth-right bg-mountain"></div>
  </div>

  <c:if test="${not empty error}">
    <script>
      alert("${error}");
    </script>
  </c:if>

</body>
</html>

