<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>여행 계획 상세</title>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
  <link rel="stylesheet" href="/css/redesign.css" />

  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a3ff57f5cf42d50dce5ccbd693ebcf24&autoload=false"></script>

  <style>
    body.plan-view-page .mp-card,
    body.plan-view-page .mp-card-body { overflow: visible; }

    body.plan-view-page .kmap-wrap {
      position: relative;
      z-index: 10;
      overflow: visible;
    }

    body.plan-view-page #kakaoMap {
      display: block;
      width: 100%;
      height: 380px;
      min-height: 380px;
      border-radius: 12px;
      overflow: hidden;
      background: #eee;
    }
  </style>
</head>

<body class="page-solid plan-view-page">
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="mp-shell">
  <main class="mp-main">
    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">여행 계획 상세</div>
          <div class="mp-card-sub">작성일: <c:out value="${regDateStr}"/></div>
        </div>

        <div style="display:flex; gap:8px;">
          <button class="mp-btn" type="button"
                  onclick="location.href='${pageContext.request.contextPath}/members/mypage/plans'">
            목록
          </button>

          <button class="mp-btn" type="button"
                  onclick="location.href='${pageContext.request.contextPath}/plans/edit?pIdx=${plan.pIdx}'">
            수정
          </button>

          <button class="mp-btn" type="button"
                  onclick="if(confirm('삭제하시겠습니까?')) location.href='${pageContext.request.contextPath}/members/mypage/plans/delete?pIdx=${plan.pIdx}'">
            삭제
          </button>
        </div>
      </div>

      <div class="mp-card-body" style="display:flex; gap:16px; align-items:stretch;">

        <!-- 왼쪽: 정보 -->
        <div style="flex:1; min-width:280px;">
          <div class="mp-card-title" style="margin-bottom:10px;">
            <c:out value="${plan.pTitle}"/>
          </div>

          <div class="mp-card-sub">
            여행기간:
            <c:out value="${plan.pStart}"/> ~ <c:out value="${plan.pEnd}"/>
          </div>

          <c:if test="${not empty plan.tpTitle}">
            <div class="mp-card-sub" style="margin-top:10px;">
              부제목: <c:out value="${plan.tpTitle}"/>
            </div>
          </c:if>

          <c:if test="${not empty spotNamesByDay}">
            <div class="mp-card-sub" style="margin-top:14px;">
              <div style="font-weight:700; margin-bottom:8px;">선택한 목적지</div>

              <c:forEach var="entry" items="${spotNamesByDay}">
                <div style="margin-bottom:10px;">
                  <div style="font-weight:700; margin-bottom:4px;">
                    <c:out value="${entry.key}"/>일차
                  </div>

                  <ol style="margin:0; padding-left:18px; line-height:1.7;">
                    <c:forEach var="nm" items="${entry.value}">
                      <li><c:out value="${nm}"/></li>
                    </c:forEach>
                  </ol>
                </div>
              </c:forEach>
            </div>
          </c:if>
		  
		  <c:if test="${not empty stayNamesByDay}">
		    <div class="mp-card-sub" style="margin-top:14px;">
		      <div style="font-weight:700; margin-bottom:8px;">선택한 숙소</div>

		      <c:forEach var="entry" items="${stayNamesByDay}">
		        <div style="margin-bottom:10px;">
		          <div style="font-weight:700; margin-bottom:4px;">
		            <c:out value="${entry.key}"/>일차
		          </div>

		          <ol style="margin:0; padding-left:18px; line-height:1.7;">
		            <c:forEach var="nm" items="${entry.value}">
		              <li><c:out value="${nm}"/></li>
		            </c:forEach>
		          </ol>
		        </div>
		      </c:forEach>
		    </div>
		  </c:if>

          <div class="mp-card-sub" style="margin-top:14px;">
            오른쪽 지도에 선택한 장소 동선이 표시돼요.
          </div>
        </div>

		<!-- 오른쪽: 지도 -->
		<div class="kmap-wrap" style="width:440px; min-width:360px;">
		  <div id="kakaoMap"></div>
		  <div id="mapHint" class="mp-card-sub" style="margin-top:10px;"></div>

		  <!-- 🔥 추가: 일차별 색상 범례 -->
		  <div class="mp-card-sub" style="
		        margin-top:12px;
		        padding:10px 12px;
		        border:1px solid #eee;
		        border-radius:10px;
		        background:#fafafa;">
		        
		    <div style="font-weight:700; margin-bottom:6px;">
		      동선 색상 안내
		    </div>

		    <div style="display:flex; flex-wrap:wrap; gap:10px; font-size:13px;">
		      <div style="display:flex; align-items:center; gap:6px;">
		        <span style="width:14px; height:4px; background:#e53935; display:inline-block; border-radius:2px;"></span>
		        1일차
		      </div>

		      <div style="display:flex; align-items:center; gap:6px;">
		        <span style="width:14px; height:4px; background:#1e88e5; display:inline-block; border-radius:2px;"></span>
		        2일차
		      </div>

		      <div style="display:flex; align-items:center; gap:6px;">
		        <span style="width:14px; height:4px; background:#43a047; display:inline-block; border-radius:2px;"></span>
		        3일차
		      </div>

		      <div style="display:flex; align-items:center; gap:6px;">
		        <span style="width:14px; height:4px; background:#fb8c00; display:inline-block; border-radius:2px;"></span>
		        4일차
		      </div>

		      <div style="display:flex; align-items:center; gap:6px;">
		        <span style="width:14px; height:4px; background:#8e24aa; display:inline-block; border-radius:2px;"></span>
		        5일차
		      </div>
		    </div>
		  </div>
		</div>

      <!-- ✅ JSON만 넣어야 함. 절대 HTML 넣지 말기 -->
      <script id="pointsJson" type="application/json">
      ${empty pointsJson ? "[]" : pointsJson}
      </script>
	  
	  <script id="staysJson" type="application/json">
	  ${empty staysJson ? "[]" : staysJson}
	  </script>

      <script>
        const points = (() => {
          try {
            const el = document.getElementById('pointsJson');
            if (!el) return [];
            return JSON.parse(el.textContent || "[]");
          } catch (e) {
            console.error("pointsJson parse error", e);
            return [];
          }
        })();
		
		const stays = (() => {
		  try {
		    const el = document.getElementById('staysJson');
		    if (!el) return [];
		    return JSON.parse(el.textContent || "[]");
		  } catch (e) {
		    console.error("staysJson parse error", e);
		    return [];
		  }
		})();

		function initKakaoMap() {
		  var mapEl = document.getElementById('kakaoMap');
		  var hintEl = document.getElementById('mapHint');

		  if (!mapEl) {
		    console.error("Map container not found (#kakaoMap)");
		    return;
		  }

		  // 컨테이너 크기 0이면 잠깐 재시도
		  var w = mapEl.offsetWidth, h = mapEl.offsetHeight;
		  if (w === 0 || h === 0) {
		    setTimeout(initKakaoMap, 100);
		    return;
		  }

		  var defaultCenter = new kakao.maps.LatLng(37.5665, 126.9780);

		  // ✅ 지도 생성
		  var map = new kakao.maps.Map(mapEl, { center: defaultCenter, level: 7 });

		  // ✅ bounds를 제일 먼저 생성 (에러 방지)
		  var bounds = new kakao.maps.LatLngBounds();

		  // =====================
		  // 1) 목적지(points) 마커 + dayPaths 누적
		  // =====================
		  var dayPaths = new Map();
		  var markerIdx = 1;

		  if (Array.isArray(points) && points.length > 0) {
		    // 중심 이동(첫 점 기준)
		    var cLat = Number(points[0].lat);
		    var cLng = Number(points[0].lng);
		    if (isFinite(cLat) && isFinite(cLng)) {
		      map.setCenter(new kakao.maps.LatLng(cLat, cLng));
		    }

		    for (var i = 0; i < points.length; i++) {
		      var p = points[i];
		      var lat = Number(p.lat);
		      var lng = Number(p.lng);
		      var day = Number(p.day);

		      if (!isFinite(lat) || !isFinite(lng)) continue;

		      var latlng = new kakao.maps.LatLng(lat, lng);
		      bounds.extend(latlng);

		      var marker = new kakao.maps.Marker({ position: latlng, map: map });

		      var safeName = (p.name || '장소').toString().replace(/</g, "&lt;").replace(/>/g, "&gt;");
		      var content =
		        '<div style="padding:6px 8px;font-size:12px;white-space:nowrap;">' +
		        (markerIdx++) + '. ' + safeName +
		        '</div>';

		      (function(mk, html){
		        var iw = new kakao.maps.InfoWindow({ content: html });
		        kakao.maps.event.addListener(mk, 'click', function() {
		          iw.open(map, mk);
		        });
		      })(marker, content);

		      if (!isFinite(day)) day = 0;
		      if (!dayPaths.has(day)) dayPaths.set(day, []);
		      dayPaths.get(day).push(latlng);
		    }
		  }

		  // =====================
		  // 2) 숙소(stays) 마커만 표시 (선 X)
		  // =====================
		  if (Array.isArray(stays) && stays.length > 0) {
		    for (var j = 0; j < stays.length; j++) {
		      var s = stays[j];
		      var slat = Number(s.lat);
		      var slng = Number(s.lng);
		      if (!isFinite(slat) || !isFinite(slng)) continue;

		      var pos = new kakao.maps.LatLng(slat, slng);
		      bounds.extend(pos);

		      var mkStay = new kakao.maps.Marker({ position: pos, map: map });

		      var sName = (s.name || '숙소').toString().replace(/</g, "&lt;").replace(/>/g, "&gt;");
		      var htmlStay =
		        '<div style="padding:6px 8px;font-size:12px;white-space:nowrap;">' +
		        '🏨 ' + sName +
		        '</div>';

		      (function(mk2, html2){
		        var iw2 = new kakao.maps.InfoWindow({ content: html2 });
		        kakao.maps.event.addListener(mk2, 'click', function() {
		          iw2.open(map, mk2);
		        });
		      })(mkStay, htmlStay);
		    }
		  }

		  // =====================
		  // 3) day별 polyline (목적지만)
		  // =====================
		  var days = Array.from(dayPaths.keys()).sort(function(a,b){ return a-b; });

		  var dayColors = [
		    '#e53935', '#1e88e5', '#43a047', '#fb8c00', '#8e24aa',
		    '#00897b', '#6d4c41'
		  ];

		  for (var d = 0; d < days.length; d++) {
		    var key = days[d];
		    var path = dayPaths.get(key);
		    if (!path || path.length < 2) continue;

		    var colorIndex = (key - 1) % dayColors.length;
		    if (!isFinite(colorIndex) || colorIndex < 0) colorIndex = 0;

		    var polyline = new kakao.maps.Polyline({
		      path: path,
		      strokeWeight: 5,
		      strokeColor: dayColors[colorIndex],
		      strokeOpacity: 0.9,
		      strokeStyle: 'solid'
		    });

		    polyline.setMap(map);
		  }

		  // =====================
		  // 4) bounds 적용 + 힌트
		  // =====================
		  if (!bounds.isEmpty()) {
		    map.setBounds(bounds);
		  }

		  if (hintEl) {
		    if ((points?.length || 0) === 0 && (stays?.length || 0) > 0) {
		      hintEl.textContent = "숙소 위치만 표시했어요.";
		    } else if ((points?.length || 0) > 0) {
		      hintEl.textContent = "일차별로 동선이 따로 표시돼요.";
		    } else {
		      hintEl.textContent = "등록된 장소가 없어서 기본 위치로 표시했어요.";
		    }
		  }

		  setTimeout(function(){ map.relayout(); }, 0);
		}

        window.addEventListener('load', function() {
          if (typeof kakao === 'undefined' || !kakao.maps) {
            const hintEl = document.getElementById('mapHint');
            if (hintEl) hintEl.textContent = "카카오맵 SDK 로드 실패: 키/도메인 등록을 확인하세요.";
            return;
          }
          kakao.maps.load(initKakaoMap);
        });
      </script>

    </section>
  </main>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
<%@ include file="/WEB-INF/views/common/authModal.jspf" %>
</body>
</html>