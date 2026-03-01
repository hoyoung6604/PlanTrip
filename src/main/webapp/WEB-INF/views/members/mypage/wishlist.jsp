<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>내 찜 목록</title>
  
  <link rel="stylesheet" href="/css/header.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
  <link rel="stylesheet" href="/css/redesign.css" />
  <link rel="stylesheet" href="/css/ui-toast.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/nav-wave.js"></script>

  <style>
    .wish-filter-wrap {
      background: #fff;
      border-radius: 12px;
      padding: 0 24px 20px 24px;
      margin-bottom: 24px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.04);
      border: 1px solid #eaeaea;
    }
    
    .city-tabs {
      display: flex;
      gap: 32px;
      border-bottom: 1px solid #f0f0f0;
      overflow-x: auto;
      scrollbar-width: none; 
      padding-top: 20px;
    }
    .city-tabs::-webkit-scrollbar { display: none; }
    
    .city-tab {
      font-size: 16px;
      font-weight: 500;
      color: #888;
      cursor: pointer;
      padding-bottom: 12px;
      position: relative;
      white-space: nowrap;
      transition: all 0.2s;
    }
    .city-tab:hover { color: #111; }
    .city-tab.active {
      color: #111;
      font-weight: 800;
    }
    .city-tab.active::after {
      content: '';
      position: absolute;
      bottom: -1px;
      left: 0;
      width: 100%;
      height: 3px;
      background: #111;
      border-radius: 3px 3px 0 0;
    }

    .cat-buttons {
      display: flex;
      gap: 12px;
      overflow-x: auto;
      scrollbar-width: none;
      padding-top: 20px;
    }
    .cat-buttons::-webkit-scrollbar { display: none; }
    
    .cat-btn {
      padding: 10px 18px;
      background: #f4f5f7;
      color: #555;
      border-radius: 6px;
      font-size: 14px;
      font-weight: 700;
      cursor: pointer;
      border: none;
      white-space: nowrap;
      transition: all 0.2s;
    }
    .cat-btn:hover { background: #e5e8ec; }
    .cat-btn.active {
      background: #111;
      color: #fff;
    }
  </style>
</head>
<body class="page-solid">

<jsp:include page="/WEB-INF/views/common/header.jsp" />
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
        <a href="${pageContext.request.contextPath}/members/mypage">
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
        <a class="active" href="${pageContext.request.contextPath}/members/mypage/wishlist">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none"><path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" stroke-linecap="round"/></svg>
          </span>내 찜 목록
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

    <div class="wish-filter-wrap">
      <div class="city-tabs" id="cityTabs">
        <div class="city-tab active" data-filter-city="ALL">모든 도시</div>
      </div>
      
      <div class="cat-buttons" id="catButtons">
        <button class="cat-btn active" data-filter-cat="ALL">전체보기</button>
        <button class="cat-btn" data-filter-cat="TOUR">관광지</button>
        <button class="cat-btn" data-filter-cat="STAY">숙소</button>
        <button class="cat-btn" data-filter-cat="ACT">문화/액티비티</button>
        <button class="cat-btn" data-filter-cat="FOOD">맛집</button>
      </div>
    </div>

    <section class="mp-card mp-grow" style="width: 100%;">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">내 찜 목록 전체보기</div>
          <div class="mp-card-sub">내가 그동안 관심 등록한 모든 장소들입니다.</div>
        </div>
      </div>

      <div class="mp-card-body" style="width: 100%;">
        <c:if test="${empty allWishList}">
          <div style="padding: 40px; text-align: center; color: #999;">아직 찜한 장소가 없습니다. 여행지를 둘러보고 찜 기능을 사용해 보세요.</div>
        </c:if>

        <c:if test="${not empty allWishList}">
          <div class="mp-deck" style="display: flex !important; flex-wrap: wrap !important; gap: 16px !important; padding-bottom: 10px;">
            <c:forEach var="spot" items="${allWishList}">
              
              <div class="item wish-card-item" 
                   data-city="${spot.city != null ? spot.city.name : '기타'}" 
                   data-cat="${spot.catCode}"
                   style="width: calc(33.333% - 11px); min-width: 220px !important; flex-shrink: 0 !important; margin-bottom: 10px; border: 1px solid #eee; border-radius: 12px; overflow: hidden;">
                
                <a href="${pageContext.request.contextPath}/spots/detail/${spot.id}" style="text-decoration: none; color: inherit; display: block;">
                  <div class="thumb" 
                       style="background-image: url('${not empty spot.image ? spot.image : pageContext.request.contextPath += '/img/hero.jpg'}'); 
                              background-size: cover; background-position: center; height: 160px;">
                  </div>
                  <div class="meta" style="padding: 15px;">
                    <div style="display: flex; gap: 6px; margin-bottom: 6px;">
                      
                      <span class="tag" style="background: #e2e8f0; color: #475569; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: bold;">
                        ${spot.city != null ? spot.city.name : '기타'}
                      </span>
                      
                      <c:choose>
                        <c:when test="${spot.catCode == 'TOUR'}"><span class="tag" style="background: #f0f0f0; color: #333; padding: 3px 8px; border-radius: 4px; font-size: 11px;">TOUR</span></c:when>
                        <c:when test="${spot.catCode == 'STAY'}"><span class="tag" style="background: #eef2ff; color: #3b82f6; padding: 3px 8px; border-radius: 4px; font-size: 11px;">STAY</span></c:when>
                        <c:when test="${spot.catCode == 'ACT'}"><span class="tag" style="background: #f0fdf4; color: #22c55e; padding: 3px 8px; border-radius: 4px; font-size: 11px;">ACT</span></c:when>
                        <c:when test="${spot.catCode == 'FOOD'}"><span class="tag" style="background: #fff5f5; color: #ef4444; padding: 3px 8px; border-radius: 4px; font-size: 11px;">FOOD</span></c:when>
                        <c:otherwise><span class="tag" style="background: #f0f0f0; color: #333; padding: 3px 8px; border-radius: 4px; font-size: 11px;">${spot.catCode}</span></c:otherwise>
                      </c:choose>
                    </div>
                    
                    <div class="ttl" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-weight: bold;">${spot.name}</div>
                    <div class="sub" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-size: 12px; color: #777; margin-top: 3px;">${spot.addr}</div>
                  </div>
                </a>
              </div>
            </c:forEach>
          </div>
        </c:if>

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
        </div>
      </div>
    </section>

  </aside>

</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>

<script>
	document.addEventListener('DOMContentLoaded', function() {
	    
	    const cards = document.querySelectorAll('.wish-card-item');
	    const citySet = new Set();
	    
	    cards.forEach(card => {
	        const city = card.getAttribute('data-city');
	        if (city && city !== '' && city !== '기타') {
	            citySet.add(city);
	        }
	    });

	    const cityTabsContainer = document.getElementById('cityTabs');
	    const targetCityOrder = ['서울', '부산', '제주도', '강릉', '경주', '수원', '속초'];

	    targetCityOrder.forEach(city => {
	        if (citySet.has(city)) {
	            const tab = document.createElement('div');
	            tab.className = 'city-tab';
	            tab.setAttribute('data-filter-city', city);
	            tab.innerText = city;
	            cityTabsContainer.appendChild(tab);
	            citySet.delete(city);
	        }
	    });

	    citySet.forEach(city => {
	        const tab = document.createElement('div');
	        tab.className = 'city-tab';
	        tab.setAttribute('data-filter-city', city);
	        tab.innerText = city;
	        cityTabsContainer.appendChild(tab);
	    });

	    const cityTabs = document.querySelectorAll('.city-tab');
	    const catBtns = document.querySelectorAll('.cat-btn');
	    let currentCity = 'ALL';
	    let currentCat = 'ALL';

	    cityTabs.forEach(tab => {
	        tab.addEventListener('click', () => {
	            cityTabs.forEach(t => t.classList.remove('active')); 
	            tab.classList.add('active');                         
	            currentCity = tab.getAttribute('data-filter-city');
	            applyFilter();                                       
	        });
	    });

	    catBtns.forEach(btn => {
	        btn.addEventListener('click', () => {
	            catBtns.forEach(b => b.classList.remove('active'));
	            btn.classList.add('active');
	            currentCat = btn.getAttribute('data-filter-cat');
	            applyFilter();
	        });
	    });

	    function applyFilter() {
	        let visibleCount = 0;
	        
	        cards.forEach(card => {
	            const cardCity = card.getAttribute('data-city');
	            const cardCat = card.getAttribute('data-cat');
	            
	            const matchCity = (currentCity === 'ALL' || currentCity === cardCity);
	            const matchCat = (currentCat === 'ALL' || currentCat === cardCat);

	            if (matchCity && matchCat) {
	                card.style.display = ''; 
	                visibleCount++;
	            } else {
	                card.style.display = 'none'; 
	            }
	        });

	        let emptyMsg = document.getElementById('emptyFilterMsg');
	        if (visibleCount === 0 && cards.length > 0) {
	            if (!emptyMsg) {
	                const msg = document.createElement('div');
	                msg.id = 'emptyFilterMsg';
	                msg.style = 'padding: 40px; text-align: center; color: #999; width: 100%;';
	                msg.innerText = '해당 조건에 맞는 장소가 없습니다.';
	                document.querySelector('.mp-deck').appendChild(msg);
	            } else {
	                emptyMsg.style.display = 'block';
	            }
	        } else {
	            if (emptyMsg) {
	                emptyMsg.style.display = 'none';
	            }
	        }
	    }
	});
</script>

</body>
</html>