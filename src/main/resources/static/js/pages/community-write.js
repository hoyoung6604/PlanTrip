/* =========================================================
   community-write.js
   - 후기 작성 페이지 전용 UI 스크립트
   - 로직/파라미터는 유지(rvStar, photos)
   - 별점: hover 미리보기 + 클릭 확정
   - 사진: 다중 업로드 미리보기 + 삭제 + 최대 10장 제한
   ========================================================= */

(function(){
  "use strict";

  function qs(sel, root){ return (root || document).querySelector(sel); }
  function qsa(sel, root){ return Array.from((root || document).querySelectorAll(sel)); }


// 썸네일 hover 확대(Trip.com 느낌) - 하나의 프리뷰를 공유
let hoverPreviewEl = null;
function ensureHoverPreview(){
  if(hoverPreviewEl) return hoverPreviewEl;
  const el = document.createElement('div');
  el.className = 'rv-hover-preview';
  el.innerHTML = '<img alt="preview"/>';
  document.body.appendChild(el);
  hoverPreviewEl = el;
  return el;
}
function showHoverPreview(src, x, y){
  const el = ensureHoverPreview();
  const img = el.querySelector('img');
  img.src = src;
  el.style.display = 'block';
  positionHoverPreview(x, y);
}
function hideHoverPreview(){
  if(!hoverPreviewEl) return;
  hoverPreviewEl.style.display = 'none';
}
function positionHoverPreview(x, y){
  if(!hoverPreviewEl) return;
  const pad = 14;
  const w = 360, h = 240; // 대략 값(overflow 방지용)
  let left = x + pad;
  let top  = y + pad;
  const vw = window.innerWidth, vh = window.innerHeight;
  if(left + w > vw) left = Math.max(12, x - w - pad);
  if(top + h > vh)  top  = Math.max(12, y - h - pad);
  hoverPreviewEl.style.left = left + 'px';
  hoverPreviewEl.style.top  = top + 'px';
}

  // ----------------------------
  // 별점 UI
  // ----------------------------
  function initRating(){
    const wrap = qs('.rv-rating');
    const select = qs('select.rvStarSelect');
    if(!wrap || !select) return;

    const stars = qsa('.rv-star', wrap);
    const text = qs('.rv-rating-text', wrap);
    const max = parseInt(wrap.getAttribute('data-max') || '5', 10);

    function getValue(){
      const v = parseInt(select.value || '5', 10);
      return isNaN(v) ? 5 : v;
    }
    function setValue(v){
      select.value = String(v);
      render(v);
    }
    function render(active){
      stars.forEach(btn => {
        const v = parseInt(btn.getAttribute('data-value') || '0', 10);
        btn.classList.toggle('is-on', v <= active);
      });
      if(text) text.textContent = active + '/' + max;
      wrap.setAttribute('data-value', String(active));
    }

    // 기본값(현재 select 선택값) 반영
    render(getValue());

    // hover: 미리보기
    stars.forEach(btn => {
      btn.addEventListener('mouseenter', () => {
        const v = parseInt(btn.getAttribute('data-value') || '0', 10);
        if(v) render(v);
      });
      btn.addEventListener('focus', () => {
        const v = parseInt(btn.getAttribute('data-value') || '0', 10);
        if(v) render(v);
      });
      btn.addEventListener('click', () => {
        const v = parseInt(btn.getAttribute('data-value') || '0', 10);
        if(v) setValue(v);
      });
    });

    wrap.addEventListener('mouseleave', () => render(getValue()));
    wrap.addEventListener('blur', () => render(getValue()), true);
  }

  // ----------------------------
  // 사진 미리보기 UI
  // ----------------------------
  function initPhotos(){
    const input = qs('#photosInput');
    const photoWrap = qs('.rv-photo');
    const grid = qs('.rv-photo-grid');
    const pickBtns = qsa('[data-action="pick"]', photoWrap || document);
    const countEl = qs('[data-count]', photoWrap || document);
    const maxEl = qs('[data-max]', photoWrap || document);

    if(!input || !grid) return;

    const max = parseInt(input.getAttribute('data-max') || '10', 10) || 10;
    if(maxEl) maxEl.textContent = String(max);

    /** @type {File[]} */
    let files = [];
    /** @type {string[]} */
    let urls = [];

    function revokeAll(){
      urls.forEach(u => { try{ URL.revokeObjectURL(u); }catch(_e){} });
      urls = [];
    }

    // 라이트박스(모달 확대)
    const lb = qs('.rv-lightbox');
    const lbImg = qs('.rv-lightbox-img', lb || document);
    const lbCloseBtns = qsa('[data-action="close"]', lb || document);
    function openLightbox(src, alt){
      if(!lb || !lbImg) return;
      lbImg.src = src;
      lbImg.alt = alt || '';
      lb.setAttribute('aria-hidden', 'false');
      document.body.classList.add('is-lightbox-open');
    }
    function closeLightbox(){
      if(!lb || !lbImg) return;
      lb.setAttribute('aria-hidden', 'true');
      document.body.classList.remove('is-lightbox-open');
      // src는 revoke 대상일 수 있으니 여기서 비우지 않음(thumb 제거 시 revoke)
    }
    lbCloseBtns.forEach(b => b.addEventListener('click', closeLightbox));
    document.addEventListener('keydown', (e) => {
      if(e.key === 'Escape') closeLightbox();
    });

    function rebuildInput(){
      const dt = new DataTransfer();
      files.forEach(f => dt.items.add(f));
      input.files = dt.files;
    }

    function setCount(){
      if(countEl) countEl.textContent = String(files.length);
      grid.dataset.empty = files.length === 0 ? 'true' : 'false';
    }

    function clearThumbs(){
      revokeAll();
      qsa('.rv-thumb', grid).forEach(el => el.remove());
    }

    function addThumb(file, idx, url){
      const item = document.createElement('div');
      item.className = 'rv-thumb';

      const img = document.createElement('img');
      img.alt = file.name;
      img.loading = 'lazy';
      img.src = url;
      img.addEventListener('click', () => openLightbox(url, file.name));
      img.style.cursor = 'zoom-in';
      img.addEventListener('mouseenter', (e) => showHoverPreview(img.src, e.clientX, e.clientY));
      img.addEventListener('mousemove', (e) => positionHoverPreview(e.clientX, e.clientY));
      img.addEventListener('mouseleave', hideHoverPreview);

      const rm = document.createElement('button');
      rm.type = 'button';
      rm.className = 'rv-thumb-remove';
      rm.setAttribute('aria-label', '사진 삭제');
      rm.innerHTML = `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 3h6l1 2h4v2H4V5h4l1-2zm1 6h2v10h-2V9zm4 0h2v10h-2V9zM6 9h2v10H6V9z"/></svg>`;
      rm.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        files.splice(idx, 1);
        rebuildInput();
        render();
      });

      item.appendChild(img);
      item.appendChild(rm);
      // 추가 버튼(첫 타일) 앞에 삽입
      const addTile = qs('.rv-photo-add', grid);
      grid.insertBefore(item, addTile || null);
    }

    function render(){
      clearThumbs();
      files.forEach((f, i) => {
        const url = URL.createObjectURL(f);
        urls.push(url);
        addThumb(f, i, url);
      });
      setCount();
    }

    function openPicker(){
      input.click();
    }

    // 버튼/타일 클릭
    pickBtns.forEach(btn => {
      btn.addEventListener('click', openPicker);
      btn.addEventListener('keydown', (e) => {
        if(e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          openPicker();
        }
      });
    });

    // 파일 선택
    input.addEventListener('change', () => {
      const selected = Array.from(input.files || []);
      if(selected.length === 0) return;

      // 현재 + 새로 추가가 max 넘으면 잘라냄
      const remain = Math.max(0, max - files.length);
      const adding = selected.slice(0, remain);

      if(adding.length < selected.length){
        alert('사진은 최대 ' + max + '장까지 첨부할 수 있어요.');
      }

      files = files.concat(adding);
      rebuildInput();
      render();

      // ✅ 중요
      // 기존 코드에서 input.value = '' 로 초기화하면,
      // 브라우저에 따라 "제출 시 파일이 비어버리는" 현상이 발생할 수 있습니다.
      // (즉, 미리보기는 보이는데 서버에는 파일이 안 넘어가서 DB/상세보기에서 사진이 없는 케이스)
      // 그래서 값 초기화는 하지 않습니다.
    });

    // 초기 상태(서버에서 값 세팅은 없지만 안전)
    files = Array.from(input.files || []);
    if(files.length > max) files = files.slice(0, max);
    rebuildInput();
    render();
  }

  // -------------------------
  // 후기 내용 글자수 카운팅
  // -------------------------
  function initContentCounter(){
    const ta = document.getElementById('rvCont');
    // ✅ 화면마다 카운터 id가 다르게 들어간 버전이 섞여 있어서 둘 다 지원
    //  - (구버전)  #rvContCounter : "123/5000 (남음)" 형태
    //  - (신버전)  #rvContCount / #rvContMax : "123 / 5000" 형태 (사용자 화면)
    const counterSingle = document.getElementById('rvContCounter');
    const counterNow = document.getElementById('rvContCount');
    const counterMax = document.getElementById('rvContMax');
    if(!ta || (!counterSingle && !counterNow)) return;

    const MAX = Number(ta.getAttribute('maxlength') || (counterMax && counterMax.textContent) || 5000);
    if(counterMax) counterMax.textContent = String(MAX);

    const update = () => {
      const len = (ta.value || '').length;
      const remain = Math.max(0, MAX - len);

      if(counterSingle){
        counterSingle.textContent = `${len}/${MAX} (${remain} 남음)`;
        counterSingle.classList.toggle('is-over', len > MAX);
      }

      if(counterNow){
        counterNow.textContent = String(len);
        // 신버전 UI는 기본적으로 maxlength가 걸려 있어서 over 상태는 사실상 안 뜸
        counterNow.classList.toggle('is-over', len > MAX);
      }
    };

    // 입력 중 실시간 반영
    ta.addEventListener('input', update);

    // 초기 표시
    update();

    // 혹시 브라우저/자동완성 등으로 초과값이 들어온 경우 마지막에 잘라줌
    const form = ta.form;
    if(form){
      form.addEventListener('submit', (e) => {
        if((ta.value || '').length > MAX){
          ta.value = (ta.value || '').substring(0, MAX);
          update();
        }
      });
    }
  }

  // DOM Ready
  document.addEventListener('DOMContentLoaded', function(){
    initRating();
    initPhotos();
    initContentCounter();
  });
})();