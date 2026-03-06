<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${city.name} - 전체보기</title>
    <link rel="stylesheet" href="/css/header.css" />
    <script src="/js/theme.js"></script>
    <script defer src="/js/nav-wave.js"></script>
    <style>
        body { font-family: 'Pretendard', sans-serif; background-color: #f8f9fa; margin: 0; }
        .container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; }
        
        /* 2단 레이아웃 설정 */
        .main-layout { display: flex; gap: 30px; align-items: flex-start; }
        
        /* 왼쪽 사이드바 스타일 */
        .sidebar { width: 240px; position: sticky; top: 92px; flex-shrink: 0; }
        .category-menu { background: white; border-radius: 16px; padding: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .menu-title { font-size: 16px; font-weight: bold; color: #888; margin-bottom: 15px; padding-left: 10px; }
        .menu-list { list-style: none; padding: 0; margin: 0; }
        .menu-item a { 
            display: block; padding: 12px 15px; text-decoration: none; color: #555; 
            border-radius: 10px; margin-bottom: 5px; transition: 0.2s; font-weight: 500;
        }
        .menu-item a:hover { background: #f0f4ff; color: #3264ff; }
        .menu-item.active a { background: #3264ff; color: white; font-weight: bold; }

        /* 오른쪽 컨텐츠 영역 */
        .content-area { flex: 1; }
        .header-section { margin-bottom: 30px; }
        .category-title { font-size: 24px; font-weight: 800; color: #333; }
        .city-name { color: #3264ff; }

        /* 리스트형 카드 디자인 */
        .spot-list { display: flex; flex-direction: column; gap: 20px; }
        .card { 
            background: white; border-radius: 16px; overflow: hidden; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); transition: 0.3s;
            text-decoration: none; color: inherit; display: flex; height: 180px;
        }
        .card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
        
        .img-box { width: 240px; background-color: #eee; background-size: cover; background-position: center; flex-shrink: 0; }
        
        .info-box { padding: 25px; flex: 1; display: flex; flex-direction: column; justify-content: center; position: relative; }
        .spot-title { font-size: 20px; font-weight: 700; margin-bottom: 8px; color: #333; }
        .spot-addr { font-size: 15px; color: #777; margin-bottom: 10px; }
		/* 기존 .spot-price는 파란색 유지 */
		.spot-price { 
		    font-size: 16px; 
		    color: #3264ff; 
		    font-weight: bold; 
		    display: flex; 
		    align-items: center; 
		    gap: 4px; /* 별과 숫자 사이 간격 */
		}

		/* 추가: 별 아이콘만 노란색으로 설정 */
		.star-yellow {
		    color: #ffc107; /* 노란색/금색 */
		    font-size: 18px; /* 별 크기 살짝 조정 (취향껏) */
		}
        
        .btn-detail { 
            position: absolute; right: 25px; bottom: 25px;
            background: #f0f4ff; color: #3264ff; padding: 8px 18px; 
            border-radius: 8px; font-size: 14px; font-weight: bold;
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<div class="container">
    <div class="main-layout">
        
        <aside class="sidebar">
            <a href="${pageContext.request.contextPath}/spots/spot?cityId=${selectedCity}" 
               style="text-decoration: none; color: #888; font-size: 14px; display: inline-block; margin-bottom: 20px; font-weight: bold;">
               &lt; 메인으로 돌아가기
            </a>
            <div class="category-menu">
                <div class="menu-title">카테고리</div>
                <ul class="menu-list">
                    <li class="menu-item ${catCode eq 'TOUR' ? 'active' : ''}">
                        <a href="?cityId=${selectedCity}&catCode=TOUR">🏛️ 인기 관광지</a>
                    </li>
                    <li class="menu-item ${catCode eq 'STAY' ? 'active' : ''}">
                        <a href="?cityId=${selectedCity}&catCode=STAY">🛌 추천 숙소</a>
                    </li>
                    <li class="menu-item ${catCode eq 'ACT' ? 'active' : ''}">
                        <a href="?cityId=${selectedCity}&catCode=ACT">🏄 문화/액티비티</a>
                    </li>
                    <li class="menu-item ${catCode eq 'FOOD' ? 'active' : ''}">
                        <a href="?cityId=${selectedCity}&catCode=FOOD">🍱 추천 맛집</a>
                    </li>
                </ul>
            </div>
        </aside>

        <main class="content-area">
            <div class="header-section">
                <div class="category-title">
                    <span class="city-name">${city.name}</span> 
                    <j:choose>
                        <j:when test="${catCode eq 'TOUR'}">인기 관광지</j:when>
                        <j:when test="${catCode eq 'STAY'}">추천 숙소</j:when>
                        <j:when test="${catCode eq 'ACT'}">문화/액티비티</j:when>
                        <j:when test="${catCode eq 'FOOD'}">추천 맛집</j:when>
                    </j:choose>
                </div>
                <div style="color: #999; margin-top: 5px;">총 ${spotList.size()}개의 장소가 검색되었습니다.</div>
            </div>

			<div class="spot-list">
			    <j:forEach var="s" items="${spotList}">
			        <a href="${pageContext.request.contextPath}/spots/detail/${s.id}" class="card" style="position: relative;">
			            <button class="wish-btn" onclick="toggleWish(event, ${s.id}, this)" 
			                    style="position: absolute; top: 15px; left: 15px; z-index: 10; background: rgba(255,255,255,0.9); border: none; border-radius: 50%; width: 35px; height: 35px; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 18px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
			                ${s.isHearted ? '❤️' : '🤍'}
			            </button>
			            
			            <%-- ✅ 여기를 수정했어요! s.id를 이용해 첫 번째 사진(_1.jpg)을 불러옵니다. --%>
			            <div class="img-box" style="background-image: url('${pageContext.request.contextPath}/img/spot/${s.id}_1.jpg');"></div>
			            
			            <div class="info-box">
			                <div class="spot-title">${s.name}</div>
			                <div class="spot-addr">${s.addr}</div>
			                <div class="spot-price">
			                    <span class="star-yellow">★</span> 
			                    ${not empty s.price ? s.price : '0.0'}
			                </div>
			                <div class="btn-detail">상세보기</div>
			            </div>
			        </a>
			    </j:forEach>
			</div>
            
            <j:if test="${empty spotList}">
                <div style="text-align: center; padding: 100px 0; color: #999; background: white; border-radius: 16px;">
                    등록된 장소가 없습니다.
                </div>
            </j:if>
        </main>
        
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>

</body>
<script>
	// 하트 토글 통신 함수
	function toggleWish(event, sIdx, btn) {
	    event.preventDefault();
	    event.stopPropagation(); // 카드 링크로 이동하는 것을 방지하고 하트만 토글시킴
	    
	    fetch('/api/wish/toggle', {
	        method: 'POST',
	        headers: { 'Content-Type': 'application/json' },
	        body: JSON.stringify({ sIdx: sIdx })
	    })
	    .then(response => {
	        if (response.status === 401) {
	            if (window.LoginRequiredPrompt) { window.LoginRequiredPrompt.open(); } else { if (window.LoginRequiredPrompt) { window.LoginRequiredPrompt.open(); } else { alert('로그인이 필요한 서비스입니다.'); } }
	            return;
	        }
	        return response.json();
	    })
	    .then(data => {
	        if (data && data.success) {
	            btn.innerText = data.isHearted ? '❤️' : '🤍';
	            if (data.isHearted) btn.classList.add('active');
	            else btn.classList.remove('active');
	        }
	    })
	    .catch(error => {
	        console.error('Error:', error);
	        alert('처리 중 오류가 발생했습니다.');
	    });
	}
	
</script>
</html>