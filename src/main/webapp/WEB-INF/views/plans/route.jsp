<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>경로 선택</title>
  <link rel="stylesheet" href="/css/header.css" />
  <script src="/js/theme.js"></script>
  <script defer src="/js/nav-wave.js"></script>
  <style>
    .wrap{display:flex; gap:16px;}
    #map{width:70%; height:720px; border-radius:10px; border:1px solid #ddd;}
    .side{width:30%;}
    .box{border:1px solid #ddd; border-radius:10px; padding:12px; margin-bottom:12px;}
    .list{max-height:240px; overflow:auto; border-top:1px solid #eee; margin-top:8px;}
    .row{display:flex; align-items:center; justify-content:space-between; gap:8px; padding:8px 0; border-bottom:1px dashed #eee;}
    .row:last-child{border-bottom:none;}
    .muted{color:#777; font-size:13px;}
    button{padding:10px 12px; border:1px solid #ccc; border-radius:8px; background:#fff; cursor:pointer;}
    button.primary{border-color:#222;}
    .selItem{display:flex; justify-content:space-between; gap:8px; padding:6px 0; border-bottom:1px dashed #eee;}
    .selItem:last-child{border-bottom:none;}
    .tiny{font-size:12px;}
    input[type="text"]{width:100%; padding:8px; border:1px solid #ccc; border-radius:8px;}
    select{padding:6px; border:1px solid #ccc; border-radius:8px;}
    .pill{display:inline-block; padding:2px 8px; border:1px solid #ddd; border-radius:999px; font-size:12px; color:#666;}
  </style>

  <!-- ✅ appkey는 하나만! (문자열로 붙이면 깨짐) -->
  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a3ff57f5cf42d50dce5ccbd693ebcf24&libraries=services&autoload=false"></script>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<h2>장소 선택 & 경로 계산</h2>
<p class="muted">도시/목적 조건에 맞는 장소를 선택하면 지도에 표시하고, “경로 계산”으로 시간/거리를 구해줘.</p>

<div class="wrap">
  <div id="map"></div>

  <div class="side">

    <!-- =======================
         1) 장소 목록
    ======================== -->
    <div class="box">
      <b>장소 목록</b>
      <div class="list" id="spotList">
        <c:forEach var="s" items="${spots}">
          <div class="row">
            <label style="flex:1;">
              <input type="checkbox" class="spotChk"
                     data-id="${s.id}"
                     data-name="${fn:escapeXml(s.name)}"
                     data-lat="${s.lat}"
                     data-lng="${s.lng}">
              ${s.name}
              <span class="muted tiny">(${s.catCode})</span>
            </label>
            <span class="muted tiny">${s.lat}, ${s.lng}</span>
          </div>
        </c:forEach>
      </div>

      <div style="margin-top:10px; display:flex; gap:8px; flex-wrap:wrap;">
        <button type="button" class="primary" onclick="calcRoute()">경로 계산</button>
        <button type="button" onclick="clearSelection()">선택 초기화</button>
        <button type="button" onclick="fitBounds()">전체보기</button>
      </div>

      <div style="margin-top:10px;">
        <div class="muted">총 거리: <span id="totalDist">-</span></div>
        <div class="muted">총 시간: <span id="totalTime">-</span></div>
      </div>
    </div>

    <!-- =======================
         2) 근처 숙소 목록(추가)
         - 장소 목록 아래 표시
         - 체크하면 selected에 들어가고 저장됨
    ======================== -->
    <div class="box">
      <b>근처 숙소 <span class="pill">DB</span></b>
      <div class="muted tiny" style="margin-top:4px;">
        * 현재 선택한 장소들의 중심 좌표 기준으로 주변 숙소를 불러와.
      </div>

      <div style="margin-top:10px; display:flex; gap:8px; flex-wrap:wrap;">
        <button type="button" onclick="loadNearbyStays()">주변 숙소 불러오기</button>
        <button type="button" onclick="clearStayLayer()">숙소 마커 제거</button>
      </div>

      <div id="stayList" class="list"></div>
    </div>

    <!-- =======================
         3) 선택 목록
    ======================== -->
    <div class="box">
      <b>선택 목록(순서)</b>
      <div id="selectedBox" class="list"></div>

      <button type="button" class="primary" onclick="savePlan()">선택 저장</button>

      <p class="muted tiny" style="margin-top:8px;">
        * p_day는 일차(1일차/2일차...)야. 지금은 간단히 선택목록에서 바꿀 수 있게 해뒀어.
      </p>
    </div>

  </div>
</div>

<!-- ✅ 저장은 백엔드 컨트롤러(@RequestParam)랑 맞춰서 "폼 submit" -->
<form id="saveForm" method="post" action="${pageContext.request.contextPath}/plans/route/save" style="display:none;">
  <input type="hidden" name="pIdx" value="${pIdx}">
  <input type="hidden" name="cityId" value="${cityId}">
  <c:forEach var="p" items="${purpose}">
    <input type="hidden" name="purpose" value="${fn:escapeXml(p)}">
  </c:forEach>

  <div id="hiddenInputs"></div>
</form>

<script>
  // ✅ contextPath
  const ctx = '${pageContext.request.contextPath}';

  // ✅ 선택 데이터: 장소+숙소 통합
  // [{id,name,lat,lng,day,memo}]
  let selected = [];

  // ✅ 지도 전역
  let map = null;
  let bounds = null;

  // ✅ "선택된 것" 마커/라인 레이어
  let selectedMarkers = [];
  let routeLines = [];

  // ✅ "근처 숙소 표시" 마커 레이어
  let stayMarkers = [];

  const pIdx = Number('${pIdx}');
  const selectedBox = document.getElementById('selectedBox');
  const hiddenInputs = document.getElementById('hiddenInputs');

  // ✅ Kakao SDK 로드 후 실행
  kakao.maps.load(function () {
    initMap();
    bindSpotCheckboxEvents();
    renderSelected();
    renderMapSelectedLayer();
  });

  function initMap() {
    const mapEl = document.getElementById('map');

    map = new kakao.maps.Map(mapEl, {
      center: new kakao.maps.LatLng(37.5665, 126.9780),
      level: 7
    });

    bounds = new kakao.maps.LatLngBounds();
  }

  // =========================
  // 장소 체크박스 이벤트
  // =========================
  function bindSpotCheckboxEvents() {
    document.querySelectorAll('.spotChk').forEach(chk => {

      // row 클릭 시 지도 이동
      const row = chk.closest('.row');
      if (row) {
        row.style.cursor = 'pointer';
        row.addEventListener('click', (e) => {
          if (e.target && (e.target.tagName === 'INPUT')) return;

          const lat = Number(chk.dataset.lat);
          const lng = Number(chk.dataset.lng);
          if (!lat || !lng || !map) return;

          const pos = new kakao.maps.LatLng(lat, lng);
          map.setLevel(5);
          map.panTo(pos);
        });
      }

      chk.addEventListener('change', () => {
        const id = Number(chk.dataset.id);

        if (chk.checked) {
          // 중복 방지
          if (selected.some(x => x.id === id)) return;

          selected.push({
            id: id,
            name: chk.dataset.name,
            lat: Number(chk.dataset.lat),
            lng: Number(chk.dataset.lng),
            day: 1,
            memo: ''
          });
        } else {
          selected = selected.filter(x => x.id !== id);
          // 숙소 체크박스도 같은 id면 같이 해제(같은 spotT면 충돌 가능성 있음)
          const stayChk = document.querySelector('.stayChk[data-id="' + id + '"]');
          if (stayChk) stayChk.checked = false;
        }

        renderSelected();
        renderMapSelectedLayer();
      });

    });
  }

  // =========================
  // 지도 레이어 관리
  // =========================
  function fitBounds() {
    if (!map || !bounds || selectedMarkers.length === 0) return;
    map.setBounds(bounds);
  }

  function clearSelectedLayer() {
    selectedMarkers.forEach(m => m.setMap(null));
    selectedMarkers = [];

    routeLines.forEach(l => l.setMap(null));
    routeLines = [];

    bounds = new kakao.maps.LatLngBounds();
  }

  function clearStayLayer() {
    stayMarkers.forEach(m => m.setMap(null));
    stayMarkers = [];
    const stayList = document.getElementById('stayList');
    if (stayList) stayList.innerHTML = '';
  }

  function clearSelection() {
    document.querySelectorAll('.spotChk').forEach(chk => chk.checked = false);
    document.querySelectorAll('.stayChk').forEach(chk => chk.checked = false);

    selected = [];
    renderSelected();

    clearSelectedLayer(); // 선택 마커/라인만 제거
    document.getElementById('totalDist').innerText = '-';
    document.getElementById('totalTime').innerText = '-';
  }

  // ✅ 선택된 것(장소+숙소) 마커 렌더
  function renderMapSelectedLayer() {
    if (!map) return;

    clearSelectedLayer();
    if (selected.length === 0) return;

    selected.forEach((s, idx) => {
      const pos = new kakao.maps.LatLng(s.lat, s.lng);
      bounds.extend(pos);

      const marker = new kakao.maps.Marker({ position: pos, map: map });
      selectedMarkers.push(marker);

      const iw = new kakao.maps.InfoWindow({
        content: '<div style="padding:6px 8px; font-size:13px;"><b>'
               + (idx + 1) + '. ' + escapeHtml(s.name)
               + '</b></div>'
      });

      kakao.maps.event.addListener(marker, 'click', () => iw.open(map, marker));
    });

    map.setBounds(bounds);
  }

  // =========================
  // 선택 목록 UI
  // =========================
  function dayOptions(selectedDay) {
    let html = '';
    for (let d = 1; d <= 7; d++) {
      html += '<option value="' + d + '"' + (d === selectedDay ? ' selected' : '') + '>' + d + '일차</option>';
    }
    return html;
  }

  function renderSelected() {
    selectedBox.innerHTML = '';

    if (selected.length === 0) {
      selectedBox.innerHTML = '<div class="muted" style="padding:8px 0;">선택된 장소가 없어.</div>';
    } else {
      selected.forEach((s, idx) => {
        const div = document.createElement('div');
        div.className = 'selItem';

        div.innerHTML =
          '<div style="flex:1;">' +
            '<b>' + (idx + 1) + '. ' + escapeHtml(s.name) + '</b>' +
            '<div class="muted tiny">' + s.lat + ', ' + s.lng + '</div>' +

            '<div style="margin-top:6px; display:flex; gap:8px; align-items:center;">' +
              '<span class="muted tiny">일차</span>' +
              '<select data-idx="' + idx + '" class="daySel">' +
                dayOptions(s.day) +
              '</select>' +
              '<button type="button" class="tiny" onclick="moveUp(' + idx + ')">▲</button>' +
              '<button type="button" class="tiny" onclick="moveDown(' + idx + ')">▼</button>' +
              '<button type="button" class="tiny" onclick="removeAt(' + idx + ')">삭제</button>' +
            '</div>' +

            '<div style="margin-top:6px;">' +
              '<input type="text" placeholder="메모(선택)" value="' + escapeXml(s.memo) + '" data-idx="' + idx + '" class="memoInp">' +
            '</div>' +
          '</div>';

        selectedBox.appendChild(div);
      });
    }

    document.querySelectorAll('.daySel').forEach(sel => {
      sel.addEventListener('change', () => {
        const idx = Number(sel.dataset.idx);
        selected[idx].day = Number(sel.value);
        buildHiddenInputs();
      });
    });

    document.querySelectorAll('.memoInp').forEach(inp => {
      inp.addEventListener('input', () => {
        const idx = Number(inp.dataset.idx);
        selected[idx].memo = inp.value;
        buildHiddenInputs();
      });
    });

    buildHiddenInputs();
  }

  function buildHiddenInputs() {
    hiddenInputs.innerHTML = '';
    selected.forEach((s) => {
      hiddenInputs.insertAdjacentHTML('beforeend',
        '<input type="hidden" name="sIdx" value="' + s.id + '">' +
        '<input type="hidden" name="pDay" value="' + s.day + '">' +
        '<input type="hidden" name="pMemo" value="' + escapeXml(s.memo) + '">'
      );
    });
  }

  function moveUp(idx) {
    if (idx <= 0) return;
    const tmp = selected[idx - 1];
    selected[idx - 1] = selected[idx];
    selected[idx] = tmp;
    renderSelected();
    renderMapSelectedLayer();
  }

  function moveDown(idx) {
    if (idx >= selected.length - 1) return;
    const tmp = selected[idx + 1];
    selected[idx + 1] = selected[idx];
    selected[idx] = tmp;
    renderSelected();
    renderMapSelectedLayer();
  }

  function removeAt(idx) {
    const id = selected[idx].id;
    selected.splice(idx, 1);

    // 장소 체크 해제
    const chk = document.querySelector('.spotChk[data-id="' + id + '"]');
    if (chk) chk.checked = false;

    // 숙소 체크 해제
    const stayChk = document.querySelector('.stayChk[data-id="' + id + '"]');
    if (stayChk) stayChk.checked = false;

    renderSelected();
    renderMapSelectedLayer();
  }

  // =========================
  // 경로 계산 (일차별 색상 라인 유지)
  // =========================
  async function calcRoute() {
    if (selected.length < 2) {
      alert('경로 계산은 최소 2개 장소가 필요해.');
      return;
    }

    const spotIds = selected.map(s => s.id).join(',');
    const url = ctx + '/plans/api/directions?spotIds=' + encodeURIComponent(spotIds);

    const res = await fetch(url);
    if (!res.ok) {
      alert('경로 계산 실패. 서버 로그 확인해줘.');
      return;
    }
    const data = await res.json();

    document.getElementById('totalDist').innerText = formatDistance(data.distanceM);
    document.getElementById('totalTime').innerText = formatDuration(data.durationSec);

    // 기존 라인 제거
    routeLines.forEach(l => l.setMap(null));
    routeLines = [];

    const grouped = groupByDay();
    Object.keys(grouped).forEach(day => {

      const arr = grouped[day];
      if (arr.length < 2) return;

      const path = arr.map(s => new kakao.maps.LatLng(s.lat, s.lng));

      const polyline = new kakao.maps.Polyline({
        path: path,
        strokeWeight: 5,
        strokeColor: getColorByDay(day),
        strokeOpacity: 0.85
      });

      polyline.setMap(map);
      routeLines.push(polyline);
    });
  }

  function getColorByDay(day) {
    const colors = {
      1: "#2979ff",
      2: "#ff1744",
      3: "#00c853",
      4: "#ff9100",
      5: "#9c27b0"
    };
    return colors[Number(day)] || "#222";
  }

  function groupByDay() {
    const map = {};
    selected.forEach(s => {
      if (!map[s.day]) map[s.day] = [];
      map[s.day].push(s);
    });
    return map;
  }

  // =========================
  // ✅ 숙소 기능(추가)
  // - 선택된 장소 중심 기준으로 /plans/api/stays 호출
  // - 목록 아래 체크박스 표시
  // - 체크하면 selected에 들어가 저장됨
  // - 지도에 숙소 마커도 표시(별도 레이어)
  // =========================
  function getCenter() {
    let lat = 0, lng = 0;
    selected.forEach(s => { lat += s.lat; lng += s.lng; });
    return { lat: lat / selected.length, lng: lng / selected.length };
  }

  async function loadNearbyStays() {
    if (selected.length === 0) {
      alert('먼저 장소를 1개 이상 선택해줘.');
      return;
    }

    const center = getCenter();
    const url = ctx + '/plans/api/stays?lat=' + center.lat + '&lng=' + center.lng;

    const res = await fetch(url);
    if (!res.ok) {
      alert('숙소 불러오기 실패(서버 로그 확인)');
      return;
    }

    const stays = await res.json();
    console.log('stays raw =', stays); // ✅ 개발자도구에서 여기로 실제 필드명 확인 가능

    // 🔥 기존 숙소 마커 제거
    stayMarkers.forEach(m => m.setMap(null));
    stayMarkers = [];

    const stayList = document.getElementById('stayList');
    stayList.innerHTML = '';

    if (!stays || stays.length === 0) {
      stayList.innerHTML = '<div class="muted" style="padding:8px 0;">근처 숙소가 없어.</div>';
      return;
    }

    stays.forEach(stay => {
      // ✅ 백엔드 DTO 필드명 케이스를 다 흡수(가장 중요)
      const id =
        Number(stay.id ?? stay.sIdx ?? stay.idx ?? stay.s_idx);

      const name =
        String(stay.name ?? stay.sName ?? stay.s_name ?? stay.spotName ?? stay.sname ?? '');

      const lat =
        Number(stay.lat ?? stay.sLat ?? stay.s_lat);

      const lng =
        Number(stay.lng ?? stay.sLng ?? stay.s_lng);

      const dist =
        Number(stay.distance ?? stay.dist ?? stay.distanceKm ?? stay.distance_km ?? 0);

      // ✅ 좌표가 없으면 마커/목록이 망가져서 여기서 스킵
      if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
        console.warn('좌표 누락 stay =', stay);
        return;
      }

      // ====== 목록(체크박스) ======
      const row = document.createElement('div');
      row.className = 'row';

      const checked = selected.some(x => x.id === id);

      row.innerHTML =
        '<label style="flex:1;">' +
          '<input type="checkbox" class="stayChk" ' +
            'data-id="' + id + '" ' +
            'data-name="' + escapeHtml(name) + '" ' +
            'data-lat="' + lat + '" ' +
            'data-lng="' + lng + '" ' +
            (checked ? 'checked' : '') +
          '>' +
          escapeHtml(name) +
          '<span class="muted tiny"> (약 ' + dist.toFixed(2) + ' km)</span>' +
        '</label>';

      stayList.appendChild(row);

      // ====== 지도 마커 ======
      const marker = new kakao.maps.Marker({
        position: new kakao.maps.LatLng(lat, lng),
        map: map
      });
      stayMarkers.push(marker);

      const iw = new kakao.maps.InfoWindow({
        content:
          '<div style="padding:8px;">' +
            '<b>' + escapeHtml(name) + '</b><br>' +
            '약 ' + dist.toFixed(2) + ' km' +
          '</div>'
      });

      kakao.maps.event.addListener(marker, 'click', () => iw.open(map, marker));
    });

    // ✅ 숙소 체크/해제 이벤트 바인딩
    document.querySelectorAll('.stayChk').forEach(chk => {
      chk.addEventListener('change', () => {
        const id = Number(chk.dataset.id);

        if (chk.checked) {
          if (selected.some(x => x.id === id)) return;

          selected.push({
            id: id,
            name: chk.dataset.name + ' (숙소)',
            lat: Number(chk.dataset.lat),
            lng: Number(chk.dataset.lng),
            day: 1,
            memo: '숙소'
          });
        } else {
          selected = selected.filter(x => x.id !== id);
        }

        renderSelected();
        renderMapMarkers(); // ✅ 기존 마커 기능 유지
      });
    });
  }

  // =========================
  // 저장 (폼 submit으로 컨트롤러와 맞춤)
  // =========================
  function savePlan() {
    if (selected.length < 1) {
      alert('저장할 장소가 없어.');
      return;
    }
    buildHiddenInputs();
    document.getElementById('saveForm').submit();
  }

  // =========================
  // 유틸
  // =========================
  function formatDuration(sec) {
    sec = Number(sec || 0);
    const h = Math.floor(sec / 3600);
    const m = Math.floor((sec % 3600) / 60);
    return (h > 0 ? (h + '시간 ') : '') + (m + '분');
  }

  function formatDistance(m) {
    m = Number(m || 0);
    return (m >= 1000) ? ((m / 1000).toFixed(1) + ' km') : (m + ' m');
  }

  function escapeHtml(str) {
    return String(str)
      .replaceAll('&','&amp;')
      .replaceAll('<','&lt;')
      .replaceAll('>','&gt;')
      .replaceAll('"','&quot;')
      .replaceAll("'",'&#039;');
  }

  function escapeXml(str) {
    return String(str ?? '')
      .replaceAll('&','&amp;')
      .replaceAll('"','&quot;')
      .replaceAll("'",'&#039;')
      .replaceAll('<','&lt;')
      .replaceAll('>','&gt;');
  }
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
</body>
</html>