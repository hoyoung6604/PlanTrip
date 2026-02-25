<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>검색 결과 - ${param.keyword}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css" />
    
	<style>
		body { 
		        margin: 0; padding: 0; 
		        font-family: 'Pretendard', sans-serif; 
		        background-color: #fff; /* 기본 바닥 배경을 흰색으로 변경 */
		    }

		    /* 1. 흐릿한 상단 배경 (높이를 충분히 확보) */
		    .hero-background-wrapper {
		        position: fixed; /* 배경을 화면에 고정시켜서 스크롤 시에도 뒤에 깔리게 함 */
		        top: 0; left: 0;
		        width: 100%; 
		        height: 600px; /* 흰색 판이 올라와도 뒤가 비지 않도록 높게 설정 */
		        overflow: hidden;
		        z-index: -1;
		        background-color: #fff; /* 검은색 대신 흰색으로 기본 베이스 설정 */
		    }
		    .hero-background-wrapper img {
		        width: 100%; height: 100%;
		        object-fit: cover;
		        filter: blur(25px) brightness(0.8);
		        transform: scale(1.2); /* 블러 외곽 깨짐 방지 */
		    }

		    /* 2. 플로팅 카드 (기존 사용자 설정 수치 유지) */
		    .floating-container {
		        max-width: 1100px;
		        margin: 0 auto;
		        position: relative;
		        margin-top: 150px; /* 배경 위에서의 위치 조절 */
		        z-index: 10;
		        padding: 0 20px;
		    }

		/* 1. 서울 사진 & 지도 카드 (상단 둥글게 유지) */
		    .combined-card {
		        display: flex;
		        width: 100%;
		        height: 320px;
		        background: #fff;
		        /* 아래쪽은 흰색 판과 밀착되도록 0으로, 위쪽은 둥글게 */
		        border-radius: 24px 24px 0 0; 
		        overflow: hidden;
		        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
		        position: relative;
		        z-index: 11; /* 본문보다 살짝 위에 있도록 */
		    }
		

	    /* 사진 영역 */
	    .city-photo-box {
	        flex: 1.8;
	        position: relative;
	    }
	    .city-photo-box img {
	        width: 100%; height: 100%;
	        object-fit: cover;
	    }
	    .city-name-overlay {
	        position: absolute;
	        bottom: 0; left: 0; right: 0;
	        padding: 30px;
	        background: linear-gradient(transparent, rgba(0,0,0,0.8));
	        color: white;
	    }
	    .city-name-overlay h1 { font-size: 3rem; margin: 0; font-weight: 900; }

	    /* 지도 영역 */
	    .city-map-box {
	        flex: 1;
	        background: #eee;
	        position: relative;
	        cursor: pointer;
	    }
	    .city-map-box img { width: 100%; height: 100%; object-fit: cover; }
	    .map-btn-label {
	        position: absolute;
	        top: 50%; left: 50%;
	        transform: translate(-50%, -50%);
	        background: rgba(255,255,255,0.95);
	        padding: 10px 20px;
	        border-radius: 30px;
	        font-weight: 700;
	        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
	    }

		/* 2. 아래 흰색 본문 영역 (상단을 카드와 똑같이 둥글게) */
		    .main-content {
		        background-color: #fff;
		        /* 카드와 본문이 한 몸처럼 보이기 위해 마진을 조절 */
		        margin-top: -1px; 
		        padding-top: 60px; 
		        position: relative;
		        z-index: 5;
		        
		        /* [핵심] 본문 상단도 둥글게 처리 */
		        border-radius: 24px 24px 0 0; 
		        
		        /* 본문이 올라오면서 생기는 입체감을 위해 그림자 추가 */
		        box-shadow: 0 -10px 30px rgba(0,0,0,0.05);
		    }

	    .section-container { max-width: 1100px; margin: 0 auto 60px; }
	</style>

	<body>
	    <div class="hero-background-wrapper">
	        <img src="${pageContext.request.contextPath}/img/main.jpg">
	    </div>

	    <div class="floating-container">
	        <div class="combined-card">
	            <div class="city-photo-box">
	                <img src="${pageContext.request.contextPath}/img/main.jpg">
	                <div class="city-name-overlay">
	                    <h1>${param.keyword}</h1>
	                </div>
	            </div>
	            <div class="city-map-box" onclick="openMapModal()">
	                <img src="${pageContext.request.contextPath}/img/map-sample.jpg">
	                <div class="map-btn-label">📍 지도로 보기</div>
	            </div>
	        </div>
	    </div>

	    <div class="main-content">
	        <section class="section-container">
	            <div class="section-title-wrap" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; padding:0 10px;">
	                <h2 style="font-size:24px; font-weight:800;">✨ 추천 관광지</h2>
	                <div class="arrow-group">
	                    <button class="arrow-btn" onclick="sideScroll('attractionList', 'left')">←</button>
	                    <button class="arrow-btn" onclick="sideScroll('attractionList', 'right')">→</button>
	                </div>
	            </div>
	            <div class="card-slider" id="attractionList">
	                </div>
	        </section>
	    </div>
	</body>

<script>
    // 1. 슬라이더 이동 (spot.jsp 로직)
    function sideScroll(elementId, direction) {
        const container = document.getElementById(elementId);
        const scrollAmount = 300; // 카드 너비 + 간격
        if (direction === 'left') container.scrollLeft -= scrollAmount;
        else container.scrollLeft += scrollAmount;
    }

    // 2. 카드 렌더링 (spot.jsp 스타일 적용)
    function renderCategory(containerId, title) {
        const container = document.getElementById(containerId);
        let html = '';
        for(let i=1; i<=8; i++) {
            html += `
                <div class="card-item">
                    <img src="${pageContext.request.contextPath}/img/main.jpg">
                    <div class="card-content">
                        <div style="font-weight: 800; font-size: 17px; margin-bottom: 8px;">\${title} 추천 장소 \${i}</div>
                        <div style="font-size: 13px; color: #777;">\${title} 주소와 간단한 설명</div>
                    </div>
                </div>
            `;
        }
        container.innerHTML = html;
    }

    // 초기 실행
    window.onload = () => {
        renderCategory('attractionList', '관광지');
        renderCategory('foodList', '맛집');
    };
	// 지도 보기 버튼 클릭 시 (예: 모달창 띄우기)
	function showMap() {
	    alert('여기에 지도 모달이나 카카오맵 화면을 띄울 예정입니다!');
	    // 나중에 카카오맵 API를 활용해 레이어를 띄우는 코드를 넣으면 됩니다.
	}

	// 기존 sideScroll과 renderCategory는 유지
	function sideScroll(elementId, direction) {
	    const container = document.getElementById(elementId);
	    const scrollAmount = 300;
	    if (direction === 'left') container.scrollLeft -= scrollAmount;
	    else container.scrollLeft += scrollAmount;
	}

	window.onload = () => {
	    // spot.jsp 스타일 카드 렌더링 호출
	    renderCategory('attractionList', '관광지');
	};
</script>
</html>