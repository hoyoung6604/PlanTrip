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
    /* 상단 여백은 CSS로 통일했으므로 불필요한 마진 제거 */
    .wish-filter-wrap {
      background: #fff;
      border-radius: 16px;
      padding: 0 24px 20px 24px;
      margin-bottom: 30px;
      box-shadow: var(--shadow2);
      border: 1px solid var(--line);
    }
    .city-tabs {
      display: flex; gap: 32px; border-bottom: 1px solid #f0f0f0;
      overflow-x: auto; scrollbar-width: none; padding-top: 20px;
    }
    .city-tabs::-webkit-scrollbar { display: none; }
    .city-tab {
      font-size: 16px; font-weight: 500; color: #888; cursor: pointer;
      padding-bottom: 12px; position: relative; white-space: nowrap; transition: all 0.2s;
    }
    .city-tab:hover { color: #111; }
    .city-tab.active { color: #111; font-weight: 800; }
    .city-tab.active::after {
      content: ''; position: absolute; bottom: -1px; left: 0; width: 100%; height: 3px;
      background: #111; border-radius: 3px 3px 0 0;
    }

    .cat-buttons {
      display: flex; gap: 12px; overflow-x: auto; scrollbar-width: none; padding-top: 20px;
    }
    .cat-buttons::-webkit-scrollbar { display: none; }
    .cat-btn {
      padding: 10px 18px; background: #f4f5f7; color: #555; border-radius: 6px;
      font-size: 14px; font-weight: 700; cursor: pointer; border: none; white-space: nowrap; transition: all 0.2s;
    }
    .cat-btn:hover { background: #e5e8ec; }
    .cat-btn.active { background: #111; color: #fff; }
  </style>
</head>
<body class="page-solid">

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="mp-shell">
  <aside class="mp-side">
    <nav class="mp-nav">
      <a href="${pageContext.request.contextPath}/members/mypage">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M4 13h7V4H4v9Zm9 7h7V11h-7v9ZM4 20h7v-5H4v5Zm9-16v5h7V4h-7Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg></span>대시보드
      </a>
      <a href="${pageContext.request.contextPath}/members/mypage/check">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M12 20h9" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4 11.5-11.5Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg></span>회원정보 수정
      </a>
      <a href="${pageContext.request.contextPath}/members/mypage/plans">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M7 3v3M17 3v3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M4 8h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M5 6h14a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg></span>내 여행 계획
      </a>
      <a href="${pageContext.request.contextPath}/members/mypage/reviews">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M7 3h8l4 4v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M15 3v5h5" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M8 13h8M8 17h8" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg></span>내 여행 후기
      </a>
      <a class="active" href="${pageContext.request.contextPath}/members/mypage/wishlist">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" stroke-linecap="round"/></svg></span>내 찜 목록
      </a>
    </nav>
  </aside>

  <main class="mp-main">
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
          <div class="mp-deck">
            <c:forEach var="spot" items="${allWishList}">
              <div class="item wish-card-item" 
                   data-city="${spot.city != null ? spot.city.name : '기타'}" 
                   data-cat="${spot.catCode}">
                
                <a href="${pageContext.request.contextPath}/spots/detail/${spot.id}" style="text-decoration: none; color: inherit; display: block;">
                  <div class="thumb" style="background-image: url('${not empty spot.image ? spot.image : pageContext.request.contextPath += '/img/hero.jpg'}');">
                  </div>
                  
                  <div class="meta">
                    <div class="tag-wrap">
                      <span class="tag-city">${spot.city != null ? spot.city.name : '기타'}</span>
                      <c:choose>
                        <c:when test="${spot.catCode == 'TOUR'}"><span class="tag-cat tag-tour">TOUR</span></c:when>
                        <c:when test="${spot.catCode == 'STAY'}"><span class="tag-cat tag-stay">STAY</span></c:when>
                        <c:when test="${spot.catCode == 'ACT'}"><span class="tag-cat tag-act">ACT</span></c:when>
                        <c:when test="${spot.catCode == 'FOOD'}"><span class="tag-cat tag-food">FOOD</span></c:when>
                        <c:otherwise><span class="tag-cat">${spot.catCode}</span></c:otherwise>
                      </c:choose>
                    </div>
                    <div class="ttl">${spot.name}</div>
                    <div class="sub">${spot.addr}</div>
                  </div>
                </a>
              </div>
            </c:forEach>
          </div>
        </c:if>
      </div>
    </section>
  </main>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>

<script>
	document.addEventListener('DOMContentLoaded', function() {
	    const cards = document.querySelectorAll('.wish-card-item');
	    const citySet = new Set();
	    
	    cards.forEach(card => {
	        const city = card.getAttribute('data-city');
	        if (city && city !== '' && city !== '기타') citySet.add(city);
	    });

	    const cityTabsContainer = document.getElementById('cityTabs');
	    const targetCityOrder = ['서울', '부산', '제주도', '강릉', '경주', '수원', '속초'];
	    
	    targetCityOrder.forEach(city => {
	        if (citySet.has(city)) {
	            const tab = document.createElement('div');
	            tab.className = 'city-tab'; tab.setAttribute('data-filter-city', city); tab.innerText = city;
	            cityTabsContainer.appendChild(tab); citySet.delete(city);
	        }
	    });

	    citySet.forEach(city => {
	        const tab = document.createElement('div');
	        tab.className = 'city-tab'; tab.setAttribute('data-filter-city', city); tab.innerText = city;
	        cityTabsContainer.appendChild(tab);
	    });

	    const cityTabs = document.querySelectorAll('.city-tab');
	    const catBtns = document.querySelectorAll('.cat-btn');
	    let currentCity = 'ALL'; let currentCat = 'ALL';
	    
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
	            const matchCity = (currentCity === 'ALL' || currentCity === card.getAttribute('data-city'));
	            const matchCat = (currentCat === 'ALL' || currentCat === card.getAttribute('data-cat'));
	            if (matchCity && matchCat) { card.style.display = ''; visibleCount++; } else { card.style.display = 'none'; }
	        });
	        let emptyMsg = document.getElementById('emptyFilterMsg');
	        if (visibleCount === 0 && cards.length > 0) {
	            if (!emptyMsg) {
	                const msg = document.createElement('div');
	                msg.id = 'emptyFilterMsg'; msg.style = 'padding: 40px; text-align: center; color: #999; grid-column: 1 / -1;'; msg.innerText = '해당 조건에 맞는 장소가 없습니다.';
	                document.querySelector('.mp-deck').appendChild(msg);
	            } else { emptyMsg.style.display = 'block'; }
	        } else { if (emptyMsg) emptyMsg.style.display = 'none'; }
	    }
	});
</script>

</body>
</html>