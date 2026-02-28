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
    <script defer src="/js/header-scroll.js"></script>

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
<a href="${pageContext.request.contextPath}/spots/spot" >추천 여행지 목록</a>
      <a href="${pageContext.request.contextPath}/plans/planRoute">여행 계획</a>
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
		              <j:if test="${sessionScope.loginMember.MRole == 9}">
		                <a class="menu-item" href="/admin">관리자</a>
		              </j:if>
		              
		              <a class="menu-item" href="/members/mypage">마이페이지</a>
		              <a class="menu-item" href="/plan">내 여행 계획</a>

		              

		              <div class="hm-divider"></div>

		              <form action="/members/logout" method="post" style="margin:0;">
		                <button class="menu-btn" type="submit">로그아웃</button>
		              </form>
		            </div>
		          </div>
		        </j:if>
		  		  <%-- <button type="button" class="theme-toggle" id="themeToggle">🌙</button> --%>
		      </div>
		    </div>
</header>



<main>
  <section class="hero">
    <div class="hero-copy hero-copy--top">
      <div class="hero-pill hero-title">Welcome to the PlanTrip</div>
    </div>

	<div class="searchbar">
	  <div class="sb-item">
	    <div class="sb-icon"></div>
	    <input type="text" id="mainSearchInput" placeholder="목적지를 입력해주세요" />
	  </div>

	  <button class="sb-btn" type="button" onclick="executeSearch()">검색</button>
	</div>

    <a class="scroll-down" href="#recommendSection" aria-label="아래로 스크롤"></a>
  </section>

  
  <section class="sheet" id="sheet">
    <div class="container">
		<section class="block">
		    <div class="block-head">
		        <h2 class="block-title">오늘의 인기 여행지 </h2>
		        <p class="block-sub block-sub--hint">매일 새로운 6개의 여행지를 추천해 드립니다!</p>
		    </div>

		    <div class="marquee" data-marquee>
		        <div class="marquee__track" data-marquee-track>
		            <j:forEach var="s" items="${popularSpots}">
		                <a class="post-card" href="${pageContext.request.contextPath}/spots/detail/${s.id}">
		                    <div class="post-img" style="background-image:url('${s.image}')"></div>
		                    <div class="post-body">
		                        <div class="post-title">${s.name}</div>
		                        <div class="post-meta">${s.city.name} · 인기</div>
		                        <div class="post-tags">
		                            <span class="tag">#${s.city.name}</span>
		                            <span class="tag">#추천</span>
		                        </div>
		                    </div>
		                </a>
		            </j:forEach>
		            
		            <j:forEach var="s" items="${popularSpots}">
		                <a class="post-card" href="${pageContext.request.contextPath}/spots/detail/${s.id}">
		                    <div class="post-img" style="background-image:url('${s.image}')"></div>
		                    <div class="post-body">
		                        <div class="post-title">${s.name}</div>
		                        <div class="post-meta">${s.city.name} · 인기</div>
		                        <div class="post-tags">
		                            <span class="tag">#${s.city.name}</span>
		                            <span class="tag">#추천</span>
		                        </div>
		                    </div>
		                </a>
		            </j:forEach>
		        </div>
		    </div>
		</section>

		<section class="block block-recommend" id="recommendSection">
		  <div class="course-head" style="margin-bottom: 20px;">
		    <div class="course-head-left block-head">
		      <h2 class="block-title">맞춤형 여행 추천 </h2>
		    </div>
		  </div>

		  <div class="course-head-right" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
		    <div class="segmented" role="tablist">
		      <button class="seg-btn active" type="button" onclick="loadRecommend('TOUR', this)">관광지</button>
		      <button class="seg-btn" type="button" onclick="loadRecommend('STAY', this)">숙소</button>
		      <button class="seg-btn" type="button" onclick="loadRecommend('ACT', this)">문화/액티비티</button>
		      <button class="seg-btn" type="button" onclick="loadRecommend('FOOD', this)">맛집</button>
		    </div>

		    <p class="block-sub block-sub--hint">카테고리를 선택하시면 매일 새로운 장소를 추천해드려요!</p>
		  </div>

		  <div class="recommend-wrap">
		    <button class="arrow-btn arrow-left" type="button" onclick="scrollRecommend(-1)">
		      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
		        <polyline points="15 18 9 12 15 6"></polyline>
		      </svg>
		    </button>

		    <div class="cards" id="recommendCards"></div>

		    <button class="arrow-btn arrow-right" type="button" onclick="scrollRecommend(1)">
		      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
		        <polyline points="9 18 15 12 9 6"></polyline>
		      </svg>
		    </button>
		  </div>
		</section>

		</main>
		
		<%@ include file="/WEB-INF/views/common/footer.jspf" %>
			
		
		

		<%@ include file="/WEB-INF/views/common/authModal.jspf" %>

</body>
<script>
function getCatName(code) {
    const map = { 'TOUR': '관광지', 'STAY': '숙소', 'ACT': '액티비티', 'FOOD': '맛집' };
    return map[code] || '추천';
}

function loadRecommend(catCode, btn) {
    if (btn) {
        document.querySelectorAll('.seg-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
    }

    fetch('/spots/api/recommend?category=' + catCode)
        .then(res => res.json())
        .then(data => {
            const container = document.getElementById('recommendCards');
            if (!container) return;
            container.innerHTML = '';

			data.forEach(spot => {
			    const card = document.createElement('a');
			    card.className = 'post-card';
			    card.href = '/spots/detail/' + spot.id; // 백틱 대신 일반 문자열 결합 사용 (안전함)
// innerHTML 내의 변수들도 일반 따옴표 결합 방식으로 작성하여 JSP 에러 방지
			    card.innerHTML = 
			        '<div class="post-img" style="background-image:url(\'' + (spot.image || '/img/default.jpg') + '\'); height: 250px; border-radius: 24px 24px 0 0;"></div>' +
			        '<div class="post-body" style="padding: 24px; background: #fff; border-radius: 0 0 24px 24px;">' +
			            '<div class="post-title" style="font-size: 20px; font-weight: 700; margin-bottom: 8px;">' + spot.name + '</div>' +
			            '<div class="post-meta" style="color: #6b7280; font-size: 14px;">' + spot.cityName + ' · 인기 추천</div>' +
			            '<div class="post-tags" style="margin-top: 15px; display: flex; gap: 8px;">' +
			                '<span class="tag">#' + getCatName(catCode) + '</span>' +
			            '</div>' +
			        '</div>';
			    container.appendChild(card);
			});
            container.scrollLeft = 0;
        })
        .catch(err => console.error("Error:", err));
}

// 스크롤 시 한 페이지(3개 카드)씩 이동
function scrollRecommend(direction) {
    const container = document.getElementById('recommendCards');
    if(container) {
        const scrollAmount = container.clientWidth + 24; 
        container.scrollBy({ left: direction * scrollAmount, behavior: 'smooth' });
    }
}

document.addEventListener('DOMContentLoaded', () => loadRecommend('TOUR'));
</script>
</html>