<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>여행지 목록</title>

    <link rel="stylesheet" href="/css/header.css" />
    <script src="/js/theme.js"></script>
    <script defer src="/js/nav-wave.js"></script>

    <style>
        body {
            font-family: 'Pretendard', sans-serif;
            color: #333;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background: #fff !important;
        }

        .section-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .city-nav {
            display: flex;
            gap: 15px;
            margin-bottom: 40px;
            overflow-x: auto;
            padding: 20px 5px;
            scrollbar-width: none;
            /* 스크롤바 숨기기 */
        }

        .city-nav::-webkit-scrollbar {
            display: none;
        }

        .city-btn {
            /* 버튼 크기 및 배경 설정 */
            min-width: 160px;
            height: 100px;
            border: none;
            border-radius: 15px;
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;

            /* 텍스트 배치 및 스타일 */
            cursor: pointer;
            font-weight: 800;
            font-size: 18px;
            color: white;
            display: flex;
            align-items: flex-end;
            /* 텍스트를 버튼 아래쪽에 배치 */
            padding: 15px;
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        /* 이미지 위에 글자가 잘 보이도록 어둡게 덮는 효과 */
        .city-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(to top, rgba(0, 0, 0, 0.7) 0%, rgba(0, 0, 0, 0) 60%);
            z-index: 1;
        }

        /* 글자가 효과 레이어보다 위에 오도록 설정 */
        .city-btn span {
            position: relative;
            z-index: 2;
            text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.5);
        }

        /* 활성화(선택) 되었을 때 스타일 */
        .city-btn.active {
            transform: translateY(-8px);
            /* 살짝 위로 떠오름 */
            box-shadow: 0 8px 20px rgba(50, 100, 255, 0.4);
            outline: 4px solid #3264ff;
            /* 파란색 테두리 */
            outline-offset: -4px;
            background-size: cover;
        }

        /* 슬라이더 및 카드 스타일 */
        .slider-wrapper {
            position: relative;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 60px;
        }

        .card-container {
            display: flex;
            overflow-x: hidden;
            scroll-behavior: smooth;
            gap: 20px;
            width: 100%;
            padding: 10px 5px;
        }

        .card-item {
            min-width: calc(25% - 15px);
            max-width: calc(25% - 15px);
            flex-shrink: 0;
        }

        .card {
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            background: white;
            transition: 0.3s;
            height: 100%;
        }

        .card:hover {
            transform: translateY(-5px);
        }

        /* ===== Trip.com 느낌의 카드 디자인 ===== */
        .spot-link {
            text-decoration: none;
            color: inherit;
            display: block;
        }

        .spot-card {
            border-radius: 18px;
            overflow: hidden;
            background: transparent;
        }

        .spot-thumb {
            position: relative;
            width: 100%;
            height: 300px;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 10px 28px rgba(0, 0, 0, 0.12);
            transition: transform .25s ease, box-shadow .25s ease;
        }

        .spot-thumb:hover {
            transform: translateY(-6px);
            box-shadow: 0 16px 38px rgba(0, 0, 0, 0.18);
        }

        .spot-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transform: scale(1.02);
        }

        .spot-overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(to top, rgba(0, 0, 0, .70), rgba(0, 0, 0, .08) 60%, rgba(0, 0, 0, 0));
            pointer-events: none;
        }

        .spot-text {
            position: absolute;
            left: 14px;
            right: 14px;
            bottom: 14px;
            z-index: 2;
        }

        .spot-title {
            font-weight: 800;
            font-size: 18px;
            color: #fff;
            white-space: nowrap;
            overflow: hidden;
            text-shadow: 0 2px 10px rgba(0, 0, 0, .35);
        }

        .spot-addr {
            margin-top: 6px;
            font-size: 13px;
            color: rgba(255, 255, 255, .88);
            white-space: nowrap;
            overflow: hidden;
            text-shadow: 0 2px 10px rgba(0, 0, 0, .35);
        }

        /* ===== 긴 제목/주소는 자동으로 옆으로 흐르게(마키) ===== */
        .spot-title.is-marquee,
        .spot-addr.is-marquee {
            padding-right: 10px;
        }

        .spot-marquee-track {
            display: inline-flex;
            align-items: center;
            gap: 22px;
            will-change: transform;
            animation: spotMarquee var(--spotMarqueeDur, 10s) linear infinite;
        }

        @keyframes spotMarquee {
            from {
                transform: translateX(0);
            }

            to {
                transform: translateX(calc(-1 * var(--spotMarqueeDist, 120px)));
            }
        }

        /* 기본 하트 버튼 스타일 (메인 및 상세 공통) */
        .wish-btn {
            position: absolute !important;
            top: 12px !important;
            right: 12px !important;
            z-index: 100 !important;
            background: rgba(255, 255, 255, 0.9) !important;
            border: none;
            border-radius: 50%;
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
            cursor: pointer;
            font-size: 18px;
            visibility: visible !important;
        }

        .wish-btn,
        .wish-btn-large {
            transition: all 0.2s ease;
            outline: none;
        }

        .wish-btn:hover,
        .wish-btn-large:hover {
            background-color: #f9f9f9;
            transform: scale(1.1);
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.15);
        }

        .wish-btn:active,
        .wish-btn-large:active {
            transform: scale(0.9);
        }

        .wish-btn.active,
        .wish-btn-large.active {
            border-color: #ff4b4b;
            color: #ff4b4b;
        }

        .nav-btn {
            background: white;
            border: none;
            border-radius: 50%;
            width: 45px;
            height: 45px;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            font-size: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        h2 {
            font-size: 24px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
    </style>
</head>

<body class="page-solid">
    <jsp:include page="/WEB-INF/views/common/header.jsp" />
    <div class="section-container">
        <h1 style="font-size: 32px; font-weight: 800; margin-top: 50px; margin-left: 60px;">대한민국에서 놓치면 안 될 인기 도시</h1>

        <%-- 1. 도시 선택 버튼 --%>
        <div class="slider-wrapper" style="margin-top: 40px; margin-bottom: 50px;">
            <button class="nav-btn" onclick="sideScroll('city-slider', 'left')">‹</button>

			<div class="card-container" id="city-slider">
			    <button type="button" onclick="loadCity(4, this)" class="card-item city-btn ${selectedCity == 4 ? 'active' : ''}" style="background-image: url('${pageContext.request.contextPath}/img/city/4.jpg');"><span>서울</span></button>
			    <button type="button" onclick="loadCity(1, this)" class="card-item city-btn ${selectedCity == 1 ? 'active' : ''}" style="background-image: url('${pageContext.request.contextPath}/img/city/1.jpg');"><span>부산</span></button>
			    <button type="button" onclick="loadCity(2, this)" class="card-item city-btn ${selectedCity == 2 ? 'active' : ''}" style="background-image: url('${pageContext.request.contextPath}/img/city/2.jpg');"><span>제주도</span></button>
			    <button type="button" onclick="loadCity(7, this)" class="card-item city-btn ${selectedCity == 7 ? 'active' : ''}" style="background-image: url('${pageContext.request.contextPath}/img/city/7.jpg');"><span>강릉</span></button>
			    <button type="button" onclick="loadCity(5, this)" class="card-item city-btn ${selectedCity == 5 ? 'active' : ''}" style="background-image: url('${pageContext.request.contextPath}/img/city/5.jpg');"><span>경주</span></button>
			    <button type="button" onclick="loadCity(3, this)" class="card-item city-btn ${selectedCity == 3 ? 'active' : ''}" style="background-image: url('${pageContext.request.contextPath}/img/city/3.jpg');"><span>수원</span></button>
			    <button type="button" onclick="loadCity(6, this)" class="card-item city-btn ${selectedCity == 6 ? 'active' : ''}" style="background-image: url('${pageContext.request.contextPath}/img/city/6.jpg');"><span>속초</span></button>
			</div>

            <button class="nav-btn" onclick="sideScroll('city-slider', 'right')">›</button>
        </div>

        <%-- 2. 인기 관광지 섹션 (TOUR) --%>
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 0 65px;">
            <h2>인기 관광지</h2>
            <a href="${pageContext.request.contextPath}/spots/all?cityId=${selectedCity}&catCode=TOUR" class="all-link" data-cat="TOUR" style="color: #888; text-decoration: none; font-size: 14px;">전체보기 ></a>
        </div>

        <div class="slider-wrapper">
            <button class="nav-btn" onclick="sideScroll('tour-slider', 'left')">‹</button>
            <div class="card-container" id="tour-slider">
                <j:if test="${empty tourList}">
                    <p style="padding: 20px; color: #999;">등록된 관광지가 없습니다.</p>
                </j:if>
                <j:forEach var="s" items="${tourList}">
                    <div class="card-item" style="position: relative;">
                        <button class="wish-btn ${s.isHearted ? 'active' : ''}" type="button" onclick="toggleWish(event, ${s.id}, this)">
                            ${s.isHearted ? '❤️' : '🤍'}
                        </button>
                        <a class="spot-link" href="${pageContext.request.contextPath}/spots/detail/${s.id}">
                            <div class="spot-card">
                                <div class="spot-thumb">
                                    <img class="spot-img" src="${pageContext.request.contextPath}/img/spot/${s.id}_1.jpg" alt="${s.name}" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/img/hero.jpg';" />
                                    <div class="spot-overlay"></div>
                                    <div class="spot-text">
                                        <div class="spot-title" data-marquee-text>${s.name}</div>
                                        <div class="spot-addr" data-marquee-text>${s.addr}</div>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </div>
                </j:forEach>
            </div>
            <button class="nav-btn" onclick="sideScroll('tour-slider', 'right')">›</button>
        </div>

        <%-- 3. 추천 숙소 섹션 (STAY) --%>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding: 0 65px;">
            <h2 style="margin: 0;">추천 숙소</h2>
            <a href="${pageContext.request.contextPath}/spots/all?cityId=${selectedCity}&catCode=STAY" class="all-link" data-cat="STAY" style="color: #888; text-decoration: none; font-size: 14px;">전체보기 ></a>
        </div>
        <div class="slider-wrapper">
            <button class="nav-btn" onclick="sideScroll('stay-slider', 'left')">‹</button>
            <div class="card-container" id="stay-slider">
                <j:if test="${empty stayList}">
                    <p style="padding: 20px; color: #999;">등록된 숙소가 없습니다.</p>
                </j:if>
                <j:forEach var="s" items="${stayList}">
                    <div class="card-item" style="position: relative;">
                        <button class="wish-btn ${s.isHearted ? 'active' : ''}" type="button" onclick="toggleWish(event, ${s.id}, this)">
                            ${s.isHearted ? '❤️' : '🤍'}
                        </button>
                        <a class="spot-link" href="${pageContext.request.contextPath}/spots/detail/${s.id}">
                            <div class="spot-card">
                                <div class="spot-thumb">
                                    <img class="spot-img" src="${pageContext.request.contextPath}/img/spot/${s.id}_1.jpg" alt="${s.name}" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/img/hero.jpg';" />
                                    <div class="spot-overlay"></div>
                                    <div class="spot-text">
                                        <div class="spot-title" data-marquee-text>${s.name}</div>
                                        <div class="spot-addr" data-marquee-text>${s.addr}</div>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </div>
                </j:forEach>
            </div>
            <button class="nav-btn" onclick="sideScroll('stay-slider', 'right')">›</button>
        </div>

        <%-- 4. 문화/액티비티 섹션 (ACT) --%>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding: 0 65px;">
            <h2 style="margin: 0;">문화/액티비티</h2>
            <a href="${pageContext.request.contextPath}/spots/all?cityId=${selectedCity}&catCode=ACT" class="all-link" data-cat="ACT" style="color: #888; text-decoration: none; font-size: 14px;">전체보기 ></a>
        </div>
        <div class="slider-wrapper">
            <button class="nav-btn" onclick="sideScroll('act-slider', 'left')">‹</button>
            <div class="card-container" id="act-slider">
                <j:if test="${empty actList}">
                    <p style="padding: 20px; color: #999;">등록된 액티비티가 없습니다.</p>
                </j:if>
                <j:forEach var="s" items="${actList}">
                    <div class="card-item" style="position: relative;">
                        <button class="wish-btn ${s.isHearted ? 'active' : ''}" type="button" onclick="toggleWish(event, ${s.id}, this)">
                            ${s.isHearted ? '❤️' : '🤍'}
                        </button>
                        <a class="spot-link" href="${pageContext.request.contextPath}/spots/detail/${s.id}">
                            <div class="spot-card">
                                <div class="spot-thumb">
                                    <img class="spot-img" src="${pageContext.request.contextPath}/img/spot/${s.id}_1.jpg" alt="${s.name}" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/img/hero.jpg';" />
                                    <div class="spot-overlay"></div>
                                    <div class="spot-text">
                                        <div class="spot-title" data-marquee-text>${s.name}</div>
                                        <div class="spot-addr" data-marquee-text>${s.addr}</div>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </div>
                </j:forEach>
            </div>
            <button class="nav-btn" onclick="sideScroll('act-slider', 'right')">›</button>
        </div>

        <%-- 5. 추천 맛집 섹션 (FOOD) --%>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding: 0 65px;">
            <h2 style="margin: 0;">추천 맛집</h2>
            <a href="${pageContext.request.contextPath}/spots/all?cityId=${selectedCity}&catCode=FOOD" class="all-link" data-cat="FOOD" style="color: #888; text-decoration: none; font-size: 14px;">전체보기 ></a>
        </div>
        <div class="slider-wrapper">
            <button class="nav-btn" onclick="sideScroll('food-slider', 'left')">‹</button>
            <div class="card-container" id="food-slider">
                <j:if test="${empty foodList}">
                    <p style="padding: 20px; color: #999;">등록된 맛집이 없습니다.</p>
                </j:if>
                <j:forEach var="s" items="${foodList}">
                    <div class="card-item" style="position: relative;">
                        <button class="wish-btn ${s.isHearted ? 'active' : ''}" type="button" onclick="toggleWish(event, ${s.id}, this)">
                            ${s.isHearted ? '❤️' : '🤍'}
                        </button>
                        <a class="spot-link" href="${pageContext.request.contextPath}/spots/detail/${s.id}">
                            <div class="spot-card">
                                <div class="spot-thumb">
                                    <img class="spot-img" src="${pageContext.request.contextPath}/img/spot/${s.id}_1.jpg" alt="${s.name}" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/img/hero.jpg';" />
                                    <div class="spot-overlay"></div>
                                    <div class="spot-text">
                                        <div class="spot-title" data-marquee-text>${s.name}</div>
                                        <div class="spot-addr" data-marquee-text>${s.addr}</div>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </div>
                </j:forEach>
            </div>
            <button class="nav-btn" onclick="sideScroll('food-slider', 'right')">›</button>
        </div>

        <script>
            const CONTEXT_PATH = "${pageContext.request.contextPath}";

            function loadCity(cityId, btn) {
                if (!btn) return;

                sessionStorage.setItem("lastCityId", cityId);

                document.querySelectorAll('.city-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');

                // 전체보기 링크 갱신
                document.querySelectorAll('.all-link').forEach(link => {
                    const catCode = link.getAttribute('data-cat');
                    link.href = CONTEXT_PATH + "/spots/all?cityId=" + cityId + "&catCode=" + catCode;
                });

                fetch(CONTEXT_PATH + "/spots/api/contents?cityId=" + cityId)
                    .then(res => res.json())
                    .then(data => {
                        renderSection('tour-slider', data.tourList);
                        renderSection('stay-slider', data.stayList);
                        renderSection('act-slider', data.actList);
                        renderSection('food-slider', data.foodList);
                    })
                    .catch(err => console.error("데이터 로딩 실패:", err));
            }

            // ✅ 마키(옆으로 흐름) 적용
            function initSpotMarquee(scopeEl) {
                if (!scopeEl) return;
                const nodes = scopeEl.querySelectorAll('[data-marquee-text]');
                nodes.forEach(el => {
                    if (el.dataset && el.dataset.marqueeInit === "1") return;

                    const txt = (el.textContent || '').trim();
                    if (!txt) return;

                    requestAnimationFrame(() => {
                        const need = el.scrollWidth > el.clientWidth + 2;
                        if (!need) {
                            el.dataset.marqueeInit = "1";
                            return;
                        }

                        el.classList.add('is-marquee');

                        const track = document.createElement('span');
                        track.className = 'spot-marquee-track';

                        const a = document.createElement('span');
                        a.className = 'spot-marquee-item';
                        a.textContent = txt;

                        const b = document.createElement('span');
                        b.className = 'spot-marquee-item';
                        b.textContent = txt;

                        track.appendChild(a);
                        track.appendChild(b);

                        const dist = a.getBoundingClientRect().width + 22;
                        const speed = 50;
                        const dur = Math.max(6, dist / speed);

                        track.style.setProperty('--spotMarqueeDist', dist + 'px');
                        track.style.setProperty('--spotMarqueeDur', dur + 's');

                        el.innerHTML = '';
                        el.appendChild(track);

                        el.dataset.marqueeInit = "1";
                    });
                });
            }

            function renderSection(containerId, list) {
                const container = document.getElementById(containerId);
                if (!container) return;

                container.innerHTML = '';
                if (!list || list.length === 0) {
                    container.innerHTML = '<p style="padding:40px; color:#999; text-align:center; width:100%;">등록된 정보가 없습니다. 😊</p>';
                    return;
                }

                list.forEach(s => {
                    const spotId = s.id || s.s_idx || s.sIdx;
                    const spotName = s.name || s.s_name || s.sname || '이름 없음';
                    const spotAddr = s.addr || s.s_addr || s.saddr || '주소 정보 없음';
                    const isHearted = s.isHearted || false;

                    // DB 데이터에 상관없이 무조건 '번호_1.jpg' 경로 생성
                    const spotImg = CONTEXT_PATH + '/img/spot/' + spotId + '_1.jpg';

                    const cardHtml = `
                    <div class="card-item" style="position: relative;">
                        <button class="wish-btn \${isHearted ? 'active' : ''}" 
                                type="button" 
                                onclick="toggleWish(event, \${spotId}, this)" 
                                style="position: absolute; top: 12px; right: 12px; z-index: 10;">
                            \${isHearted ? '❤️' : '🤍'}
                        </button>
                        <a class="spot-link" href="${pageContext.request.contextPath}/spots/detail/\${spotId}">
                            <div class="spot-card">
                                <div class="spot-thumb">
                                    <img class="spot-img" src="\${spotImg}" alt="\${spotName}"
                                         onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/img/hero.jpg';" />
                                    <div class="spot-overlay"></div>
                                    <div class="spot-text">
                                        <div class="spot-title" data-marquee-text>\${spotName}</div>
                                        <div class="spot-addr" data-marquee-text>\${spotAddr}</div>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </div>
                    `;
                    container.insertAdjacentHTML('beforeend', cardHtml);
                });

                initSpotMarquee(container);
            }

            function sideScroll(elementId, direction) {
                const container = document.getElementById(elementId);
                const card = container.querySelector('.card-item');
                if (!card) return;
                const scrollAmount = card.clientWidth + 20;
                if (direction === 'left') container.scrollLeft -= scrollAmount;
                else container.scrollLeft += scrollAmount;
            }

            document.addEventListener("DOMContentLoaded", function () {
                const savedCityId = sessionStorage.getItem("lastCityId") || "4";
                const buttons = document.querySelectorAll('.city-btn');
                let targetBtn = null;

                buttons.forEach(btn => {
                    if (btn.getAttribute('onclick').includes(savedCityId)) {
                        targetBtn = btn;
                    }
                });

                if (targetBtn) {
                    loadCity(savedCityId, targetBtn);
                } else if (buttons.length > 0) {
                    loadCity("4", buttons[0]);
                }
            });

            function toggleWish(event, sIdx, btn) {
                event.preventDefault();
                event.stopPropagation();
                fetch('/api/wish/toggle', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({sIdx: sIdx})
                })
                .then(response => {
                    if (response.status === 401) {
                        if (window.LoginRequiredPrompt) { window.LoginRequiredPrompt.open(); } else { alert('로그인이 필요한 서비스입니다.'); }
                        return;
                    }
                    return response.json();
                })
                .then(data => {
                    if (data && data.success) {
                        btn.innerText = data.isHearted ? '❤️' : '🤍';
                        if (data.isHearted) {
                            btn.classList.add('active');
                        } else {
                            btn.classList.remove('active');
                        }
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('처리 중 오류가 발생했습니다.');
                });
            }
        </script>
    </div>
    <%@ include file="/WEB-INF/views/common/footer.jspf" %>
</body>
</html>