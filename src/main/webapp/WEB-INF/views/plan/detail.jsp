<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>${spot.name} | 관광지</title>
  <link rel="stylesheet" href="/css/home.css"/>

  <!-- Leaflet (지도) -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
</head>
<body>

<div class="container" style="padding:24px 0;">
  <div style="display:flex; align-items:flex-end; justify-content:space-between; gap:12px; margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:24px;">${spot.name}</h1>
      <p style="margin:6px 0 0; color:#6b7280;">
        <j:if test="${not empty spot.city}">${spot.city.name}</j:if>
        <j:if test="${not empty spot.addr}"> · ${spot.addr}</j:if>
      </p>
    </div>
    <a class="btn" href="${pageContext.request.contextPath}/spots?cat=${spot.catCode}">목록으로</a>
  </div>

  <div style="display:flex; gap:18px; align-items:flex-start;">

	<j:set var="uri" value="${pageContext.request.requestURI}" />
	<j:set var="selectedRegion" value="${empty param.region ? 'GYEONGJU' : param.region}" />
	<j:set var="selectedCat" value="${empty param.cat ? 'CITY' : param.cat}" />

	<aside style="width:260px;">
	  <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:14px;">
	    <div style="font-weight:800; margin-bottom:10px;">추천 여행지</div>

	    <div style="display:flex; flex-direction:column; gap:8px;">

	      <!-- ===================== 경주 ===================== -->
	      <a class="btn ${selectedRegion eq 'GYEONGJU' ? 'solid' : ''}"
	         href="${pageContext.request.contextPath}/spot/${spot.id}?region=GYEONGJU&cat=${selectedCat}"
	         style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
	        경주
	      </a>

		  <j:if test="${selectedRegion eq 'GYEONGJU'}">
		    <div style="display:flex; flex-direction:column; gap:8px; padding:6px 2px 10px 2px;">

		      <a class="btn ${selectedCat eq 'CITY' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=CITY"
		         style="width:100%;">관광지</a>

		      <a class="btn ${selectedCat eq 'HOTEL' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=HOTEL"
		         style="width:100%;">숙소</a>

		      <a class="btn ${selectedCat eq 'FOOD' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=FOOD"
		         style="width:100%;">맛집</a>
					 
			  <a class="btn ${selectedCat eq 'ACT' ? 'solid' : ''}"
				  href="${pageContext.request.contextPath}/spot/${spot.id}?region=GYEONGJU&cat=ACT"
				  style="width:100%; text-align:left;">
				 문화/액티비티</a>

		    </div>
		  </j:if>

	      <!-- ===================== 부산 ===================== -->
	      <a class="btn ${selectedRegion eq 'BUSAN' ? 'solid' : ''}"
	         href="${pageContext.request.contextPath}/spot/${spot.id}?region=BUSAN&cat=${selectedCat}"
	         style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
	        부산
	      </a>

		  <j:if test="${selectedRegion eq 'BUSAN'}">
		    <div style="display:flex; flex-direction:column; gap:8px; padding:6px 2px 10px 2px;">

		      <a class="btn ${selectedCat eq 'CITY' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=CITY"
		         style="width:100%;">관광지</a>

		      <a class="btn ${selectedCat eq 'HOTEL' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=HOTEL"
		         style="width:100%;">숙소</a>

		      <a class="btn ${selectedCat eq 'FOOD' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=FOOD"
		         style="width:100%;">맛집</a>
				 
			  <a class="btn ${selectedCat eq 'ACT' ? 'solid' : ''}"
				 href="${pageContext.request.contextPath}/spot/${spot.id}?region=GYEONGJU&cat=ACT"
    			 style="width:100%; text-align:left;">
				 문화/액티비티</a>

		    </div>
		  </j:if>

	      <!-- ===================== 수원 ===================== -->
	      <a class="btn ${selectedRegion eq 'SUWON' ? 'solid' : ''}"
	         href="${pageContext.request.contextPath}/spot/${spot.id}?region=SUWON&cat=${selectedCat}"
	         style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
	        수원
	      </a>

		  <j:if test="${selectedRegion eq 'SUWON'}">
		    <div style="display:flex; flex-direction:column; gap:8px; padding:6px 2px 10px 2px;">

		      <a class="btn ${selectedCat eq 'CITY' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=CITY"
		         style="width:100%;">관광지</a>

		      <a class="btn ${selectedCat eq 'HOTEL' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=HOTEL"
		         style="width:100%;">숙소</a>

		      <a class="btn ${selectedCat eq 'FOOD' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=FOOD"
		         style="width:100%;">맛집</a>
				 
			  <a class="btn ${selectedCat eq 'ACT' ? 'solid' : ''}"
				 href="${pageContext.request.contextPath}/spot/${spot.id}?region=GYEONGJU&cat=ACT"
		  		 style="width:100%; text-align:left;">
				 문화/액티비티</a>

		    </div>
		  </j:if>

	      <!-- ===================== 제주도 ===================== -->
	      <a class="btn ${selectedRegion eq 'JEJU' ? 'solid' : ''}"
	         href="${pageContext.request.contextPath}/spot/${spot.id}?region=JEJU&cat=${selectedCat}"
	         style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
	        제주도
	      </a>
		  <j:if test="${selectedRegion eq 'JEJU'}">
		    <div style="display:flex; flex-direction:column; gap:8px; padding:6px 2px 10px 2px;">

		      <a class="btn ${selectedCat eq 'CITY' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=CITY"
		         style="width:100%;">관광지</a>

		      <a class="btn ${selectedCat eq 'HOTEL' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=HOTEL"
		         style="width:100%;">숙소</a>

		      <a class="btn ${selectedCat eq 'FOOD' ? 'solid' : ''}"
		         href="?region=GYEONGJU&cat=FOOD"
		         style="width:100%;">맛집</a>
				 
			  <a class="btn ${selectedCat eq 'ACT' ? 'solid' : ''}"
				 href="${pageContext.request.contextPath}/spot/${spot.id}?region=GYEONGJU&cat=ACT"
				 style="width:100%; text-align:left;">
				 문화/액티비티</a>
		    </div>
		  </j:if>
	    </div>
	  </div>
	</aside>
    <!-- 우측: 사진 + 지도 + 설명 -->
    <main style="flex:1; min-width:0;">

      <!-- 상단: 사진(좌) + 지도(우) -->
      <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:16px; margin-bottom:14px;">
        <div style="display:flex; gap:14px; align-items:stretch; flex-wrap:wrap;">

          <!-- 사진 -->
          <div style="flex:1; min-width:280px;">
            <div style="font-weight:800; margin-bottom:10px;">사진</div>
            <img src="${pageContext.request.contextPath}/img/spots/${spot.id}.jpg"
                 onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/img/hero.jpg';"
                 alt="${spot.name}"
                 style="width:100%; height:360px; object-fit:cover; border-radius:12px; border:1px solid #f1f5f9;">
          </div>

          <!-- 지도 -->
          <div style="flex:1; min-width:280px;">
            <div style="font-weight:800; margin-bottom:10px;">지도</div>
            <div id="map" style="width:100%; height:360px; border-radius:12px; border:1px solid #f1f5f9;"></div>
          </div>

        </div>

        <!-- 아래: 설명 -->
        <div style="margin-top:14px;">
          <div style="font-weight:800; margin-bottom:8px;">설명</div>
          <div style="color:#374151; line-height:1.7;">
            <j:choose>
              <j:when test="${not empty spot.info}">
                ${spot.info}
              </j:when>
              <j:otherwise>
                아직 등록된 설명이 없습니다.
              </j:otherwise>
            </j:choose>
          </div>

          <div style="margin-top:12px; color:#6b7280; font-size:13px; line-height:1.6;">
            <j:if test="${not empty spot.hours}">운영시간: ${spot.hours}<br/></j:if>
            <j:if test="${not empty spot.holiday}">휴무일: ${spot.holiday}<br/></j:if>
            <j:if test="${not empty spot.price}">요금: ${spot.price}<br/></j:if>
          </div>
        </div>
      </div>
    </main>
  </div>
</div>

<!-- ✅ 삼항연산 제거: 컨트롤러에서 mapLat/mapLng를 내려주는 방식 -->
<script>
  (function(){
    var lat = Number("${mapLat}");
    var lng = Number("${mapLng}");

    var map = L.map('map').setView([lat, lng], 13);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);

    L.marker([lat, lng]).addTo(map).bindPopup("${spot.name}").openPopup();
  })();
</script>

</body>
</html>
