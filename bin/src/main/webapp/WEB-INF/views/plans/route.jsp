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
    /* 지도 전체 영역 (스크롤 해야 푸터가 보이도록 높이 지정) */
    .map-container {
      position: relative;
      width: 100%;
      height: 100vh; /* 화면의 88%를 차지하여 푸터를 스크롤 아래로 밀어냄 */
      min-height: 750px;
      overflow: hidden;
      background: #f8f9fa;
      border-top: 1px solid #eee; /* 헤더와의 경계선 */
    }

    /* 전체 화면 지도 */
    #map {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      z-index: 1;
    }

    /* ---------------------------------
       왼쪽 타임라인 패널 & 토글
    --------------------------------- */
    .left-timeline {
      position: absolute;
      top: 0;
      left: 0;
      width: 380px;
      height: 100%;
      background: #fff;
      z-index: 10;
      box-shadow: 2px 0 16px rgba(0,0,0,0.1);
      display: flex;
      flex-direction: column;
      transition: transform 0.3s ease-in-out;
    }
    .left-timeline.closed {
      transform: translateX(-100%);
    }
    
    /* 왼쪽 패널 토글 버튼 */
    .toggle-btn.left-btn {
      position: absolute;
      top: 50%;
      right: -28px;
      transform: translateY(-50%);
      width: 28px;
      height: 70px;
      background: #fff;
      border: 1px solid #ddd;
      border-left: none;
      border-radius: 0 8px 8px 0;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 3px 0 6px rgba(0,0,0,0.05);
      z-index: 11;
      font-size: 12px;
      color: #555;
    }

    .timeline-header {
      padding: 24px 20px 16px;
      border-bottom: 1px solid #eee;
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: #fff;
    }
    .timeline-header h3 { margin: 0; font-size: 18px; color: #222; }

    #selectedBox {
      flex: 1;
      overflow-y: auto;
      padding: 24px 20px;
      background: #fcfcfc;
    }

    /* 타임라인 아이템 디자인 (트리플 스타일) */
    .selItem { position: relative; padding-left: 28px; margin-bottom: 24px; }
    .selItem::before { content: ''; position: absolute; left: 0; top: 4px; width: 12px; height: 12px; background: #2979ff; border-radius: 50%; box-shadow: 0 0 0 3px #e3edff; z-index: 2; }
    .selItem::after { content: ''; position: absolute; left: 5px; top: 20px; bottom: -30px; width: 2px; background: #e3edff; z-index: 1; }
    .selItem:last-child::after { display: none; }
    .sel-card { background: #fff; border: 1px solid #eaeaea; border-radius: 12px; padding: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.02); }
    .sel-card b { font-size: 15px; color: #111; display: block; margin-bottom: 4px; }

    /* ---------------------------------
       오른쪽 위젯 패널 & 토글
    --------------------------------- */
    .right-tools {
      position: absolute;
      top: 40px; /* 헤더에서 충분히 떨어지도록 넉넉하게 내림 */
      right: 30px;
      width: 360px;
      max-height: calc(100% - 80px); /* 스크롤을 위한 하단 여백 확보 */
      z-index: 10;
      transition: transform 0.3s ease-in-out;
    }
    .right-tools.closed {
      transform: translateX(calc(100% + 30px));
    }
    
    /* 오른쪽 패널 컨텐츠 래퍼 (스크롤 영역) */
    .right-tools-content {
      display: flex;
      flex-direction: column;
      gap: 16px;
      max-height: calc(88vh - 100px);
      overflow-y: auto;
      pointer-events: none;
    }
    
    /* 오른쪽 패널 토글 버튼 */
    .toggle-btn.right-btn {
      position: absolute;
      top: 50%;
      left: -28px;
      transform: translateY(-50%);
      width: 28px;
      height: 70px;
      background: #fff;
      border: 1px solid #ddd;
      border-right: none;
      border-radius: 8px 0 0 8px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: -3px 0 6px rgba(0,0,0,0.05);
      z-index: 11;
      font-size: 12px;
      color: #555;
      pointer-events: auto;
    }

    .box { pointer-events: auto; background: #fff; border-radius: 16px; padding: 20px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); border: 1px solid #f0f0f0; }
    .box b { font-size: 16px; color: #222; display: block; margin-bottom: 12px; }

    .list { max-height: 220px; overflow-y: auto; padding-right: 8px; }
    .row { display: flex; align-items: center; justify-content: space-between; gap: 8px; padding: 10px 0; border-bottom: 1px dashed #eee; cursor: pointer; transition: background 0.2s; }
    .row:hover { background: #f9f9f9; }
    .row:last-child { border-bottom: none; }

    /* 공통 요소 및 버튼 최적화 */
    .muted { color: #777; font-size: 13px; }
    .tiny { font-size: 12px; }
    
    button { padding: 10px 14px; border: 1px solid #ccc; border-radius: 8px; background: #fff; cursor: pointer; font-weight: 600; transition: 0.2s; box-sizing: border-box; }
    button:hover { background: #f5f5f5; }
    button.primary { border-color: #2979ff; background: #2979ff; color: #fff; border: none; }
    button.primary:hover { background: #1c54b2; }
    button.btn-icon { padding: 4px 8px; font-size: 12px; border: 1px solid #eee; border-radius: 6px; background: #fff; color: #555; }
    
    input[type="text"] { width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 8px; outline: none; box-sizing: border-box; }
    input[type="text"]:focus { border-color: #2979ff; }
    select { padding: 6px 10px; border: 1px solid #ddd; border-radius: 6px; outline: none; }

    ::-webkit-scrollbar { width: 6px; }
    ::-webkit-scrollbar-thumb { background: #ccc; border-radius: 10px; }
    ::-webkit-scrollbar-track { background: transparent; }
  </style>

  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a3ff57f5cf42d50dce5ccbd693ebcf24&libraries=services&autoload=false"></script>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="map-container">
  
  <div id="map"></div>
  
  <div class="left-timeline closed" id="leftTimeline">
    <button class="toggle-btn left-btn" id="leftToggleBtn" onclick="toggleLeftPanel()">▶</button>
    
    <div class="timeline-header">
      <div>
        <h3>나의 일정</h3>
        <span class="muted tiny">장소를 선택하면 코스가 만들어져.</span>
      </div>
      <button type="button" class="primary" onclick="savePlan()">선택 저장</button>
    </div>
    
    <div id="selectedBox"></div>
  </div>

  <div class="right-tools" id="rightTools">
    <button class="toggle-btn right-btn" id="rightToggleBtn" onclick="toggleRightPanel()">▶</button>
    
    <div class="right-tools-content">
      <div class="box">
        <b>장소 목록</b>
        <div class="list" id="spotList">
          <c:forEach var="s" items="${spots}">
            <div class="row">
              <label style="flex:1; cursor: pointer; display: flex; align-items: center;">
                <input type="checkbox" class="spotChk"
                       data-id="${s.id}"
                       data-name="${fn:escapeXml(s.name)}"
                       data-lat="${s.lat}"
                       data-lng="${s.lng}"
                       style="margin-right: 8px;">
                ${s.name}
                <span class="muted tiny" style="margin-left:4px;">(${s.catCode})</span>
              </label>
              <span class="muted tiny">${s.lat}, ${s.lng}</span>
            </div>
          </c:forEach>
        </div>

        <div style="margin-top:16px;">
          <button type="button" class="primary" onclick="calcRoute()" style="width: 100%; margin-bottom: 8px; padding: 12px;">경로 계산</button>
          <div style="display: flex; gap: 8px;">
            <button type="button" onclick="clearSelection()" style="flex: 1;">초기화</button>
            <button type="button" onclick="fitBounds()" style="flex: 1;">전체보기</button>
          </div>
        </div>

        <div style="margin-top:16px; padding-top:16px; border-top: 1px dashed #eee; background: #fafafa; border-radius: 8px; padding: 12px;">
          <div class="muted">총 거리: <span id="totalDist" style="font-weight:700; color:#2979ff;">-</span></div>
          <div class="muted" style="margin-top:4px;">총 시간: <span id="totalTime" style="font-weight:700; color:#2979ff;">-</span></div>
        </div>
      </div>

      <div class="box">
        <b style="margin-bottom:8px;">근처 숙소</b>
        <div class="muted tiny" style="margin-bottom:12px; line-height:1.4;">
          * 현재 유저 선택한 장소들의 중심 좌표 기준으로 주변 숙소를 불러와 줍니다.
        </div>

        <div style="display:flex; gap:8px; margin-bottom: 12px;">
          <button type="button" onclick="loadNearbyStays()" style="flex:1; border-color:#2979ff; color:#2979ff;">주변 숙소 불러오기</button>
          <button type="button" onclick="clearStayLayer()" style="padding: 10px;">마커 제거</button>
        </div>

        <div id="stayList" class="list"></div>
      </div>
    </div>
  </div> 
</div> <form id="saveForm" method="post" action="${pageContext.request.contextPath}/plans/route/save" style="display:none;">
  <input type="hidden" name="pIdx" value="${pIdx}">
  <input type="hidden" name="cityId" value="${cityId}">
  <c:forEach var="p" items="${purpose}">
    <input type="hidden" name="purpose" value="${fn:escapeXml(p)}">
  </c:forEach>
  <div id="hiddenInputs"></div>
</form>

<script>
  // ✅ 패널 토글 애니메이션 로직
  function toggleLeftPanel() {
    const panel = document.getElementById('leftTimeline');
    const btn = document.getElementById('leftToggleBtn');
    panel.classList.toggle('closed');
    btn.innerText = panel.classList.contains('closed') ? '▶' : '◀';
  }

  function toggleRightPanel() {
    const panel = document.getElementById('rightTools');
    const btn = document.getElementById('rightToggleBtn');
    panel.classList.toggle('closed');
    btn.innerText = panel.classList.contains('closed') ? '◀' : '▶';
  }

  // ✅ contextPath
  const ctx = '${pageContext.request.contextPath}';

  let selected = [];
  let map = null;
  let bounds = null;
  let selectedMarkers = [];
  let routeLines = [];
  let stayMarkers = [];

  const pIdx = Number('${pIdx}');
  const selectedBox = document.getElementById('selectedBox');
  const hiddenInputs = document.getElementById('hiddenInputs');

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

  function bindSpotCheckboxEvents() {
    document.querySelectorAll('.spotChk').forEach(chk => {
      const row = chk.closest('.row');
      if (row) {
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
          if (selected.some(x => x.id === id)) return;
          selected.push({
            id: id,
            name: chk.dataset.name,
            lat: Number(chk.dataset.lat),
            lng: Number(chk.dataset.lng),
            day: 1,
            memo: ''
          });
          
          // 장소 선택 시 왼쪽 패널 자동 열기
          const leftPanel = document.getElementById('leftTimeline');
          if (leftPanel.classList.contains('closed')) {
            toggleLeftPanel();
          }
        } else {
          selected = selected.filter(x => x.id !== id);
          const stayChk = document.querySelector('.stayChk[data-id="' + id + '"]');
          if (stayChk) stayChk.checked = false;
        }
        renderSelected();
        renderMapSelectedLayer();
      });
    });
  }

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
    clearSelectedLayer();
    document.getElementById('totalDist').innerText = '-';
    document.getElementById('totalTime').innerText = '-';
    
    // 모두 해제 시 왼쪽 패널 자동 닫기
    const leftPanel = document.getElementById('leftTimeline');
    if (!leftPanel.classList.contains('closed')) {
      toggleLeftPanel();
    }
  }

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
        content: '<div style="padding:6px 8px; font-size:13px;"><b>' + (idx + 1) + '. ' + escapeHtml(s.name) + '</b></div>'
      });
      kakao.maps.event.addListener(marker, 'click', () => iw.open(map, marker));
    });
    map.setBounds(bounds);
  }

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
      selectedBox.innerHTML = '<div class="muted" style="text-align:center; padding-top:40px;">오른쪽 장소 목록에서<br>원하는 곳을 추가해주세요.</div>';
    } else {
      selected.forEach((s, idx) => {
        const div = document.createElement('div');
        div.className = 'selItem';

        div.innerHTML =
          '<div class="sel-card">' +
            '<div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 12px;">' +
              '<b style="flex:1; margin-right:8px; line-height:1.4;">' + escapeHtml(s.name) + '</b>' +
              '<div style="display:flex; gap:4px;">' +
                '<button type="button" class="btn-icon" onclick="moveUp(' + idx + ')">▲</button>' +
                '<button type="button" class="btn-icon" onclick="moveDown(' + idx + ')">▼</button>' +
                '<button type="button" class="btn-icon" style="color:#ff5252;" onclick="removeAt(' + idx + ')">✕</button>' +
              '</div>' +
            '</div>' +
            
            '<div style="display:flex; gap:8px; align-items:center;">' +
              '<select data-idx="' + idx + '" class="daySel" style="width: 80px;">' + dayOptions(s.day) + '</select>' +
              '<input type="text" placeholder="메모(선택)" value="' + escapeXml(s.memo) + '" data-idx="' + idx + '" class="memoInp" style="flex:1;">' +
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
    const chk = document.querySelector('.spotChk[data-id="' + id + '"]');
    if (chk) chk.checked = false;
    const stayChk = document.querySelector('.stayChk[data-id="' + id + '"]');
    if (stayChk) stayChk.checked = false;
    renderSelected();
    renderMapSelectedLayer();
    
    // 삭제 후 리스트가 비어있으면 왼쪽 패널 닫기
    if(selected.length === 0) {
        const leftPanel = document.getElementById('leftTimeline');
        if (!leftPanel.classList.contains('closed')) {
          toggleLeftPanel();
        }
    }
  }

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
    const colors = { 1: "#2979ff", 2: "#ff1744", 3: "#00c853", 4: "#ff9100", 5: "#9c27b0" };
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
    stayMarkers.forEach(m => m.setMap(null));
    stayMarkers = [];

    const stayList = document.getElementById('stayList');
    stayList.innerHTML = '';

    if (!stays || stays.length === 0) {
      stayList.innerHTML = '<div class="muted" style="padding:8px 0; text-align:center;">근처 숙소가 없어.</div>';
      return;
    }

    stays.forEach(stay => {
      const id = Number(stay.id ?? stay.sIdx ?? stay.idx ?? stay.s_idx);
      const name = String(stay.name ?? stay.sName ?? stay.s_name ?? stay.spotName ?? stay.sname ?? '');
      const lat = Number(stay.lat ?? stay.sLat ?? stay.s_lat);
      const lng = Number(stay.lng ?? stay.sLng ?? stay.s_lng);
      const dist = Number(stay.distance ?? stay.dist ?? stay.distanceKm ?? stay.distance_km ?? 0);

      if (!Number.isFinite(lat) || !Number.isFinite(lng)) return;

      const row = document.createElement('div');
      row.className = 'row';
      const checked = selected.some(x => x.id === id);

      row.innerHTML =
        '<label style="flex:1; cursor: pointer; display: flex; align-items: center;">' +
          '<input type="checkbox" class="stayChk" ' +
            'data-id="' + id + '" data-name="' + escapeHtml(name) + '" data-lat="' + lat + '" data-lng="' + lng + '" ' +
            (checked ? 'checked' : '') + ' style="margin-right: 8px;">' +
          escapeHtml(name) +
          '<span class="muted tiny" style="margin-left:4px;"> (약 ' + dist.toFixed(2) + ' km)</span>' +
        '</label>';

      stayList.appendChild(row);

      const marker = new kakao.maps.Marker({ position: new kakao.maps.LatLng(lat, lng), map: map });
      stayMarkers.push(marker);

      const iw = new kakao.maps.InfoWindow({
        content: '<div style="padding:8px;"><b>' + escapeHtml(name) + '</b><br>약 ' + dist.toFixed(2) + ' km</div>'
      });
      kakao.maps.event.addListener(marker, 'click', () => iw.open(map, marker));
    });

    document.querySelectorAll('.stayChk').forEach(chk => {
      chk.addEventListener('change', () => {
        const id = Number(chk.dataset.id);
        if (chk.checked) {
          if (selected.some(x => x.id === id)) return;
          selected.push({ id: id, name: chk.dataset.name + ' (숙소)', lat: Number(chk.dataset.lat), lng: Number(chk.dataset.lng), day: 1, memo: '숙소' });
          
          // 숙소 선택 시 왼쪽 패널 닫혀있으면 열기
          const leftPanel = document.getElementById('leftTimeline');
          if (leftPanel.classList.contains('closed')) {
            toggleLeftPanel();
          }
        } else {
          selected = selected.filter(x => x.id !== id);
        }
        renderSelected();
        renderMapSelectedLayer(); 
        
        // 삭제 후 리스트가 비어있으면 왼쪽 패널 닫기
        if(selected.length === 0) {
            const leftPanel = document.getElementById('leftTimeline');
            if (!leftPanel.classList.contains('closed')) {
              toggleLeftPanel();
            }
        }
      });
    });
  }

  function savePlan() {
    if (selected.length < 1) {
      alert('저장할 장소가 없어.');
      return;
    }
    buildHiddenInputs();
    document.getElementById('saveForm').submit();
  }

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

  function escapeHtml(str) { return String(str).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;').replaceAll("'",'&#039;'); }
  function escapeXml(str) { return String(str ?? '').replaceAll('&','&amp;').replaceAll('"','&quot;').replaceAll("'",'&#039;').replaceAll('<','&lt;').replaceAll('>','&gt;'); }
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
</body>
</html>