<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>여행 계획 상세</title>

  <link rel="stylesheet" href="/css/header.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
  <link rel="stylesheet" href="/css/redesign.css" />

  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a3ff57f5cf42d50dce5ccbd693ebcf24&autoload=false"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/nav-wave.js"></script>

  <style>
    body.plan-view-page .mp-card,
    body.plan-view-page .mp-card-body { overflow: visible; }
    body.plan-view-page .kmap-wrap {
      position: relative; z-index: 10; overflow: visible; flex: 1;
    }
    body.plan-view-page #kakaoMap {
      display: block; width: 100%; height: 420px; border-radius: 12px; overflow: hidden; background: #eee;
    }
  </style>
</head>

<body class="page-solid plan-view-page">
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
      <a class="active" href="${pageContext.request.contextPath}/members/mypage/plans">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M7 3v3M17 3v3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M4 8h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M5 6h14a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg></span>내 여행 계획
      </a>
      <a href="${pageContext.request.contextPath}/members/mypage/reviews">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M7 3h8l4 4v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M15 3v5h5" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M8 13h8M8 17h8" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg></span>내 여행 후기
      </a>
      <a href="${pageContext.request.contextPath}/members/mypage/wishlist">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" stroke-linecap="round"/></svg></span>내 찜 목록
      </a>
    </nav>
  </aside>

  <main class="mp-main">
    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">여행 계획 상세</div>
          <div class="mp-card-sub">작성일: <c:out value="${regDateStr}"/></div>
        </div>

        <div style="display:flex; gap:8px;">
          <button class="mp-btn" type="button" onclick="location.href='${pageContext.request.contextPath}/members/mypage/plans'">목록</button>
          <!-- ✅ 수정: 마이페이지 상세보기의 '수정'은 기본정보 수정 화면(/plans/edit)으로 이동 -->
		  <button class="mp-btn" type="button"
		                    onclick="location.href='${pageContext.request.contextPath}/plans/edit?pIdx=${plan.pIdx}'">
		              수정
		            </button>

          <button class="mp-btn" type="button" onclick="if(confirm('삭제하시겠습니까?')) location.href='${pageContext.request.contextPath}/members/mypage/plans/delete?pIdx=${plan.pIdx}'">삭제</button>
        </div>
      </div>

      <div class="mp-card-body" style="display:flex; gap:30px; align-items:stretch; flex-wrap: wrap;">

        <div style="flex: 0 0 280px;">
          <div class="mp-card-title" style="margin-bottom:10px; font-size: 18px;">
            <c:out value="${plan.pTitle}"/>
          </div>
          <div class="mp-card-sub">
            여행기간: <c:out value="${plan.pStart}"/> ~ <c:out value="${plan.pEnd}"/>
          </div>

          <c:if test="${not empty plan.tpTitle}">
            <div class="mp-card-sub" style="margin-top:10px;">
              부제목: <c:out value="${plan.tpTitle}"/>
            </div>
          </c:if>

          <c:if test="${not empty spotNamesByDay}">
            <div class="mp-card-sub" style="margin-top:20px;">
              <div style="font-weight:800; color:#222; margin-bottom:10px;">📌 선택한 목적지</div>
              <c:forEach var="entry" items="${spotNamesByDay}">
                <div style="margin-bottom:12px;">
                  <div style="font-weight:700; color:#444; margin-bottom:4px;">
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
		    <div class="mp-card-sub" style="margin-top:20px;">
		      <div style="font-weight:800; color:#222; margin-bottom:10px;">🏨 선택한 숙소</div>
		      <c:forEach var="entry" items="${stayNamesByDay}">
		        <div style="margin-bottom:12px;">
		          <div style="font-weight:700; color:#444; margin-bottom:4px;">
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
        </div>

		<div class="kmap-wrap" style="min-width:300px;">
		  <div id="kakaoMap"></div>
		  <div id="mapHint" class="mp-card-sub" style="margin-top:10px;"></div>

		  <div class="mp-card-sub" style="margin-top:16px; padding:12px 16px; border:1px solid #eee; border-radius:12px; background:#fafafa;">
		    <div style="font-weight:800; margin-bottom:8px; color: #333;">동선 색상 안내</div>
		    <div style="display:flex; flex-wrap:wrap; gap:14px; font-size:13px; font-weight: 600;">
		      <div style="display:flex; align-items:center; gap:6px;"><span style="width:16px; height:6px; background:#e53935; display:inline-block; border-radius:3px;"></span>1일차</div>
		      <div style="display:flex; align-items:center; gap:6px;"><span style="width:16px; height:6px; background:#1e88e5; display:inline-block; border-radius:3px;"></span>2일차</div>
		      <div style="display:flex; align-items:center; gap:6px;"><span style="width:16px; height:6px; background:#43a047; display:inline-block; border-radius:3px;"></span>3일차</div>
		      <div style="display:flex; align-items:center; gap:6px;"><span style="width:16px; height:6px; background:#fb8c00; display:inline-block; border-radius:3px;"></span>4일차</div>
		      <div style="display:flex; align-items:center; gap:6px;"><span style="width:16px; height:6px; background:#8e24aa; display:inline-block; border-radius:3px;"></span>5일차</div>
		    </div>
		  </div>
		</div>

      <script id="pointsJson" type="application/json">${empty pointsJson ? "[]" : pointsJson}</script>
	  <script id="staysJson" type="application/json">${empty staysJson ? "[]" : staysJson}</script>

      <script>
        const points = (() => {
          try { const el = document.getElementById('pointsJson'); if (!el) return []; return JSON.parse(el.textContent || "[]"); } catch (e) { return []; }
        })();
		const stays = (() => {
		  try { const el = document.getElementById('staysJson'); if (!el) return []; return JSON.parse(el.textContent || "[]"); } catch (e) { return []; }
		})();

		function initKakaoMap() {
		  var mapEl = document.getElementById('kakaoMap');
		  var hintEl = document.getElementById('mapHint');
		  if (!mapEl) return;

		  var w = mapEl.offsetWidth, h = mapEl.offsetHeight;
		  if (w === 0 || h === 0) { setTimeout(initKakaoMap, 100); return; }

		  var defaultCenter = new kakao.maps.LatLng(37.5665, 126.9780);
		  var map = new kakao.maps.Map(mapEl, { center: defaultCenter, level: 7 });
		  var bounds = new kakao.maps.LatLngBounds();
		  
		  var dayPaths = new Map();
		  var markerIdx = 1;

		  if (Array.isArray(points) && points.length > 0) {
		    var cLat = Number(points[0].lat), cLng = Number(points[0].lng);
		    if (isFinite(cLat) && isFinite(cLng)) map.setCenter(new kakao.maps.LatLng(cLat, cLng));

		    for (var i = 0; i < points.length; i++) {
		      var p = points[i];
		      var lat = Number(p.lat), lng = Number(p.lng), day = Number(p.day);
		      if (!isFinite(lat) || !isFinite(lng)) continue;

		      var latlng = new kakao.maps.LatLng(lat, lng);
		      bounds.extend(latlng);
		      var marker = new kakao.maps.Marker({ position: latlng, map: map });
		      var safeName = (p.name || '장소').toString().replace(/</g, "&lt;").replace(/>/g, "&gt;");
		      var content = '<div style="padding:6px 8px;font-size:12px;white-space:nowrap;">' + (markerIdx++) + '. ' + safeName + '</div>';

		      (function(mk, html){
		        var iw = new kakao.maps.InfoWindow({ content: html });
		        kakao.maps.event.addListener(mk, 'click', function() { iw.open(map, mk); });
		      })(marker, content);

		      if (!isFinite(day)) day = 0;
		      if (!dayPaths.has(day)) dayPaths.set(day, []);
		      dayPaths.get(day).push(latlng);
		    }
		  }

		  if (Array.isArray(stays) && stays.length > 0) {
		    for (var j = 0; j < stays.length; j++) {
		      var s = stays[j];
		      var slat = Number(s.lat), slng = Number(s.lng);
		      if (!isFinite(slat) || !isFinite(slng)) continue;

		      var pos = new kakao.maps.LatLng(slat, slng);
		      bounds.extend(pos);
		      var mkStay = new kakao.maps.Marker({ position: pos, map: map });
		      var sName = (s.name || '숙소').toString().replace(/</g, "&lt;").replace(/>/g, "&gt;");
		      var htmlStay = '<div style="padding:6px 8px;font-size:12px;white-space:nowrap;">🏨 ' + sName + '</div>';

		      (function(mk2, html2){
		        var iw2 = new kakao.maps.InfoWindow({ content: html2 });
		        kakao.maps.event.addListener(mk2, 'click', function() { iw2.open(map, mk2); });
		      })(mkStay, htmlStay);
		    }
		  }

		  var days = Array.from(dayPaths.keys()).sort(function(a,b){ return a-b; });
		  var dayColors = ['#e53935', '#1e88e5', '#43a047', '#fb8c00', '#8e24aa', '#00897b', '#6d4c41'];

		  for (var d = 0; d < days.length; d++) {
		    var key = days[d];
		    var path = dayPaths.get(key);
		    if (!path || path.length < 2) continue;

		    var colorIndex = (key - 1) % dayColors.length;
		    if (!isFinite(colorIndex) || colorIndex < 0) colorIndex = 0;

		    var polyline = new kakao.maps.Polyline({
		      path: path, strokeWeight: 5, strokeColor: dayColors[colorIndex], strokeOpacity: 0.9, strokeStyle: 'solid'
		    });
		    polyline.setMap(map);
		  }

		  if (!bounds.isEmpty()) { map.setBounds(bounds); }

		  if (hintEl) {
		    if ((points?.length || 0) === 0 && (stays?.length || 0) > 0) {
		      hintEl.textContent = "숙소 위치만 표시했어요.";
		    } else if ((points?.length || 0) > 0) {
		      hintEl.textContent = "일차별로 동선이 표시돼요.";
		    } else {
		      hintEl.textContent = "등록된 장소가 없습니다.";
		    }
		  }

		  setTimeout(function(){ map.relayout(); }, 0);
		}

        window.addEventListener('load', function() {
          if (typeof kakao === 'undefined' || !kakao.maps) {
            const hintEl = document.getElementById('mapHint');
            if (hintEl) hintEl.textContent = "카카오맵 SDK 로드 실패.";
            return;
          }
          kakao.maps.load(initKakaoMap);
        });
      </script>

      </div>
    </section>
  </main>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
<%@ include file="/WEB-INF/views/common/authModal.jspf" %>
</body>
</html>