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
  </style>

  <!-- ✅ appkey는 하나만! + autoload=false 필수 -->
  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a3ff57f5cf42d50dce5ccbd693ebcf24${kakaoJsKey}&libraries=services&autoload=false"></script>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<h2>장소 선택 & 경로 계산</h2>
<p class="muted">도시/목적 조건에 맞는 장소를 선택하면 지도에 표시하고, “경로 계산”으로 시간/거리를 구해줘.</p>

<div class="wrap">
  <div id="map"></div>

  <div class="side">

    <div class="box">
      <b>장소 목록</b>
      <div class="list">
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

<script>
  // ✅ contextPath 고정
  const ctx = '${pageContext.request.contextPath}';

  // ✅ 선택 데이터
  let selected = []; // [{id,name,lat,lng,day,memo}]

  // ✅ 지도 전역(딱 1번만 선언)
  let map = null;
  let bounds = null;
  let markers = [];
  let line = null;

  const pIdx = Number('${pIdx}');
  const selectedBox = document.getElementById('selectedBox');
  const hiddenInputs = document.getElementById('hiddenInputs');

  // ✅ Kakao SDK 로드가 끝난 뒤에만 실행 (kakao undefined 방지)
  kakao.maps.load(function () {
    initMap();
    bindCheckboxEvents();
    renderSelected(); // 초기 렌더
  });

  function initMap() {
    const mapEl = document.getElementById('map');

    map = new kakao.maps.Map(mapEl, {
      center: new kakao.maps.LatLng(37.5665, 126.9780),
      level: 7
    });

    bounds = new kakao.maps.LatLngBounds();
  }

  function bindCheckboxEvents() {
    document.querySelectorAll('.spotChk').forEach(chk => {

      // ✅ row(줄) 클릭 시 지도 이동
      const row = chk.closest('.row');
      if (row) {
        row.style.cursor = 'pointer';
        row.addEventListener('click', (e) => {
          // 체크박스 자체 클릭은 기존 로직 타게 두고
          if (e.target && (e.target.tagName === 'INPUT')) return;

          const lat = Number(chk.dataset.lat);
          const lng = Number(chk.dataset.lng);
          if (!lat || !lng || !map) return;

          const pos = new kakao.maps.LatLng(lat, lng);
          map.setLevel(5);
          map.panTo(pos);
        });
      }

      // ✅ 체크박스 체크/해제 로직(기존 그대로)
      chk.addEventListener('change', () => {
        const id = Number(chk.dataset.id);

        if (chk.checked) {
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
        }

        renderSelected();
        renderMapMarkers();
      });

    });
  }

  function fitBounds() {
    if (!map || !bounds || markers.length === 0) return;
    map.setBounds(bounds);
  }

  function clearMap() {
    markers.forEach(m => m.setMap(null));
    markers = [];

    // ✅ bounds는 재생성이 정답 (setSouthWest 같은 거 없음)
    bounds = new kakao.maps.LatLngBounds();

    if (line) { line.setMap(null); line = null; }
  }

  function clearSelection() {
    document.querySelectorAll('.spotChk').forEach(chk => chk.checked = false);
    selected = [];
    renderSelected();
    clearMap();
    document.getElementById('totalDist').innerText = '-';
    document.getElementById('totalTime').innerText = '-';
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
    renderMapMarkers();
  }

  function moveDown(idx) {
    if (idx >= selected.length - 1) return;
    const tmp = selected[idx + 1];
    selected[idx + 1] = selected[idx];
    selected[idx] = tmp;
    renderSelected();
    renderMapMarkers();
  }

  function removeAt(idx) {
    const id = selected[idx].id;
    selected.splice(idx, 1);

    const chk = document.querySelector('.spotChk[data-id="' + id + '"]');
    if (chk) chk.checked = false;

    renderSelected();
    renderMapMarkers();
  }

  function renderMapMarkers() {
    if (!map) return;

    clearMap();
    if (selected.length === 0) return;

    selected.forEach((s, idx) => {
      const pos = new kakao.maps.LatLng(s.lat, s.lng);
      bounds.extend(pos);

      const marker = new kakao.maps.Marker({ position: pos, map: map });
      markers.push(marker);

      const iw = new kakao.maps.InfoWindow({
        content: '<div style="padding:6px 8px; font-size:13px;"><b>'
               + (idx + 1) + '. ' + escapeHtml(s.name)
               + '</b></div>'
      });

      kakao.maps.event.addListener(marker, 'click', () => iw.open(map, marker));
    });

    map.setBounds(bounds);
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

    if (line) { line.setMap(null); line = null; }
    if (data.path && data.path.length) {
      const path = data.path.map(p => new kakao.maps.LatLng(p.lat, p.lng));
      line = new kakao.maps.Polyline({
        path: path,
        strokeWeight: 5,
        strokeOpacity: 0.85
      });
      line.setMap(map);
    }
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
  
  async function savePlan() {
    if (selected.length < 1) {
      alert('저장할 장소가 없어.');
      return;
    }

    // seq 자동 생성 (선택 순서 기준)
    const items = selected.map((s, idx) => ({
      sIdx: s.id,
      day: s.day,
      seq: idx + 1,
      memo: s.memo || ""
    }));

    const payload = {
	  pIdx: pIdx,
      title: "내 여행 플랜",   // 필요하면 input으로 바꿔도 됨
      start: null,            // 서버에서 기본값 처리
      end: null,
      items: items
    };

    try {
      const res = await fetch(ctx + '/route/save', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      });

      if (!res.ok) {
        const text = await res.text();
        alert('저장 실패: ' + text);
        return;
      }

      const data = await res.json();

      if (data.ok) {
        alert('계획 저장이 완료되었습니다.');
        // 👉 저장 성공 후 메인페이지 이동
        window.location.href = ctx + '/';
      } else {
        alert(data.msg || '저장 실패');
      }

    } catch (e) {
      console.error(e);
      alert('서버 오류 발생');
    }
  }
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>

</body>
</html>