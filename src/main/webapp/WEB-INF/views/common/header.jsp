<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<j:set var="isSupport" value="${fn:contains(pageContext.request.requestURI, '/support')}" />

<header class="header${isSupport ? ' is-support' : ''}" id="header">
  <div class="container header-inner">
    <div class="brand-top">
      <a class="brand-top" href="${pageContext.request.contextPath}/" title="홈으로 돌아가기">
        <img class="brand-logo-img" src="${pageContext.request.contextPath}/img/PlanTriplog.png" alt="PlanTrip">
      </a>
    </div>

    <nav class="nav pt-nav">
      <a href="${pageContext.request.contextPath}/spots/spot" class="pt-wave">추천 여행지 목록</a>
      <a href="${pageContext.request.contextPath}/plans/planRoute" class="pt-wave">여행 계획</a>
      <a href="${pageContext.request.contextPath}/community" class="pt-wave">커뮤니티</a>
      <a href="${pageContext.request.contextPath}/maps" class="pt-wave">지도</a>

      <div class="nav-dropdown" id="transportWrap">
        <button class="nav-drop-btn pt-wave" type="button" id="transportBtn"
                aria-haspopup="true" aria-expanded="false">
          교통수단 <span class="chev" aria-hidden="true">▾</span>
        </button>

        <div class="nav-drop-menu" id="transportMenu" role="menu" aria-label="교통수단">
          <a href="${pageContext.request.contextPath}/transport/flight">항공권</a>
          <a href="${pageContext.request.contextPath}/transport/expbus">버스</a>
          <a href="${pageContext.request.contextPath}/transport/train">기차</a>
        </div>
      </div>

      <j:if test="${not empty sessionScope.loginMember}">
        <a href="${pageContext.request.contextPath}/members/mypage" class="pt-wave">마이페이지</a>
      </j:if>
    </nav>

    <div class="header-right">
      <j:if test="${empty sessionScope.loginMember}">
        <a class="header-auth" href="#" data-auth-open="login">로그인</a>
        <a class="header-auth" href="#" data-auth-open="signup">회원가입</a>
      </j:if>

      <j:if test="${not empty sessionScope.loginMember}">
        <a class="header-link" href="${pageContext.request.contextPath}/reservations">내 예약</a>

        <div class="hamburger" id="hmWrap">
          <button class="hamburger-btn" type="button" id="hmBtn"
                  aria-label="메뉴" aria-haspopup="true" aria-expanded="false">
            <span></span><span></span><span></span>
          </button>

          <div class="hamburger-menu" id="hm" role="menu" aria-label="메뉴">
            <div class="hm-title">
              ${sessionScope.loginMember.MName}님
              <span class="hm-role">
                <j:choose>
                  <j:when test="${sessionScope.loginMember.MRole == 9}">(관리자)</j:when>
                  <j:otherwise>(회원)</j:otherwise>
                </j:choose>
              </span>
            </div>
            <j:if test="${sessionScope.loginMember.MRole == 9}">
              <a class="menu-item" href="${pageContext.request.contextPath}/admin">관리자</a>
            </j:if>
            <a class="menu-item" href="${pageContext.request.contextPath}/members/mypage">마이페이지</a>
            <a class="menu-item" href="${pageContext.request.contextPath}/plan">내 여행 계획</a>

            <div class="hm-divider"></div>

            <form action="${pageContext.request.contextPath}/members/logout" method="post" style="margin:0;">
              <button class="menu-btn" type="submit">로그아웃</button>
            </form>
          </div></div>
        </div>
      </j:if>

      <%-- 다크/라이트 토글은 임시 보류(주석 유지) --%>
      <%-- <button type="button" class="theme-toggle" id="themeToggle">🌓</button> --%>
    </div>
  </div>
</header>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    // 1) 요소 가져오기
    const hmBtn = document.getElementById('hmBtn');
    const hmMenu = document.getElementById('hm');
    const transportBtn = document.getElementById('transportBtn');
    const transportWrap = document.getElementById('transportWrap');

    // 2) 공통 토글 함수
    function toggleMenu(target, other) {
      if (!target) return;
      const isOpen = target.classList.contains('open');

      if (other) other.classList.remove('open');
      target.classList.toggle('open', !isOpen);

      if (target.id === 'hm' && hmBtn) {
        hmBtn.setAttribute('aria-expanded', String(!isOpen));
      }
      if (target.id === 'transportWrap' && transportBtn) {
        transportBtn.setAttribute('aria-expanded', String(!isOpen));
      }
    }

    // 3) 이벤트 연결
    if (hmBtn && hmMenu) {
      hmBtn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        toggleMenu(hmMenu, transportWrap);
      });
    }

    if (transportBtn && transportWrap) {
      transportBtn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        toggleMenu(transportWrap, hmMenu);
      });
    }

    // 4) 바깥 클릭 시 모두 닫기
    document.addEventListener('click', function () {
      if (hmMenu) hmMenu.classList.remove('open');
      if (transportWrap) transportWrap.classList.remove('open');
      if (hmBtn) hmBtn.setAttribute('aria-expanded', 'false');
      if (transportBtn) transportBtn.setAttribute('aria-expanded', 'false');
    });

    // 5) ✅ 현재 페이지 active 표시 (컨텍스트 경로 포함 href 정상 처리)
    const currentPath = window.location.pathname; // 예: /plantrip/community 또는 /community (환경별)
    const navLinks = document.querySelectorAll('.pt-nav a.pt-wave');
    const ctx = '${pageContext.request.contextPath}'; // 예: /plantrip 또는 ""

    function normalize(path) {
      if (!path) return '/';
      // 컨텍스트 경로가 있으면 제거해서 순수 경로만 비교
      if (ctx && path.startsWith(ctx)) return path.substring(ctx.length) || '/';
      return path;
    }

    const now = normalize(currentPath); // 예: /community

    // a 링크 active 처리
    navLinks.forEach(link => {
      const href = link.getAttribute('href');
      if (!href) return;

      // href를 pathname으로 안전하게 파싱 (상대/절대 모두 대응)
      let linkPath = '/';
      try {
        linkPath = new URL(href, window.location.origin).pathname;
      } catch (e) {
        linkPath = href;
      }
      const target = normalize(linkPath);

      // 정확 매칭 + 하위 경로 매칭
      const isMatch = (now === target) || (target !== '/' && now.startsWith(target + '/'));

      if (isMatch) link.classList.add('active');
    });

    // 교통수단 버튼 active 처리 (/transport/*)
    if (transportBtn) {
      if (now === '/transport' || now.startsWith('/transport/')) {
        transportBtn.classList.add('active');
      }
    }
  });
</script>

<!-- 공통: 스크롤 시 헤더 숨김/표시 -->
<script src="${pageContext.request.contextPath}/js/header-scroll.js"></script>