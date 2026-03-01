// transport.js - 교통수단 공통 UX
// - (A) native date input(data-tp-date): change 시 hidden(YYYYMMDD) 세팅 + 자동 submit
// - (B) custom date input(data-tp-date-text): 팝업 캘린더를 input 바로 아래에 띄우고 선택 시 동일 처리
(function () {
  function toYYYYMMDD(iso) { return iso ? iso.replaceAll('-', '') : ''; }
  function toISO(yyyymmdd) {
    if (!yyyymmdd) return '';
    const s = String(yyyymmdd);
    if (s.includes('-')) return s;
    if (s.length !== 8) return '';
    return s.slice(0,4) + '-' + s.slice(4,6) + '-' + s.slice(6,8);
  }
  function pad2(n){ return (n<10?'0':'')+n; }

  // ===== Flight: arrival options based on departure/date =====
  const __tpArrivalsCache = new Map(); // key: dep|date -> [ids]
  async function fetchFlightArrivals(depId, yyyymmdd){
    const key = depId + '|' + yyyymmdd;
    if (__tpArrivalsCache.has(key)) return __tpArrivalsCache.get(key);

    try{
      const url = (window.CONTEXT_PATH || '') + `/transport/flight/arrivals?depAirportId=${encodeURIComponent(depId)}&depPlandTime=${encodeURIComponent(yyyymmdd)}`;
      const res = await fetch(url, { headers: { 'Accept':'application/json' }});
      if (!res.ok) throw new Error('bad response');
      const data = await res.json();
      const ids = Array.isArray(data) ? data : (data && Array.isArray(data.ids) ? data.ids : []);
      __tpArrivalsCache.set(key, ids);
      return ids;
    }catch(e){
      // fallback: allow all (no filtering)
      return [];
    }
  }

  function getAirportNameById(id){
    const btn = document.querySelector(`button[data-air-id="${CSS.escape(id)}"]`);
    return btn ? (btn.textContent || '').trim() : id;
  }

  function updateSummaries(){
    const dep = document.getElementById('depAirportId');
    const arr = document.getElementById('arrAirportId');
    const depS = document.getElementById('depSummary');
    const arrS = document.getElementById('arrSummary');
    if (depS && dep) depS.textContent = '출발: ' + getAirportNameById(dep.value);
    if (arrS && arr) arrS.textContent = '도착: ' + getAirportNameById(arr.value);

    // Search bar readonly inputs (flight)
    const depTxt = document.getElementById('tpDepAirportText');
    const arrTxt = document.getElementById('tpArrAirportText');
    if (depTxt && dep) depTxt.value = getAirportNameById(dep.value);
    if (arrTxt && arr) arrTxt.value = getAirportNameById(arr.value);
  }

  function setActiveInRow(row, val){
    if (!row) return;
    row.querySelectorAll('button.tp-chip').forEach(function(b){
      b.classList.toggle('is-active', b.getAttribute('data-air-id') === val);
    });
  }

  function applyArrivalVisibility(allowedIds){
    const arrRow = document.querySelector('[data-tp-air-chips="arrAirportId"]');
    if (!arrRow) return;

    const hasAllowed = Array.isArray(allowedIds) && allowedIds.length > 0;
    arrRow.querySelectorAll('button[data-air-id]').forEach(function(btn){
      const id = btn.getAttribute('data-air-id');
      // if allowedIds empty -> don't hide anything
      const ok = !hasAllowed || allowedIds.includes(id);
      btn.style.display = ok ? '' : 'none';
    });
  }

  async function ensureArrivalValid(){
    const dep = document.getElementById('depAirportId');
    const arr = document.getElementById('arrAirportId');
    const dateHidden = document.getElementById('depPlandTime');
    if (!dep || !arr || !dateHidden) return;

    const allowed = await fetchFlightArrivals(dep.value, dateHidden.value);
    if (Array.isArray(allowed) && allowed.length > 0){
      applyArrivalVisibility(allowed);

      if (!allowed.includes(arr.value)){
        arr.value = allowed[0];
        const arrRow = document.querySelector('[data-tp-air-chips="arrAirportId"]');
        setActiveInRow(arrRow, arr.value);
      }
    }else{
      // no filtering info -> show all
      applyArrivalVisibility([]);
    }
    updateSummaries();
  }

  async function autoSubmitFlight(){
    const dep = document.getElementById('depAirportId');
    if (!dep || !dep.form) return;
    await ensureArrivalValid();
    dep.form.submit();
  }

  // A) native date input
  document.querySelectorAll('[data-tp-date]').forEach(function (dateEl) {
    const hiddenId = dateEl.getAttribute('data-tp-hidden');
    const hiddenEl = hiddenId ? document.getElementById(hiddenId) : null;
    if (!hiddenEl) return;

    dateEl.addEventListener('change', function () {
      hiddenEl.value = toYYYYMMDD(dateEl.value);
      if (dateEl.form) dateEl.form.submit();
    });
  });

  // B) custom date picker
  function buildPicker(host, onPick) {
    const pop = document.createElement('div');
    pop.className = 'tp-datepicker';
    pop.setAttribute('role','dialog');
    pop.innerHTML = `
      <div class="tp-dp-head">
        <button type="button" class="tp-dp-nav" data-nav="prev" aria-label="이전 달">‹</button>
        <div class="tp-dp-title"></div>
        <button type="button" class="tp-dp-nav" data-nav="next" aria-label="다음 달">›</button>
      </div>
      <div class="tp-dp-dow">
        <span>일</span><span>월</span><span>화</span><span>수</span><span>목</span><span>금</span><span>토</span>
      </div>
      <div class="tp-dp-grid"></div>
      <div class="tp-dp-foot">
        <button type="button" class="tp-dp-today">오늘</button>
        <button type="button" class="tp-dp-close">닫기</button>
      </div>
    `;
    document.body.appendChild(pop);

    function measureSize(){
      // Ensure we can measure even when hidden
      const prevDisplay = pop.style.display;
      const prevLeft = pop.style.left;
      const prevTop = pop.style.top;
      pop.style.display = 'block';
      pop.style.left = '-9999px';
      pop.style.top = '-9999px';
      const rect = pop.getBoundingClientRect();
      pop.style.display = prevDisplay;
      pop.style.left = prevLeft;
      pop.style.top = prevTop;
      return { w: rect.width || 280, h: rect.height || 340 };
    }

    function position(){
      const r = host.getBoundingClientRect();
      const pad = 8;
      const { w: popW, h: popH } = measureSize();

      // Use fixed positioning so parent overflow/scroll doesn't clip the popover.
      let top = r.bottom + pad;
      let left = r.left;

      const vw = document.documentElement.clientWidth;
      const vh = document.documentElement.clientHeight;

      if (left + popW + 12 > vw) left = Math.max(12, vw - popW - 12);
      if (top + popH + 12 > vh) top = Math.max(12, r.top - popH - 12);

      pop.style.left = left + 'px';
      pop.style.top = top + 'px';
    }

    const title = pop.querySelector('.tp-dp-title');
    const grid = pop.querySelector('.tp-dp-grid');

    const today = new Date();
    let view = new Date(today.getFullYear(), today.getMonth(), 1);
    let selectedISO = '';

    function render() {
      const y = view.getFullYear();
      const m = view.getMonth(); // 0-based
      title.textContent = `${y}년 ${pad2(m+1)}월`;

      grid.innerHTML = '';
      const firstDay = new Date(y, m, 1);
      const startDow = firstDay.getDay();
      const lastDate = new Date(y, m+1, 0).getDate();

      // leading blanks
      for (let i=0; i<startDow; i++){
        const b = document.createElement('button');
        b.type = 'button';
        b.className = 'tp-dp-cell is-empty';
        b.disabled = true;
        grid.appendChild(b);
      }
      for (let d=1; d<=lastDate; d++){
        const iso = `${y}-${pad2(m+1)}-${pad2(d)}`;
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'tp-dp-cell';
        btn.textContent = String(d);

        if (iso === selectedISO) btn.classList.add('is-selected');
        const tISO = `${today.getFullYear()}-${pad2(today.getMonth()+1)}-${pad2(today.getDate())}`;
        if (iso === tISO) btn.classList.add('is-today');

        btn.addEventListener('click', function(){
          selectedISO = iso;
          onPick(iso);
          hide();
        });
        grid.appendChild(btn);
      }
    }

    function show() {
      render();
      position();
      pop.classList.add('is-open');
      pop.setAttribute('aria-hidden','false');
    }
    function hide() {
      pop.classList.remove('is-open');
      pop.setAttribute('aria-hidden','true');
    }

    pop.querySelectorAll('.tp-dp-nav').forEach(function(b){
      b.addEventListener('click', function(){
        const dir = b.getAttribute('data-nav');
        view = new Date(view.getFullYear(), view.getMonth() + (dir==='prev'?-1:1), 1);
        render();
      });
    });
    pop.querySelector('.tp-dp-close').addEventListener('click', hide);
    pop.querySelector('.tp-dp-today').addEventListener('click', function(){
      const iso = `${today.getFullYear()}-${pad2(today.getMonth()+1)}-${pad2(today.getDate())}`;
      view = new Date(today.getFullYear(), today.getMonth(), 1);
      selectedISO = iso;
      onPick(iso);
      hide();
    });

    return { show, hide, setSelected: function(iso){ selectedISO = iso; }, el: pop };
  }

  function initCustomDate(el) {
    const hiddenId = el.getAttribute('data-tp-hidden');
    const hiddenEl = hiddenId ? document.getElementById(hiddenId) : null;
    if (!hiddenEl) return;

    // wrapper
    const wrap = document.createElement('div');
    wrap.className = 'tp-datewrap';
    el.parentNode.insertBefore(wrap, el);
    wrap.appendChild(el);

    // calendar button
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'tp-datebtn';
    btn.setAttribute('aria-label','달력 열기');
    btn.textContent = '📅';
    wrap.appendChild(btn);

    // initial value
    const initialISO = el.value || toISO(hiddenEl.value);
    if (initialISO) el.value = initialISO;

    const picker = buildPicker(wrap, function(iso){
      el.value = iso;
      hiddenEl.value = toYYYYMMDD(iso);
      // Sync arrival date (UI only)
      const arrDate = document.getElementById('arrDate');
      if (arrDate) arrDate.value = iso;
      if (el.form) {
        if (el.form.action && el.form.action.includes('/transport/flight')) {
          autoSubmitFlight();
        } else {
          el.form.submit();
        }
      }
    });
    if (initialISO) picker.setSelected(initialISO);

    function open(){
      picker.setSelected(el.value);
      picker.show();
    }
    el.addEventListener('click', open);
    btn.addEventListener('click', open);

    // close on outside
    document.addEventListener('mousedown', function(e){
      if (!wrap.contains(e.target) && !picker.el.contains(e.target)) picker.hide();
    });
    // esc close
    document.addEventListener('keydown', function(e){
      if (e.key === 'Escape') picker.hide();
    });
  }

  
  // C) airport chips -> hidden value + active state + auto submit
  document.querySelectorAll('[data-tp-air-chips]').forEach(function(row){
    const hiddenId = row.getAttribute('data-tp-air-chips');
    const hidden = hiddenId ? document.getElementById(hiddenId) : null;
    if (!hidden) return;

    row.addEventListener('click', function(e){
      const btn = e.target.closest('button[data-air-id]');
      if (!btn) return;
      e.preventDefault();

      const id = btn.getAttribute('data-air-id');
      hidden.value = id;

      row.querySelectorAll('button.tp-chip').forEach(function(b){ b.classList.remove('is-active'); });
      btn.classList.add('is-active');

      // 같은 공항 선택 방지(출발=도착) 정도는 UI에서만 살짝 처리
      const otherId = hiddenId === 'depAirportId' ? 'arrAirportId' : 'depAirportId';
      const other = document.getElementById(otherId);
      if (other && other.value === id) {
        // 다른 쪽 첫 번째 버튼으로 자동 변경
        const alt = row.parentElement.querySelector('[data-tp-air-chips="'+otherId+'"] button[data-air-id]:not([data-air-id="'+id+'"])');
        if (alt) {
          other.value = alt.getAttribute('data-air-id');
          const otherRow = row.parentElement.querySelector('[data-tp-air-chips="'+otherId+'"]');
          if (otherRow) {
            otherRow.querySelectorAll('button.tp-chip').forEach(function(b){ b.classList.remove('is-active'); });
            alt.classList.add('is-active');
          }
        }
      }

      updateSummaries();
      if (hidden.form) {
        if (hidden.form.action && hidden.form.action.includes('/transport/flight')) {
          // departure change should filter arrival options automatically
          if (hiddenId === 'depAirportId') {
            autoSubmitFlight();
          } else {
            hidden.form.submit();
          }
        } else {
          hidden.form.submit();
        }
      }
    });
  });

  // D) swap dep/arr airports (flight)
  document.querySelectorAll('[data-tp-swap-air]').forEach(function(btn){
    btn.addEventListener('click', function(e){
      e.preventDefault();
      const dep = document.getElementById('depAirportId');
      const arr = document.getElementById('arrAirportId');
      if (!dep || !arr) return;

      const tmp = dep.value;
      dep.value = arr.value;
      arr.value = tmp;

      const depRow = document.querySelector('[data-tp-air-chips="depAirportId"]');
      const arrRow = document.querySelector('[data-tp-air-chips="arrAirportId"]');
      function sync(row, val){
        if (!row) return;
        row.querySelectorAll('button.tp-chip').forEach(function(b){
          b.classList.toggle('is-active', b.getAttribute('data-air-id') === val);
        });
      }
      sync(depRow, dep.value);
      sync(arrRow, arr.value);

      updateSummaries();
      if (dep.form) autoSubmitFlight();
    });
  });

  

  /* Bus/Train: 출발 변경 시 도착을 자동으로 맞추기 + 터미널 파라미터 초기화 */
  function initBusTrainSmartCities(){
    const mode = document.body && document.body.dataset ? document.body.dataset.tpMode : '';
    if (mode !== 'expbus' && mode !== 'train') return;

    const depRow = document.querySelector('[data-tp-city-row="dep"]');
    const arrRow = document.querySelector('[data-tp-city-row="arr"]');
    if (!depRow || !arrRow) return;

    const depChips = Array.from(depRow.querySelectorAll('a.tp-chip'));
    if (depChips.length === 0) return;

    const cities = depChips.map(a => (a.textContent || '').trim()).filter(Boolean);
    function pickAltCity(dep, currentArr){
      if (currentArr && currentArr !== dep) return currentArr;
      for (const c of cities) {
        if (c !== dep) return c;
      }
      return currentArr || dep;
    }

    depChips.forEach(function(a){
      a.addEventListener('click', function(e){
        if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
        e.preventDefault();

        const current = new URL(window.location.href);
        const curArr = current.searchParams.get('arrCity') || '';

        const url = new URL(this.href, window.location.origin);
        const depCity = url.searchParams.get('depCity') || '';
        const nextArr = pickAltCity(depCity, curArr);

        url.searchParams.set('arrCity', nextArr);

        // 터미널/역 선택 값은 도시 변경 시 깨지기 쉬워서 초기화
        url.searchParams.delete('depTerminalId');
        url.searchParams.delete('arrTerminalId');
        url.searchParams.delete('depSubTerminalId');
        url.searchParams.delete('arrSubTerminalId');

        window.location.href = url.toString();
      });
    });
  }

  // E) swap dep/arr cities (bus/train)
  function initSwapCities(){
    const mode = document.body && document.body.dataset ? document.body.dataset.tpMode : '';
    if (mode !== 'expbus' && mode !== 'train') return;

    document.querySelectorAll('[data-tp-swap-city]').forEach(function(btn){
      btn.addEventListener('click', function(e){
        e.preventDefault();
        const url = new URL(window.location.href);
        const dep = (url.searchParams.get('depCity') || '').trim();
        const arr = (url.searchParams.get('arrCity') || '').trim();
        if (!dep || !arr) return;

        url.searchParams.set('depCity', arr);
        url.searchParams.set('arrCity', dep);

        // paging/terminal params reset
        url.searchParams.delete('page');
        url.searchParams.delete('depTerminalId');
        url.searchParams.delete('arrTerminalId');
        url.searchParams.delete('depSubTerminalId');
        url.searchParams.delete('arrSubTerminalId');

        window.location.href = url.toString();
      });
    });
  }

  initBusTrainSmartCities();
  initSwapCities();
  
  document.querySelectorAll('input[data-tp-date-text]').forEach(initCustomDate);
  // initial sync (flight)
  updateSummaries();
  ensureArrivalValid();
})();
