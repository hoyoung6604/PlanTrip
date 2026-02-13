<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>여행지 목록</title>
    <style>
        body { font-family: 'Pretendard', sans-serif; color: #333; line-height: 1.6; margin: 0; padding: 0; }
        .section-container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        
        /* 도시 버튼 스타일 */
        .city-nav { display: flex; gap: 15px; margin-bottom: 40px; overflow-x: auto; padding: 10px 0; }
        .city-btn { padding: 12px 25px; border: 1px solid #eee; border-radius: 25px; background: white; 
                    cursor: pointer; font-weight: bold; text-decoration: none; color: #555; box-shadow: 0 2px 8px rgba(0,0,0,0.05); white-space: nowrap; }
        .city-btn.active { background: #3264ff; color: white; border-color: #3264ff; }

        /* 슬라이더 및 카드 스타일 */
        .slider-wrapper { position: relative; display: flex; align-items: center; gap: 10px; margin-bottom: 60px; }
        .card-container { display: flex; overflow-x: hidden; scroll-behavior: smooth; gap: 20px; width: 100%; padding: 10px 5px; }
        .card-item { min-width: calc(25% - 15px); max-width: calc(25% - 15px); flex-shrink: 0; }
        .card { border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.08); background: white; transition: 0.3s; height: 100%; }
        .card:hover { transform: translateY(-5px); }
        .card.is-disabled{ opacity:.55; cursor:not-allowed; }
        .card.is-disabled:hover{ transform:none; }
        
        .nav-btn { background: white; border: none; border-radius: 50%; width: 45px; height: 45px; cursor: pointer; 
                    box-shadow: 0 4px 12px rgba(0,0,0,0.15); font-size: 20px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        
        h2 { font-size: 24px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
    
        /* === Top-left home logo (spots list) === */
        .spot-home-logo{
            position: fixed;
            top: 18px;
            left: 18px;
            z-index: 1200;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }
        .spot-home-logo img{
            height: 54px;
            width: auto;
            display: block;
        }
        @media (max-width: 768px){
            .spot-home-logo{ top: 12px; left: 12px; }
            .spot-home-logo img{ height: 44px; }
        }

    </style>
</head>
<body>
    <a class="spot-home-logo" href="/" title="메인으로">
        <img src="/img/PlanTriplog.png" alt="PlanTrip">
    </a>


<div class="section-container">
    <h1 style="font-size: 32px; font-weight: 800; margin-top: 50px;">대한민국에서 놓치면 안 될 인기 명소</h1>

    <%-- 1. 도시 선택 버튼 --%>
    <div class="city-nav">
		<button type="button" onclick="loadCity(4, this)" class="city-btn ${selectedCity == 4 ? 'active' : ''}">서울</button>
		<button type="button" onclick="loadCity(1, this)" class="city-btn ${selectedCity == 1 ? 'active' : ''}">부산</button>
		<button type="button" onclick="loadCity(2, this)" class="city-btn ${selectedCity == 2 ? 'active' : ''}">제주도</button>
		<button type="button" onclick="loadCity(7, this)" class="city-btn ${selectedCity == 7 ? 'active' : ''}">강릉</button>
		<button type="button" onclick="loadCity(5, this)" class="city-btn ${selectedCity == 5 ? 'active' : ''}">경주</button>
		<button type="button" onclick="loadCity(3, this)" class="city-btn ${selectedCity == 3 ? 'active' : ''}">수원</button>
		<button type="button" onclick="loadCity(6, this)" class="city-btn ${selectedCity == 6 ? 'active' : ''}">속초</button>
    </div>

    <%-- 2. 인기 관광지 섹션 (TOUR) --%>
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <h2>인기 관광지</h2>
		<a href="${pageContext.request.contextPath}/spots/all?cityId=${selectedCity}&catCode=TOUR" 
		class="all-link" data-cat="TOUR"       
		style="color: #888; text-decoration: none; font-size: 14px;">전체보기 ></a>
    </div>
    <div class="slider-wrapper">
        <button class="nav-btn" onclick="sideScroll('tour-slider', 'left')">‹</button>
        <div class="card-container" id="tour-slider">
            <j:if test="${empty tourList}">
    <j:forEach begin="1" end="4" var="i">
        <div class="card-item">
            <a href="#" onclick="alert('데이터가 현재 없습니다.'); return false;" style="text-decoration:none; color:inherit;">
                <div class="card is-disabled">
                    <div style="height: 200px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 50px;">🏛️</div>
                    <div style="padding: 20px;">
                        <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">데이터 준비중</div>
                        <div style="font-size: 13px; color: #777;">등록된 관광지가 없습니다.</div>
                    </div>
                </div>
            </a>
        </div>
    </j:forEach>
</j:if>
            <j:forEach var="s" items="${tourList}">
                <div class="card-item">
                    <a href="${pageContext.request.contextPath}/spots/detail/${s.id}" style="text-decoration:none; color:inherit;">
                        <div class="card">
                            <div style="height: 200px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 50px;">🏛️</div>
                            <div style="padding: 20px;">
                                <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">${s.name}</div>
                                <div style="font-size: 13px; color: #777;">${s.addr}</div>
                            </div>
                        </div>
                    </a>
                </div>
            </j:forEach>
        </div>
        <button class="nav-btn" onclick="sideScroll('tour-slider', 'right')">›</button>
    </div>

    <%-- 3. 추천 숙소 섹션 (STAY) --%>
	<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
	        <h2 style="margin: 0;">추천 숙소</h2>
	        <a href="${pageContext.request.contextPath}/spots/all?cityId=${selectedCity}&catCode=STAY" 
			class="all-link" data-cat="STAY"
	           style="color: #888; text-decoration: none; font-size: 14px;">전체보기 ></a>
	    </div>
    <div class="slider-wrapper">
        <button class="nav-btn" onclick="sideScroll('stay-slider', 'left')">‹</button>
        <div class="card-container" id="stay-slider">
            <j:if test="${empty stayList}">
    <j:forEach begin="1" end="4" var="i">
        <div class="card-item">
            <a href="#" onclick="alert('데이터가 현재 없습니다.'); return false;" style="text-decoration:none; color:inherit;">
                <div class="card is-disabled">
                    <div style="height: 200px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 50px;">🛌</div>
                    <div style="padding: 20px;">
                        <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">데이터 준비중</div>
                        <div style="font-size: 13px; color: #777;">등록된 숙소가 없습니다.</div>
                    </div>
                </div>
            </a>
        </div>
    </j:forEach>
</j:if>
            <j:forEach var="s" items="${stayList}">
                <div class="card-item">
                    <a href="${pageContext.request.contextPath}/spots/detail/${s.id}" style="text-decoration:none; color:inherit;">
                        <div class="card">
                        <div style="height: 200px; background: #eef2ff; display: flex; align-items: center; justify-content: center; font-size: 50px;">🛌</div>
                        <div style="padding: 20px;">
                            <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">${s.name}</div>
                            <div style="font-size: 13px; color: #777;">${s.addr}</div>
                        </div>
                    </div>
                </a>
                </div>
            </j:forEach>
        </div>
        <button class="nav-btn" onclick="sideScroll('stay-slider', 'right')">›</button>
    </div>

    <%-- 4. 문화/액티비티 섹션 (ACT) --%>
	<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
	        <h2 style="margin: 0;">문화/액티비티</h2>
	        <%-- catCode를 STAY로 바꿔서 넣어주세요! --%>
	        <a href="${pageContext.request.contextPath}/spots/all?cityId=${selectedCity}&catCode=ACT" 
			class="all-link" data-cat="ACT"   
			style="color: #888; text-decoration: none; font-size: 14px;">전체보기 ></a>
	    </div>
    <div class="slider-wrapper">
        <button class="nav-btn" onclick="sideScroll('act-slider', 'left')">‹</button>
        <div class="card-container" id="act-slider">
            <j:if test="${empty actList}">
    <j:forEach begin="1" end="4" var="i">
        <div class="card-item">
            <a href="#" onclick="alert('데이터가 현재 없습니다.'); return false;" style="text-decoration:none; color:inherit;">
                <div class="card is-disabled">
                    <div style="height: 200px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 50px;">🏄</div>
                    <div style="padding: 20px;">
                        <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">데이터 준비중</div>
                        <div style="font-size: 13px; color: #777;">등록된 액티비티가 없습니다.</div>
                    </div>
                </div>
            </a>
        </div>
    </j:forEach>
</j:if>
            <j:forEach var="s" items="${actList}">
                <div class="card-item">
                    <a href="${pageContext.request.contextPath}/spots/detail/${s.id}" style="text-decoration:none; color:inherit;">
                        <div class="card">
                        <div style="height: 200px; background: #f0fdf4; display: flex; align-items: center; justify-content: center; font-size: 50px;">🏄</div>
                        <div style="padding: 20px;">
                            <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">${s.name}</div>
                            <div style="font-size: 13px; color: #777;">${s.addr}</div>
                        </div>
                    </div>
                </a>
                </div>
            </j:forEach>
        </div>
        <button class="nav-btn" onclick="sideScroll('act-slider', 'right')">›</button>
    </div>

    <%-- 5. 추천 맛집 섹션 (FOOD) --%>
	<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
	        <h2 style="margin: 0;">추천 맛집</h2>
	        <%-- catCode를 STAY로 바꿔서 넣어주세요! --%>
	        <a href="${pageContext.request.contextPath}/spots/all?cityId=${selectedCity}&catCode=FOOD" 
			class="all-link" data-cat="FOOD"   
			style="color: #888; text-decoration: none; font-size: 14px;">전체보기 ></a>
	    </div>
    <div class="slider-wrapper">
        <button class="nav-btn" onclick="sideScroll('food-slider', 'left')">‹</button>
        <div class="card-container" id="food-slider">
            <j:if test="${empty foodList}">
    <j:forEach begin="1" end="4" var="i">
        <div class="card-item">
            <a href="#" onclick="alert('데이터가 현재 없습니다.'); return false;" style="text-decoration:none; color:inherit;">
                <div class="card is-disabled">
                    <div style="height: 200px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 50px;">🍱</div>
                    <div style="padding: 20px;">
                        <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">데이터 준비중</div>
                        <div style="font-size: 13px; color: #777;">등록된 맛집이 없습니다.</div>
                    </div>
                </div>
            </a>
        </div>
    </j:forEach>
</j:if>
            <j:forEach var="s" items="${foodList}">
                <div class="card-item">
                    <a href="${pageContext.request.contextPath}/spots/detail/${s.id}" style="text-decoration:none; color:inherit;">
                        <div class="card">
                        <div style="height: 200px; background: #fff5f5; display: flex; align-items: center; justify-content: center; font-size: 50px;">🍱</div>
                        <div style="padding: 20px;">
                            <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">${s.name}</div>
                            <div style="font-size: 13px; color: #777;">${s.addr}</div>
                        </div>
                    </div>
                </a>
                </div>
            </j:forEach>
        </div>
        <button class="nav-btn" onclick="sideScroll('food-slider', 'right')">›</button>
    </div>
</div>

<script>
    // 1. 도시 데이터를 비동기로 불러오는 함수
    function loadCity(cityId, btn) {
        // 버튼 활성화 스타일 처리
        document.querySelectorAll('.city-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

		const contextPath = "${pageContext.request.contextPath}";
		    document.querySelectorAll('.all-link').forEach(link => {
		        const catCode = link.getAttribute('data-cat'); // 아까 넣은 data-cat 값을 가져옴
		        link.href = contextPath + "/spots/all?cityId=" + cityId + "&catCode=" + catCode;
		    });
		
        // 서버로 데이터 요청
        fetch("${pageContext.request.contextPath}/spots/api/contents?cityId=" + cityId)
            .then(res => res.json())
            .then(data => {
                // 받은 데이터로 각 섹션 그리기
                renderSection('tour-slider', data.tourList, '🏛️');
                renderSection('stay-slider', data.stayList, '🛌');
                renderSection('act-slider', data.actList, '🏄');
                renderSection('food-slider', data.foodList, '🍱');
            })
            .catch(err => console.error("로딩 실패:", err));
    }

    // 2. 카드를 화면에 그려주는 함수
    function renderSection(containerId, list, emoji) {
        const container = document.getElementById(containerId);
        container.innerHTML = ''; 

        if (!list || list.length === 0) {
    const placeholders = Array.from({length: 4}).map(() => `
        <div class="card-item">
            <a href="#" onclick="alert('데이터가 현재 없습니다.'); return false;" style="text-decoration:none; color:inherit;">
                <div class="card is-disabled">
                    <div style="height: 200px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 50px;">${emoji}</div>
                    <div style="padding: 20px;">
                        <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">데이터 준비중</div>
                        <div style="font-size: 13px; color: #777;">등록된 정보가 없습니다.</div>
                    </div>
                </div>
            </a>
        </div>
    `).join('');
    container.innerHTML = placeholders;
    return;
}

        list.forEach(s => {
            const cardHtml = `
                <div class="card-item">
                    <a href="${pageContext.request.contextPath}/spots/detail/\${s.id}" style="text-decoration:none; color:inherit;">
                        <div class="card">
                            <div style="height: 200px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 50px;">\${emoji}</div>
                            <div style="padding: 20px;">
                                <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">\${s.name}</div>
                                <div style="font-size: 13px; color: #777;">\${s.addr}</div>
                            </div>
                        </div>
                    </a>
                </div>
            `;
            container.innerHTML += cardHtml;
        });
    }

    // 3. 사용자님이 주신 화살표 슬라이드 함수 (그대로 유지!)
    function sideScroll(elementId, direction) {
        const container = document.getElementById(elementId);
        const card = container.querySelector('.card-item');
        if (!card) return; 

        const scrollAmount = card.clientWidth + 20; 

        if (direction === 'left') {
            container.scrollLeft -= scrollAmount;
        } else {
            container.scrollLeft += scrollAmount;
        }
    }

    // 4. 페이지 처음 켰을 때 서울(4) 데이터를 기본으로 불러오기
    window.onload = () => {
        const defaultBtn = document.querySelector('.city-btn.active') || document.querySelector('.city-btn');
        if(defaultBtn) loadCity(4, defaultBtn);
    };
</script>
</body>
</html>