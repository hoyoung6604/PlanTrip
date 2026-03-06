// transport.js - 교통수단 공통 UX
// - (A) native date input(data-tp-date): change 시 hidden(YYYYMMDD) 세팅 + 자동 submit
// - (B) custom date input(data-tp-date-text): 팝업 캘린더를 input 바로 아래에 띄우고 선택 시 동일 처리
(function () {
  /* =========================================
     Toast + Shake UX
     - 출발/도착(또는 출발/도착 공항) 동일 선택 시 안내
     ========================================= */
  let __tpToastEl = null;
  let __tpToastTimer = null;

  function ensureToast(){
    if (__tpToastEl) return __tpToastEl;
    const el = document.createElement('div');
    el.className = 'tp-toast';
    el.setAttribute('role', 'status');
    el.setAttribute('aria-live', 'polite');
    el.innerHTML = '<div class="tp-toast__msg"></div>';
    document.body.appendChild(el);
    __tpToastEl = el;
    return el;
  }

  function showToast(msg){
    const el = ensureToast();
    const msgEl = el.querySelector('.tp-toast__msg');
    if (msgEl) msgEl.textContent = msg;

    el.classList.add('is-show');
    clearTimeout(__tpToastTimer);
    __tpToastTimer = setTimeout(function(){
      el.classList.remove('is-show');
    }, 1600);
  }

  function shake(el){
    if (!el) return;
    el.classList.remove('tp-shake');
    // reflow
    void el.offsetWidth;
    el.classList.add('tp-shake');
    setTimeout(function(){ el.classList.remove('tp-shake'); }, 420);
  }

  function warnSameRoute(targetEl, otherEl){
    showToast('출발/도착은 같을 수 없어요');
    shake(targetEl);
    shake(otherEl);
  }

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

  // When swap just happened, don't auto-reset the arrival value.
  const swapped = !!window.__tpSwapJustHappened;
  if (swapped) window.__tpSwapJustHappened = false;

  if (Array.isArray(allowed) && allowed.length > 0){
    applyArrivalVisibility(allowed);

    // If current arrival is not allowed, only auto-fix when it wasn't a swap action.
    if (!allowed.includes(arr.value) && !swapped){
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
        // UX: 출발/도착 공항 동일 선택 안내
        const otherRow = row.parentElement.querySelector('[data-tp-air-chips="'+otherId+'"]');
        const otherActive = otherRow ? otherRow.querySelector('button.tp-chip.is-active') : null;
        warnSameRoute(btn, otherActive || (otherId === 'depAirportId' ? document.getElementById('tpDepAirportText') : document.getElementById('tpArrAirportText')));

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

      // mark swap so arrival auto-filter won't overwrite user intention
      window.__tpSwapJustHappened = true;

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

  

  
  /* Bus/Train: 도시 칩 선택 & 스왑 버튼 로직 (URL 의존 X) */
  function initBusTrainCityUI(){
    const mode = document.body && document.body.dataset ? document.body.dataset.tpMode : '';
    if (mode !== 'expbus' && mode !== 'train') return;

    const panel = document.querySelector('.tp-form-panel');
    const form = panel ? panel.closest('form') : document.querySelector('form');
    if (!form) return;

    const depHidden = document.getElementById('depCityHidden') || form.querySelector('input[name="depCity"]');
    const arrHidden = document.getElementById('arrCityHidden') || form.querySelector('input[name="arrCity"]');
    if (!depHidden || !arrHidden) return;

    const depText = document.getElementById('tpDepCityText') || form.querySelector('.tp-searchbar__loc .tp-field:nth-child(1) .tp-field__input');
    const arrText = document.getElementById('tpArrCityText') || form.querySelector('.tp-searchbar__loc .tp-field:nth-child(3) .tp-field__input');

    const depTerminalHidden = document.getElementById('depTerminalIdHidden') || form.querySelector('input[name="depTerminalId"]');
    const arrTerminalHidden = document.getElementById('arrTerminalIdHidden') || form.querySelector('input[name="arrTerminalId"]');
    const depSubTerminalHidden = document.getElementById('depSubTerminalIdHidden') || form.querySelector('input[name="depSubTerminalId"]');
    const arrSubTerminalHidden = document.getElementById('arrSubTerminalIdHidden') || form.querySelector('input[name="arrSubTerminalId"]');

    const depRow = document.querySelector('[data-tp-city-row="dep"]');
    const arrRow = document.querySelector('[data-tp-city-row="arr"]');

    function norm(s){ return (s || '').toString().trim(); }

    function readCityList(){
      const base = depRow ? Array.from(depRow.querySelectorAll('.tp-chip')).map(el => norm(el.textContent)) : [];
      return base.filter(Boolean);
    }
    const cities = readCityList();

    function firstDifferent(target){
      const t = norm(target);
      for (const c of cities){
        if (norm(c) !== t) return c;
      }
      return t;
    }

    function clearTerminals(){
      if (depTerminalHidden) depTerminalHidden.value = '';
      if (arrTerminalHidden) arrTerminalHidden.value = '';
      if (depSubTerminalHidden) depSubTerminalHidden.value = '';
      if (arrSubTerminalHidden) arrSubTerminalHidden.value = '';
    }

    function setActive(row, value){
      if (!row) return;
      const v = norm(value);
      row.querySelectorAll('.tp-chip').forEach(function(chip){
        chip.classList.toggle('is-active', norm(chip.textContent) === v);
      });
    }

    function syncBar(){
      if (depText) depText.value = norm(depHidden.value);
      if (arrText) arrText.value = norm(arrHidden.value);
      setActive(depRow, depHidden.value);
      setActive(arrRow, arrHidden.value);
    }

    function safeSetDep(city){
      const next = norm(city);
      const conflict = norm(arrHidden.value) === next && next;
      depHidden.value = next;
      if (conflict){
        // keep service usable by auto-fixing the other side, but notify user
        arrHidden.value = firstDifferent(depHidden.value);
      }
      return conflict;
    }

    function safeSetArr(city){
      const next = norm(city);
      const conflict = norm(depHidden.value) === next && next;
      arrHidden.value = next;
      if (conflict){
        depHidden.value = firstDifferent(arrHidden.value);
      }
      return conflict;
    }

    // Intercept city chip clicks (anchors or buttons)
    function bindRow(row, which){
      if (!row) return;
      row.addEventListener('click', function(e){
        const chip = e.target.closest('.tp-chip');
        if (!chip) return;

        // prevent navigation when it's an anchor
        if (chip.tagName === 'A') e.preventDefault();

        const city = norm(chip.textContent);
        if (!city) return;

        clearTerminals();
        let conflicted = false;
        if (which === 'dep') {
          conflicted = safeSetDep(city);
          if (conflicted) {
            const otherActive = arrRow ? arrRow.querySelector('.tp-chip.is-active') : null;
            warnSameRoute(chip, otherActive || arrText);
            shake(depText);
            shake(arrText);
          }
        } else {
          conflicted = safeSetArr(city);
          if (conflicted) {
            const otherActive = depRow ? depRow.querySelector('.tp-chip.is-active') : null;
            warnSameRoute(chip, otherActive || depText);
            shake(depText);
            shake(arrText);
          }
        }

        syncBar();
        form.submit();
      });
    }
    bindRow(depRow, 'dep');
    bindRow(arrRow, 'arr');

    // Swap button in search bar
    document.querySelectorAll('[data-tp-swap-city]').forEach(function(btn){
      btn.addEventListener('click', function(e){
        e.preventDefault();
        const d = norm(depHidden.value);
        const a = norm(arrHidden.value);
        if (!d || !a) return;

        clearTerminals();
        depHidden.value = a;
        arrHidden.value = d;

        // final guard (dep==arr)
        if (norm(depHidden.value) === norm(arrHidden.value)){
          arrHidden.value = firstDifferent(depHidden.value);
        }

        syncBar();
        form.submit();
      });
    });

    // Initial sync on load
    syncBar();
  }

  initBusTrainCityUI();

  document.querySelectorAll('input[data-tp-date-text]').forEach(initCustomDate);
  // initial sync (flight)
  updateSummaries();
  ensureArrivalValid();
})();