<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>여행 지도</title>
    
  <link rel="stylesheet" href="/css/theme-sky.css" />
<meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- 공통 CSS -->
    <link rel="stylesheet" href="/css/home.css">
    <link rel="stylesheet" href="/css/maps.css">

    <!-- ✅ 카카오 지도 API (autoload=false로 바꿔서, load() 안에서 초기화) -->
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a3ff57f5cf42d50dce5ccbd693ebcf24&libraries=services&autoload=false"></script>
<!--
    <style>
        #map {
            width: 100%;
            height: calc(100vh - 140px);
        }

        .map-search {
            display: flex;
            gap: 8px;
            padding: 10px;
            background: #fff;
            border-bottom: 1px solid #ddd;
        }

        .map-search input {
            flex: 1;
            padding: 8px;
            font-size: 14px;
        }

        .map-search button {
            padding: 8px 16px;
            background: #333;
            color: #fff;
            border: none;
            cursor: pointer;
        }

        .info-window {
            padding: 8px;
            font-size: 13px;
            line-height: 1.4;
        }
        .info-window b {
            font-size: 14px;
        }
    </style>-->
  <link rel="stylesheet" href="/css/auth-modal.css" />
  <link rel="stylesheet" href="/css/ui-toast.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/auth-modal.js"></script>
  <script defer src="/js/auth-guard.js"></script>

</head>

<!-- ✅ 지도 페이지 전용 클래스 -->
<body class="maps-page">

<header class="header is-solid">
  <div class="header-inner container">
    <a href="/" class="brand-top">
      <img src="/img/PlanTriplog.png" alt="여행 플래너" class="brand-logo-img">
    </a>

    <nav class="nav">
      <a href="/plan" class="header-link">여행 계획</a>
      <a href="/maps" class="header-link active">지도</a>

      <div class="hamburger">
        <button class="hamburger-btn" type="button"
                onclick="document.getElementById('hm').classList.toggle('open')">
          <span></span><span></span><span></span>
        </button>

        <div class="hamburger-menu" id="hm">
          <c:choose>
            <c:when test="${empty sessionScope.loginMember}">
              <a class="menu-item" href="/members/login" data-auth-open="login">로그인</a>
              <a class="menu-item" href="/members/register" data-auth-open="signup">회원가입</a>
            </c:when>
            <c:otherwise>
              <div class="hm-title">
                ${sessionScope.loginMember.MName}님
                <span class="hm-role">
                  <c:if test="${sessionScope.loginMember.MRole == 9}">(관리자)</c:if>
                  <c:if test="${sessionScope.loginMember.MRole != 9}">(회원)</c:if>
                </span>
              </div>

              <a class="menu-item" href="/profile">프로필</a>
              <a class="menu-item" href="/members/mypage">마이페이지</a>
              <a class="menu-item" href="/plan">내 여행 계획</a>

              <c:if test="${sessionScope.loginMember.MRole == 9}">
                <a class="menu-item" href="/admin">관리자</a>
              </c:if>

              <div class="hm-divider"></div>

              <form action="/members/logout" method="post" style="margin:0;">
                <button class="menu-btn" type="submit">로그아웃</button>
              </form>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </nav>
  </div>
</header>

<div class="map-search">
    <input type="text" id="keyword" placeholder="지역 또는 장소 검색 (예: 강남, 부산, 카페)">
    <button type="button" id="searchBtn">검색</button>
</div>

<div id="map"></div>

<script defer src="/js/pages/maps.js"></script>


  <%@ include file="/WEB-INF/views/common/authModal.jspf" %>

</body>
</html>
