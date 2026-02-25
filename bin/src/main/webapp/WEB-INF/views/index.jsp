<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>PlanTrip</title>

  <!--welcome to the PlanTrip 폰트임-->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Dancing+Script:wght@400;600;700&display=swap" rel="stylesheet">


    <link rel="stylesheet" href="/css/home.css" />
    <link rel="stylesheet" href="/css/auth-modal.css" />
    <link rel="stylesheet" href="/css/ui-toast.css" />

    <script defer src="/js/ui-toast.js"></script>
    <script defer src="/js/theme.js"></script>
    <script defer src="/js/auth-modal.js"></script>
    <script defer src="/js/auth-guard.js"></script>
    <script defer src="/js/pages/index.js"></script>
    <script defer src="/js/scrollbar-auto.js"></script>

	</head>

<body>

<header class="header" id="header">
  <div class="container header-inner">
    <div class="brand-top">
      <a class="brand-top" href="/" title="홈으로 돌아가기" aria-label="홈으로 돌아가기">
        <img class="brand-logo-img" src="/img/PlanTriplog.png" alt="PlanTrip">
      </a>
    </div>

    <nav class="nav">
<a href="${pageContext.request.contextPath}/spots/list" >추천 여행지 목록</a>
      <a href="/plan">여행 계획</a>
      <a href="/community">커뮤니티</a>
      <a href="/maps">지도</a>
	  <div class="nav-dropdown" id="transportWrap">
	      <button class="nav-drop-btn" type="button" id="transportBtn" aria-haspopup="true" aria-expanded="false">
	        교통수단 <span class="chev" aria-hidden="true">▾</span>
	      </button>

	      <div class="nav-drop-menu" id="transportMenu" role="menu" aria-label="교통수단">
	        <a href="${pageContext.request.contextPath}/transport/flight">항공권</a>
	        <a href="${pageContext.request.contextPath}/transport/expbus">버스</a>
	        <a href="${pageContext.request.contextPath}/transport/train">기차</a>
	      </div>
	    </div>

      <j:if test="${not empty sessionScope.loginMember}">
        <a href="/members/mypage">마이페이지</a>
      </j:if>
    </nav>

    <div class="header-right">
		<!-- 비로그인: 글자 링크만 -->
		 <j:if test="${empty sessionScope.loginMember}">
		   <a class="header-auth" href="/members/login" data-auth-open="login">로그인</a>
		   <a class="header-auth" href="/members/register" data-auth-open="signup">회원가입</a>
		 </j:if>

		  <!--로그인: 내 예약 + 햄버거--> 
		 <j:if test="${not empty sessionScope.loginMember}">
		   <a class="header-link" href="/reservations">내 예약</a>

		   <div class="hamburger" id="hmWrap">
		     <button class="hamburger-btn" type="button" id="hmBtn" aria-label="메뉴" aria-haspopup="true" aria-expanded="false">
		       <span></span><span></span><span></span>
			
		     </button>
		  <!--✅ hm은 딱 1개만 존재 -->
		            <div class="hamburger-menu" id="hm" role="menu" aria-label="메뉴">
		              <div class="hm-title">
		                ${sessionScope.loginMember.MName}님
		                <span class="hm-role">
		                  <j:if test="${sessionScope.loginMember.MRole == 9}">(관리자)</j:if>
		                  <j:if test="${sessionScope.loginMember.MRole != 9}">(회원)</j:if>
		                </span>
		              </div>
		              <a class="menu-item" href="/profile">프로필</a>
		              <a class="menu-item" href="/members/mypage">마이페이지</a>
		              <a class="menu-item" href="/plan">내 여행 계획</a>

		              
		              <j:if test="${sessionScope.loginMember.MRole == 9}">
		                <a class="menu-item" href="/admin">관리자</a>
		              </j:if>

		              <div class="hm-divider"></div>

		              <form action="/members/logout" method="post" style="margin:0;">
		                <button class="menu-btn" type="submit">로그아웃</button>
		              </form>
		            </div>
		          </div>
		        </j:if>
		  		  <button type="button" class="theme-toggle" id="themeToggle">🌙</button>
		      </div>
		    </div>
</header>



