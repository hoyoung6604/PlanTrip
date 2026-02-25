<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
	 <meta charset="UTF-8">
	    <title>여행 지도</title>
	    
	<meta name="viewport" content="width=device-width, initial-scale=1">

	    <!-- 공통 CSS -->
	    <link rel="stylesheet" href="/css/home.css">
	    <link rel="stylesheet" href="/css/maps.css">


    <!-- ✅ 카카오 지도 API (autoload=false로 바꿔서, load() 안에서 초기화) -->
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a3ff57f5cf42d50dce5ccbd693ebcf24&libraries=services&autoload=false"></script>

    <style>
        #map {
            width: 100%;
            height: calc(100vh - 140px);
        }

        .map-search {
            display: flex;
            gap: 8px;
            padding: 10px;
            background: #fff;
            border-bottom: 1px solid #ddd;
        }

        .map-search input {
            flex: 1;
            padding: 8px;
            font-size: 14px;
        }

        .map-search button {
            padding: 8px 16px;
            background: #333;
            color: #fff;
            border: none;
            cursor: pointer;
        }

        .info-window {
            padding: 8px;
            font-size: 13px;
            line-height: 1.4;
        }
        .info-window b {
            font-size: 14px;
        }
    </style>
</head>

<!-- ✅ 지도 페이지 전용 클래스 -->
<body class="maps-page">

<header class="header">
  <div class="header-inner container">
    <a href="/" class="brand-top">
      <img src="/img/PlanTriplog.png" alt="여행 플래너" class="brand-logo-img">
    </a>

    <nav class="nav">
      <a href="/plan" class="header-link">여행 계획</a>
      <a href="/maps" class="header-link active">지도</a>

      <div class="hamburger">
        <button class="hamburger-btn" type="button"
                onclick="document.getElementById('hm').classList.toggle('open')">
          <span></span><span></span><span></span>
        </button>

        <div class="hamburger-menu" id="hm">
          <!-- 기존 c:if 그대로 유지 -->
        </div>
      </div>
    </nav>
  </div>
</header>

<div class="map-search">
    <input type="text" id="keyword" placeholder="지역 또는 장소 검색 (예: 강남, 부산, 카페)">
    <button type="button" id="searchBtn">검색</button>
</div>

<div id="map"></div>

<script>
  // ✅ SDK가 준비된 다음에만 지도 초기화
  kakao.maps.load(function () {

    // 지도 생성
    var mapEl = document.getElementById('map');
    var map = new kakao.maps.Map(mapEl, {
      center: new kakao.maps.LatLng(37.5665, 126.9780),
      level: 5
    });

    // ✅ 레이아웃 계산 한번 갱신 (가끔 “빈 화면” 방지)
    setTimeout(function () {
      map.relayout();
      map.setCenter(new kakao.maps.LatLng(37.5665, 126.9780));
    }, 0);

    // 장소 검색 서비스
    var places = new kakao.maps.services.Places();

    // 마커 + 인포윈도우
    var markers = [];
    var infoWindow = new kakao.maps.InfoWindow({ zIndex: 1 });

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

      // 기존 마커 제거
      markers.forEach(m => m.setMap(null));
      markers = [];

      var bounds = new kakao.maps.LatLngBounds();

      data.forEach(place => {
        var position = new kakao.maps.LatLng(place.y, place.x);

        var marker = new kakao.maps.Marker({
          map: map,
          position: position
        });

        kakao.maps.event.addListener(marker, 'click', function () {
          var content =
            '<div class="info-window">' +
              '<b>' + place.place_name + '</b><br>' +
              (place.road_address_name || place.address_name) + '<br>' +
              (place.phone ? '☎ ' + place.phone : '') +
            '</div>';

          infoWindow.setContent(content);
          infoWindow.open(map, marker);
        });

        markers.push(marker);
        bounds.extend(position);
      });

      map.setBounds(bounds);
    }

    document.getElementById("searchBtn").addEventListener("click", function (e) {
      e.preventDefault();
      searchPlace();
    });

    // 햄버거 외부 클릭 시 닫기
    document.addEventListener("click", function(e) {
      const hm = document.getElementById("hm");
      const btn = document.querySelector(".hamburger-btn");
      if (!hm.contains(e.target) && !btn.contains(e.target)) {
        hm.classList.remove("open");
      }
    });

  });
</script>

</body>
</html>
