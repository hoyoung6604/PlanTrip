<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <!-- [추가] 모바일 화면 비율/스케일 최적화 (없으면 폰에서 레이아웃이 깨져 보일 수 있어요) -->
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>마이페이지</title>
  
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
  <link rel="stylesheet" href="/css/auth-modal.css" />
  <link rel="stylesheet" href="/css/ui-toast.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/auth-modal.js"></script>
  <script defer src="/js/auth-guard.js"></script>

</head>
<body>

<c:set var="displayName" value="사용자" />
<c:choose>
  <c:when test="${not empty sessionScope.loginUserName}">
    <c:set var="displayName" value="${sessionScope.loginUserName}" />
  </c:when>
  <c:when test="${not empty sessionScope.loginMember and not empty sessionScope.loginMember.MName}">
    <c:set var="displayName" value="${sessionScope.loginMember.MName}" />
  </c:when>
  <c:when test="${not empty sessionScope.member and not empty sessionScope.member.MName}">
    <c:set var="displayName" value="${sessionScope.member.MName}" />
  </c:when>
  <c:when test="${not empty pageContext.request.userPrincipal}">
    <c:set var="displayName" value="${pageContext.request.userPrincipal.name}" />
  </c:when>
</c:choose>

<div class="mp-shell">

  <aside class="mp-side">
    <div class="mp-brand">
      <div class="mp-logo"></div>
      <div class="mp-brand-name"><c:out value="${displayName}"/></div>
    </div>

    <div class="sec">
      <div class="sec-title">OVERVIEW</div>
      <nav class="mp-nav">
        <a class="active" href="${pageContext.request.contextPath}/members/mypage">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none"><path d="M4 13h7V4H4v9Zm9 7h7V11h-7v9ZM4 20h7v-5H4v5Zm9-16v5h7V4h-7Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg>
          </span>대시보드
        </a>
        <a href="${pageContext.request.contextPath}/members/mypage/check">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none"><path d="M12 20h9" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4 11.5-11.5Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg>
          </span>회원정보 수정
        </a>
        <a href="${pageContext.request.contextPath}/members/mypage/plans">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none"><path d="M7 3v3M17 3v3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M4 8h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M5 6h14a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg>
          </span>내 여행 계획
        </a>
        <a href="${pageContext.request.contextPath}/members/mypage/reviews">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none"><path d="M7 3h8l4 4v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M15 3v5h5" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M8 13h8M8 17h8" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
          </span>내 여행 후기
        </a>
      </nav>
    </div>

    <div class="sec sec-bottom">
      <div class="sec-title">SETTINGS</div>
      <nav class="mp-nav">
		<button class="menu-btn" type="button" onclick="location.href='${pageContext.request.contextPath}/'">

          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none"><path d="M3 10.5 12 3l9 7.5V21a2 2 0 0 1-2 2h-4v-7H9v7H5a2 2 0 0 1-2-2V10.5Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg>
          </span>메인으로
        </button>

        <form action="${pageContext.request.contextPath}/members/logout" method="post" style="margin:0;">
          <button class="menu-btn danger" type="submit">
            <span class="mp-ico" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none"><path d="M10 17l-1 0a4 4 0 0 1-4-4V7a4 4 0 0 1 4-4h1" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M15 7l5 5-5 5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M20 12H10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
            </span>로그아웃
          </button>
        </form>
      </nav>
    </div>
  </aside>

  <main class="mp-main">
    <div class="mp-topbar">
      <div class="mp-search">
        <span class="sico" aria-hidden="true">
          <svg viewBox="0 0 24 24" fill="none">
            <path d="M10.5 18a7.5 7.5 0 1 1 0-15 7.5 7.5 0 0 1 0 15Z" stroke="currentColor" stroke-width="1.8"/>
            <path d="M16.5 16.5 21 21" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
          </svg>
        </span>
        <input type="text" placeholder="Search your travel..." />
      </div>
    </div>

    <div class="mp-placeholder"></div>

    <section class="mp-card mp-grow">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">수정이 필요한 카드덱</div>
          <div class="mp-card-sub">지금은 임시 카드이며, 추후 여행 추천/인기 콘텐츠로 교체 예정</div>
        </div>
      </div>

      <div class="mp-card-body">
        <div class="mp-deck">
          <div class="item">
            <div class="thumb"></div>
            <div class="meta">
              <span class="tag">RECOMMEND</span>
              <div class="ttl">여행 일정 짜기, 어디서부터?</div>
              <div class="sub">초보자를 위한 간단 가이드</div>
            </div>
          </div>

          <div class="item">
            <div class="thumb"></div>
            <div class="meta">
              <span class="tag">SPOT</span>
              <div class="ttl">제주 2박 3일 루트 예시</div>
              <div class="sub">동선 줄이는 코스 구성</div>
            </div>
          </div>

          <div class="item">
            <div class="thumb"></div>
            <div class="meta">
              <span class="tag">TIP</span>
              <div class="ttl">예산/시간 관리 체크리스트</div>
              <div class="sub">계획이 흐트러지지 않게</div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>

  <aside class="mp-right">
    <section class="mp-profile">
      <div class="mp-profile-top">
        <div class="ttl">내 계정</div>
        <div class="mp-mini"></div>
      </div>

      <div class="name"><c:out value="${displayName}"/></div>
      <div class="desc">계정 정보 및 여행 기록을 확인할 수 있어요</div>

      <div class="mp-list">
        <div class="mp-row">
          <div class="left">
            <div class="ttl">회원정보 수정</div>
            <div class="sub">비밀번호 확인 후 수정</div>
          </div>
          <span class="mp-pill" onclick="location.href='${pageContext.request.contextPath}/members/mypage/check'">이동</span>
        </div>
      </div>
    </section>

    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">내 여행 계획</div>
          <div class="mp-card-sub">최근 작성한 계획</div>
        </div>
        <button class="mp-btn" onclick="location.href='${pageContext.request.contextPath}/members/mypage/plans'">전체보기</button>
      </div>
      <div class="mp-card-body">
        <div class="mp-list">
          <div class="mp-row">
            <div class="left">
              <div class="ttl">제주 2박 3일</div>
              <div class="sub">2026-03-12 ~ 2026-03-14</div>
            </div>
            <span class="mp-pill">예정</span>
          </div>
          <div class="mp-row">
            <div class="left">
              <div class="ttl">부산 당일치기</div>
              <div class="sub">2026-04-01</div>
            </div>
            <span class="mp-pill">예정</span>
          </div>
        </div>
      </div>
    </section>

    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">내 여행 후기</div>
          <div class="mp-card-sub">최근 작성한 후기</div>
        </div>
        <button class="mp-btn" onclick="location.href='${pageContext.request.contextPath}/members/mypage/reviews'">전체보기</button>
      </div>
      <div class="mp-card-body">
        <div class="mp-list">
          <div class="mp-row">
            <div class="left">
              <div class="ttl">제주 여행 후기</div>
              <div class="sub">작성일: 2026-04-03</div>
            </div>
            <span class="mp-pill">완료</span>
          </div>
          <div class="mp-row">
            <div class="left">
              <div class="ttl">강릉 여행 후기</div>
              <div class="sub">작성일: 2026-05-10</div>
            </div>
            <span class="mp-pill">완료</span>
          </div>
        </div>
      </div>
    </section>
  </aside>

</div>


  <%@ include file="/WEB-INF/views/common/authModal.jspf" %>

</body>
</html>