<main>
  <section class="hero">
    <div class="hero-copy hero-copy--top">
      <div class="hero-pill hero-title">Wellcome to PlanTrip</div>
    </div>

    <!-- ✅ searchbar 내부에 다른 div 넣지 말기(레이아웃 밀림 방지) -->
    <div class="searchbar">
      <div class="sb-item">
        <div class="sb-icon"></div>
        <input type="text" placeholder="목적지를 입력해주세요" />
      </div>

      <div class="sb-item">
        <div class="sb-icon"></div>
        <input type="date" placeholder="연도-월-일" />
      </div>

      <div class="sb-item sb-select">
        <div class="sb-icon"></div>
        <select aria-label="인원" name="people" required>
          <option value="" selected disabled>인원</option>
          <option value="1">1인</option>
          <option value="2">2인</option>
          <option value="3">3인</option>
          <option value="4+">4인 이상</option>
        </select>
      </div>

      <button class="sb-btn" type="button">검색</button>
    </div>

    <a class="scroll-down" href="#sheet" aria-label="아래로 스크롤"></a>
  </section>

  <section class="sheet" id="sheet">
    <div class="container">
		 <section class="block">
		        <div class="block-head">
		          <h2 class="block-title">인기 여행지</h2>
		          <p class="block-sub">요즘 많이 찾는 여행지로 추천 해드려요 !</p>
		        </div>

		        <div class="marquee" data-marquee>
		          <div class="marquee__track" data-marquee-track>
		            <a class="post-card" href="/spot/sea">
		              <div class="post-img" style="background-image:url('/img/sea.jpg')"></div>
		              <div class="post-body">
		                <div class="post-title">바다 감성 여행</div>
		                <div class="post-meta">테마 · 인기</div>
		                <div class="post-tags">
		                  <span class="tag">#바다</span>
		                  <span class="tag">#감성</span>
		                </div>
		              </div>
		            </a>

		            <a class="post-card" href="/spot/city">
		              <div class="post-img" style="background-image:url('/img/hero.jpg')"></div>
		              <div class="post-body">
		                <div class="post-title">도심 힐링 코스</div>
		                <div class="post-meta">테마 · 인기</div>
		                <div class="post-tags">
		                  <span class="tag">#힐링</span>
		                  <span class="tag">#카페</span>
		                </div>
		              </div>
		            </a>

		            <a class="post-card" href="/spot/mountain">
		              <div class="post-img" style="background-image:url('/img/mountain.jpg')"></div>
		              <div class="post-body">
		                <div class="post-title">산/자연 코스</div>
		                <div class="post-meta">테마 · 인기</div>
		                <div class="post-tags">
		                  <span class="tag">#자연</span>
		                  <span class="tag">#트레킹</span>
		                </div>
		              </div>
		            </a>

		            <a class="post-card" href="/spot/food">
		              <div class="post-img" style="background-image:url('/img/main.jpg')"></div>
		              <div class="post-body">
		                <div class="post-title">맛집 투어</div>
		                <div class="post-meta">테마 · 인기</div>
		                <div class="post-tags">
		                  <span class="tag">#맛집</span>
		                  <span class="tag">#현지</span>
		                </div>
		              </div>
		            </a>
		          </div>
		        </div>
		      </section>

		      <section class="block block-recommend">
		        <div class="course-head">
		          <div class="course-head-left block-head">
		            <h2 class="block-title">맞춤형 여행 코스</h2>
		            <p class="block-sub">원하는 지역과, 원하는 도시를 선택해서 본인에 맞는 맞춤형 여행 코스를 추천해드려요!</p>
		          </div>

		          <div class="course-head-right">
		            <div class="segmented" role="tablist" aria-label="추천 일정 탭">
		              <button class="seg-btn active" type="button">국내</button>
		            </div>
		          </div>
		        </div>

		        <div class="citybar" id="domesticBar"></div>

		        <div class="recommend-wrap">
		          <button class="arrow-btn arrow-left" type="button" aria-label="이전" onclick="scrollRecommend(-1)">
		            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
		              stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
		              <polyline points="15 18 9 12 15 6"></polyline>
		            </svg>
		          </button>

		          <div class="cards" id="recommendCards"></div>

		          <button class="arrow-btn arrow-right" type="button" aria-label="다음" onclick="scrollRecommend(1)">
		            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
		              stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
		              <polyline points="9 18 15 12 9 6"></polyline>
		            </svg>
		          </button>
		        </div>
		      </section>

		    </div>
		  </section>
		</main>
		
		<!-- Floating 고객센터 -->
		<a class="cs-fab" href="/support" aria-label="고객센터">
		  <span class="cs-fab__icon" aria-hidden="true">?</span>
		  <span class="cs-fab__label">고객센터</span>
		</a>

		<%@ include file="/WEB-INF/views/common/authModal.jspf" %>

</body>
</html>
