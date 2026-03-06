<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>여행 지도</title>
    
    <link rel="stylesheet" href="/css/header.css" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="/css/maps.css">

    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a3ff57f5cf42d50dce5ccbd693ebcf24&libraries=services&autoload=false"></script>

    <style>
        .map-layout-wrapper {
            display: flex;
            height: calc(100vh - 75px);
            width: 100%;
            overflow: hidden;
        }
        
        .map-sidebar {
            width: 390px;
            background: #fff;
            box-shadow: 2px 0 15px rgba(0,0,0,0.08);
            z-index: 10;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }
        
        .map-search {
            display: flex;
            gap: 8px;
            padding: 12px 16px; 
            background: #fff;
            border-bottom: 1px solid #f0f0f0;
            z-index: 11;
        }
        .map-search input {
            flex: 1;
            padding: 8px 12px; 
            font-size: 14px;
            border: 1px solid #ddd;
            border-radius: 6px;
            outline: none;
            transition: 0.2s;
        }
        .map-search input:focus {
            border-color: #3264ff;
        }
        .map-search button {
            padding: 8px 16px; 
            background: #333;
            color: #fff;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            font-size: 14px;
            white-space: nowrap; 
            word-break: keep-all;
        }
        
        .sidebar-content-area {
            flex: 1;
            overflow-y: auto;
            padding: 0; 
            scrollbar-width: none;
        }
        .sidebar-content-area::-webkit-scrollbar { display: none; }
        
        .map-area {
            flex: 1;
            position: relative;
        }
        #map {
            width: 100%;
            height: 100%;
        }

        .map-hover-tooltip {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            padding: 16px 20px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.15);
            position: absolute;
            bottom: 50px; 
            left: 50%;
            transform: translateX(-50%);
            width: 310px; 
            pointer-events: none; 
            z-index: 100;
            font-family: 'Pretendard', sans-serif;
        }

        .map-hover-tooltip::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            border-width: 8px 8px 0;
            border-style: solid;
            border-color: #fff transparent transparent transparent;
        }
        
        .tooltip-header {
            display: flex;
            align-items: baseline;
            gap: 8px;
            margin-bottom: 8px;
        }
        .tooltip-title {
            font-size: 20px;
            font-weight: 800;
            color: #1a73e8; 
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .tooltip-cat {
            font-size: 14px;
            color: #888;
            font-weight: 500;
            white-space: nowrap;
        }
        .tooltip-addr {
            font-size: 15px;
            color: #333;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
    </style>
    <script defer src="/js/nav-wave.js"></script>
</head>

<body class="maps-page page-solid">

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="map-layout-wrapper">
    <aside class="map-sidebar">
        <div class="map-search">
            <input type="text" id="keyword" placeholder="장소, 주소 검색 (예: 강남 카페)">
            <button type="button" id="searchBtn">검색</button>
        </div>
        
        <div class="sidebar-content-area">
            <div id="defaultSidebar" style="text-align: center; color: #888; margin-top: 100px;">
                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom: 15px; opacity: 0.5;">
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                    <circle cx="12" cy="10" r="3"></circle>
                </svg>
                <p style="line-height: 1.6; font-size: 15px;">지도에서 마커를 클릭하시면<br>여기에 상세 정보가 표시됩니다.</p>
            </div>
            <div id="sidebarContent" style="display: none;"></div>
        </div>
    </aside>

    <div class="map-area">
        <div id="map"></div>
    </div>
</div>

<script>
	kakao.maps.load(function () {

	    var mapEl = document.getElementById('map');
	    var map = new kakao.maps.Map(mapEl, {
	      center: new kakao.maps.LatLng(37.5665, 126.9780),
	      level: 5
	    });

	    setTimeout(function () {
	      map.relayout();
	      map.setCenter(new kakao.maps.LatLng(37.5665, 126.9780));
	    }, 0);

	    var places = new kakao.maps.services.Places();
	    var searchMarkers = [];
	    var wishMarkers = [];

	    var categoryStyles = {
	        'TOUR': { color: '#888', name: '관광지', icon: 'https://maps.google.com/mapfiles/ms/icons/blue-dot.png' },
	        'STAY': { color: '#888', name: '숙소', icon: 'https://maps.google.com/mapfiles/ms/icons/purple-dot.png' },
	        'ACT':  { color: '#888', name: '액티비티', icon: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png' },
	        'FOOD': { color: '#888', name: '한식/맛집', icon: 'https://maps.google.com/mapfiles/ms/icons/red-dot.png' },
	        'DEFAULT': { color: '#888', name: '기타', icon: 'https://maps.google.com/mapfiles/ms/icons/yellow-dot.png' }
	    };

	    var wishSpots = [
	        <c:forEach var="spot" items="${wishSpots}" varStatus="status">
	        {
	            id: "${spot.id}",
	            name: "${spot.name}",
	            addr: "${spot.addr}",
	            lat: ${spot.lat},
	            lng: ${spot.lng},
	            catCode: "${spot.catCode}",
	            image: "${spot.image}",
	            price: "${spot.price}",
	            hours: "${spot.hours}",
	            holiday: "${spot.holiday}",
	            info: "${spot.info}"
	        }<c:if test="${!status.last}">,</c:if>
	        </c:forEach>
	    ];

	    window.closeSidebar = function() {
	        document.getElementById('sidebarContent').style.display = 'none';
	        document.getElementById('defaultSidebar').style.display = 'block';
	    };

	    var hoverOverlay = new kakao.maps.CustomOverlay({
	        zIndex: 4,
	        clickable: false
	    });

	    if (wishSpots.length > 0) {
	        var wishBounds = new kakao.maps.LatLngBounds();

	        wishSpots.forEach(function(spot) {
	            var position = new kakao.maps.LatLng(spot.lat, spot.lng);
	            var style = categoryStyles[spot.catCode] || categoryStyles['DEFAULT'];
	            var markerImage = new kakao.maps.MarkerImage(style.icon, new kakao.maps.Size(32, 32));

	            var marker = new kakao.maps.Marker({
	                map: map,
	                position: position,
	                image: markerImage,
	                title: spot.name
	            });

	            kakao.maps.event.addListener(marker, 'mouseover', function() {
	                var content = `
	                    <div class="map-hover-tooltip">
	                        <div class="tooltip-header">
	                            <div class="tooltip-title">\${spot.name}</div>
	                            <div class="tooltip-cat">\${style.name}</div>
	                        </div>
	                        <div class="tooltip-addr">\${spot.addr}</div>
	                    </div>
	                `;
	                hoverOverlay.setContent(content);
	                hoverOverlay.setPosition(position);
	                hoverOverlay.setMap(map);
	            });

	            kakao.maps.event.addListener(marker, 'mouseout', function() {
	                hoverOverlay.setMap(null);
	            });

	            kakao.maps.event.addListener(marker, 'click', function () {
	                var imgSrc = spot.image ? spot.image : '${pageContext.request.contextPath}/img/hero.jpg';
	                
	                var sidebarHtml = `
	                    <div style="position: relative; width: 100%; height: 230px;">
	                        <img src="\${imgSrc}" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.src='${pageContext.request.contextPath}/img/hero.jpg'">
	                        <button onclick="closeSidebar()" style="position: absolute; top: 15px; right: 15px; background: rgba(0,0,0,0.4); color: #fff; border: none; border-radius: 50%; width: 32px; height: 32px; font-size: 20px; cursor: pointer; display: flex; align-items: center; justify-content: center;">×</button>
	                    </div>
	                    
	                    <div style="padding: 24px;">
	                        <div style="display: flex; align-items: baseline; gap: 8px; margin-bottom: 8px;">
	                            <h2 style="margin: 0; font-size: 24px; font-weight: 800; color: #111;">\${spot.name}</h2>
	                            <span style="font-size: 14px; color: #777;">\${style.name}</span>
	                        </div>
	                        
	                        <div style="font-size: 14px; color: #555; margin-bottom: 18px;">
	                            <span style="color: #ffc107;">★</span> \${spot.price} 
	                            <span style="color: #ddd; margin: 0 6px;">
	                        </div>

	                        <div style="display: flex; gap: 10px; margin-bottom: 24px;">
	                            <a href="${pageContext.request.contextPath}/spots/detail/\${spot.id}" style="flex: 1; padding: 14px; border-radius: 8px; background: #eef2ff; color: #3264ff; text-align: center; font-weight: bold; text-decoration: none; font-size: 15px;">상세보기</a>
	                            <a href="${pageContext.request.contextPath}/plans/planRoute" style="flex: 1; padding: 14px; border-radius: 8px; background: #3264ff; color: #fff; text-align: center; font-weight: bold; text-decoration: none; font-size: 15px;">일정 추가</a>
	                        </div>

	                        <div style="display: flex; flex-direction: column; gap: 16px; font-size: 14px; color: #333;">
	                            <div style="display: flex; gap: 12px; align-items: flex-start;">
	                                <span style="color: #aaa; font-size: 16px; margin-top: 2px;">📌</span>
	                                <span style="line-height: 1.5;">\${spot.addr}</span>
	                            </div>
	                            <div style="display: flex; gap: 12px; align-items: flex-start;">
	                                <span style="color: #aaa; font-size: 16px; margin-top: 2px;">🕒</span>
	                                <span style="line-height: 1.5;">
	                                    \${spot.hours}<br>
	                                    <span style="color: #ef4444; font-size: 13px;">\${spot.holiday}</span>
	                                </span>
	                            </div>
	                            <div style="display: flex; gap: 12px; align-items: flex-start;">
	                                <span style="color: #aaa; font-size: 16px; margin-top: 2px;">📝</span>
	                                <span style="line-height: 1.6; word-break: keep-all; color:#555;">\${spot.info}</span>
	                            </div>
	                        </div>
	                    </div>
	                `;

	                document.getElementById('defaultSidebar').style.display = 'none';
	                document.getElementById('sidebarContent').innerHTML = sidebarHtml;
	                document.getElementById('sidebarContent').style.display = 'block';
	                
	                map.panTo(position);
	            });

	            wishMarkers.push(marker);
	            wishBounds.extend(position);
	        });

	        map.setBounds(wishBounds);
	    }

	    function searchPlace() {
	      const keyword = document.getElementById("keyword").value.trim();
	      if (!keyword) {
	        alert("검색어를 입력하세요");
	        return;
	      }
	      places.keywordSearch(keyword, placesSearchCB);
	    }

	    function placesSearchCB(data, status) {
	      if (status !== kakao.maps.services.Status.OK) {
	        alert("검색 결과가 없습니다");
	        return;
	      }

	      searchMarkers.forEach(m => m.setMap(null));
	      searchMarkers = [];

	      var bounds = new kakao.maps.LatLngBounds();

	      data.forEach(place => {
	        var position = new kakao.maps.LatLng(place.y, place.x);
	        var marker = new kakao.maps.Marker({
	          map: map,
	          position: position
	        });

	        kakao.maps.event.addListener(marker, 'mouseover', function() {
	            var catName = place.category_group_name ? place.category_group_name : '검색결과';
	            var addrName = place.road_address_name || place.address_name;
	            var content = `
	                <div class="map-hover-tooltip">
	                    <div class="tooltip-header">
	                        <div class="tooltip-title">\${place.place_name}</div>
	                        <div class="tooltip-cat">\${catName}</div>
	                    </div>
	                    <div class="tooltip-addr">\${addrName}</div>
	                </div>
	            `;
	            hoverOverlay.setContent(content);
	            hoverOverlay.setPosition(position);
	            hoverOverlay.setMap(map);
	        });

	        kakao.maps.event.addListener(marker, 'mouseout', function() {
	            hoverOverlay.setMap(null);
	        });

	        kakao.maps.event.addListener(marker, 'click', function () {
	            var sidebarHtml = `
	                <div style="position: relative; width: 100%; height: 230px; background: #eee;">
	                    <button onclick="closeSidebar()" style="position: absolute; top: 15px; right: 15px; background: rgba(0,0,0,0.4); color: #fff; border: none; border-radius: 50%; width: 32px; height: 32px; font-size: 20px; cursor: pointer; display: flex; align-items: center; justify-content: center;">×</button>
	                </div>
	                <div style="padding: 24px;">
	                    <div style="display: flex; align-items: baseline; gap: 8px; margin-bottom: 24px;">
	                        <h2 style="margin: 0; font-size: 24px; font-weight: 800; color: #111;">\${place.place_name}</h2>
	                        <span style="font-size: 14px; color: #777;">\${place.category_group_name || '검색결과'}</span>
	                    </div>

	                    <div style="display: flex; gap: 10px; margin-bottom: 24px;">
	                        <a href="${pageContext.request.contextPath}/plans/planRoute" style="flex: 1; padding: 14px; border-radius: 8px; background: #3264ff; color: #fff; text-align: center; font-weight: bold; text-decoration: none; font-size: 15px;">일정 추가</a>
	                    </div>
	                    
	                    <div style="display: flex; flex-direction: column; gap: 16px; font-size: 14px; color: #333;">
	                        <div style="display: flex; gap: 12px; align-items: flex-start;">
	                            <span style="color: #aaa; font-size: 16px;">📌</span>
	                            <span style="line-height: 1.5;">\${place.road_address_name || place.address_name}</span>
	                        </div>
	                        \${place.phone ? `
	                        <div style="display: flex; gap: 12px; align-items: flex-start;">
	                            <span style="color: #aaa; font-size: 16px;">📞</span>
	                            <span style="line-height: 1.5; color: #3264ff; font-weight: bold;">\${place.phone}</span>
	                        </div>
	                        ` : ''}
	                    </div>
	                </div>
	            `;
	            
	            document.getElementById('defaultSidebar').style.display = 'none';
	            document.getElementById('sidebarContent').innerHTML = sidebarHtml;
	            document.getElementById('sidebarContent').style.display = 'block';
	            
	            map.panTo(position);
	        });

	        searchMarkers.push(marker);
	        bounds.extend(position);
	      });

	      map.setBounds(bounds);
	    }

	    document.getElementById("searchBtn").addEventListener("click", function (e) {
	      e.preventDefault();
	      searchPlace();
	    });

	});
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>

</body>
</html>