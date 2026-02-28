
// scroll-down: 맞춤형 여행 추천 섹션까지 이동
document.addEventListener("DOMContentLoaded", () => {
  const arrow = document.querySelector(".scroll-down");
  const target = document.querySelector("#recommendSection") || document.querySelector("#sheet");
  if (arrow && target) {
    arrow.addEventListener("click", (e) => {
      // hash 기본 이동 대신, 헤더 높이 고려해서 스크롤
      e.preventDefault();
      const headerH = 72;
      const top = target.getBoundingClientRect().top + window.scrollY - headerH - 12;
      window.scrollTo({ top: Math.max(0, top), behavior: "smooth" });
    });
  }
});

(function(){
  function clamp(v, min, max){ return Math.max(min, Math.min(max, v)); }

  function initSheetLift(){
    var sheet = document.querySelector('.sheet');
    var hero = document.querySelector('.hero');
    if(!sheet || !hero) return;

    var MAX_LIFT = 260;
    var SMOOTH = 0.14;
    var target = 0;
    var current = 0;
    var rafId = null;

    function computeTarget(){
      var rect = hero.getBoundingClientRect();
      target = clamp(-rect.top, 0, MAX_LIFT);
      if(!rafId) rafId = requestAnimationFrame(tick);
    }

    function tick(){
      current += (target - current) * SMOOTH;
      if(Math.abs(target - current) < 0.1) current = target;
      sheet.style.setProperty('--sheetLift', current.toFixed(2));
      if(Math.abs(target - current) >= 0.1) rafId = requestAnimationFrame(tick);
      else rafId = null;
    }

    window.addEventListener('scroll', computeTarget, { passive: true });
    window.addEventListener('resize', computeTarget);
    computeTarget();
  }

  function initMarquee(){
    var marquee = document.querySelector('[data-marquee]');
    var track = document.querySelector('[data-marquee-track]');
    if(!marquee || !track) return;

    // 접근성: 모션 줄이기 설정이면 애니메이션을 돌리지 않음
    try{
      if(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches){
        return;
      }
    }catch(e){}

    // px/sec : 값이 고정이면 "거리(카드 폭)가 줄어들 때 duration이 자동으로 짧아짐"
    var SPEED = 60;

    var state = {
      distance: 0,
      x: 0,
      raf: 0,
      lastTs: 0,
      paused: false,
      ro: null
    };

    function getGap(){
      var g = 0;
      try{
        var cs = getComputedStyle(track);
        g = parseFloat(cs.gap || cs.columnGap || '0') || 0;
      }catch(e){}
      return g;
    }

    function getKey(el){
      if(!el) return "";
      var href = el.getAttribute && el.getAttribute("href");
      if(href) return "h:" + href;
      var title = el.textContent ? el.textContent.trim() : "";
      return "t:" + title;
    }

    function isDuplicatedTwoSets(list){
      // 서버(JSP)에서 2세트를 미리 렌더링하는 경우가 있어, '한 세트'만 기준으로 잡아야 함
      if(!list || list.length < 4) return false;
      if(list.length % 2 !== 0) return false;
      var half = list.length / 2;
      for(var i=0;i<half;i++){
        if(getKey(list[i]) !== getKey(list[i+half])) return false;
      }
      return true;
    }

    function getOriginalItems(){
      var children = Array.prototype.slice.call(track.children);
      var originals = children.filter(function(el){ return !el.dataset || !el.dataset.clone; });
      if(isDuplicatedTwoSets(originals)){
        return originals.slice(0, originals.length/2);
      }
      return originals;
    }

    function removeClones(){
      var clones = track.querySelectorAll('[data-clone="1"]');
      Array.prototype.forEach.call(clones, function(el){ el.remove(); });
    }

    function ensureEnoughWidth(baseItems){
      // 최소 2세트 이상 + 여유(화면이 커져도 끊김 방지)
      var minWidth = marquee.clientWidth * 2.5 + state.distance;
      var safety = 0;

      // 기존에 이미 렌더된 두 번째 세트가 있더라도,
      // 랜덤/일일 변경으로 카드 폭이 달라지면 부족해질 수 있어 clone을 추가로 붙임
      while(track.scrollWidth < minWidth && safety < 10){
        baseItems.forEach(function(node){
          var clone = node.cloneNode(true);
          clone.dataset.clone = "1";
          track.appendChild(clone);
        });
        safety++;
      }
    }

    function measureDistance(baseItems){
      var gap = getGap();
      var sum = 0;

      baseItems.forEach(function(el){
        // offsetWidth가 소수점 점프가 덜함
        sum += (el.offsetWidth || Math.round(el.getBoundingClientRect().width) || 0);
      });

      if(!baseItems.length) return 0;

      // ✅ 핵심: 세트 경계에도 gap이 1번 들어가므로 gap * n 이 맞음
      // (n-1은 내부 gap만 계산해서 루프 지점에서 '툭' 끊김이 생길 수 있음)
      sum += gap * baseItems.length;

      return Math.max(1, Math.round(sum));
    }

    function rebuild(){
      var baseItems = getOriginalItems();
      if(!baseItems.length) return;

      // JS 루프는 CSS 애니메이션을 끄고 transform만 제어
      track.classList.add('is-js');
      // CSS keyframes와 충돌 방지(뚝 끊김 방지)
      track.style.animation = 'none';
      track.style.willChange = 'transform';

      // clone은 우리가 필요한 만큼만 붙인다
      removeClones();

      // 1) 거리 측정(한 세트 기준)
      var dist = measureDistance(baseItems);
      state.distance = dist;

      // 2) 충분한 길이 확보(최소 2세트 이상)
      ensureEnoughWidth(baseItems);

      // 3) 현재 위치를 새 distance 안으로 정규화(리사이즈/카드 폭 변동 시 점프 방지)
      if(state.distance > 0){
        // x는 음수 방향으로 흐르므로, [-distance, 0) 범위로 맞춤
        var mod = state.x % state.distance;
        state.x = (mod > 0) ? (mod - state.distance) : mod;
      }else{
        state.x = 0;
      }

      // 첫 프레임에 바로 적용
      applyTransform();
    }

    function applyTransform(){
      track.style.transform = 'translate3d(' + state.x.toFixed(2) + 'px,0,0)';
    }

    function tick(ts){
      if(!state.lastTs) state.lastTs = ts;
      var dt = (ts - state.lastTs) / 1000;
      state.lastTs = ts;

      if(!state.paused && state.distance > 0){
        state.x -= SPEED * dt;
        // 루프
        if(state.x <= -state.distance){
          // 큰 dt(탭 비활성 후 복귀)에도 안정적으로
          state.x = state.x % state.distance;
        }
        applyTransform();
      }

      state.raf = requestAnimationFrame(tick);
    }

    function start(){
      if(state.raf) cancelAnimationFrame(state.raf);
      state.lastTs = 0;
      state.raf = requestAnimationFrame(tick);
    }

    function stop(){
      if(state.raf) cancelAnimationFrame(state.raf);
      state.raf = 0;
      state.lastTs = 0;
    }

    // hover 시 일시정지(기존 UX 유지)
    marquee.addEventListener('mouseenter', function(){ state.paused = true; });
    marquee.addEventListener('mouseleave', function(){ state.paused = false; });

    // 터치(모바일)에서 스크롤 중엔 잠깐 멈추면 덜 끊겨 보임
    marquee.addEventListener('touchstart', function(){ state.paused = true; }, { passive:true });
    marquee.addEventListener('touchend', function(){ state.paused = false; }, { passive:true });
    marquee.addEventListener('touchcancel', function(){ state.paused = false; }, { passive:true });

    // 리사이즈/폰트 로드/이미지 로드 등으로 폭이 바뀌어도 끊김 없이 distance 재계산
    try{
      state.ro = new ResizeObserver(function(){
        // 레이아웃 안정화 후 재빌드
        requestAnimationFrame(rebuild);
      });
      state.ro.observe(marquee);
    }catch(e){
      window.addEventListener('resize', function(){ requestAnimationFrame(rebuild); });
    }

    window.addEventListener('load', function(){
      rebuild();
      start();
    });
    // DOMContentLoaded 시점에서도 한 번(초기 페인트 전에 세팅)
    rebuild();
    start();
  }

  function initDomestic(){
    var DOMESTIC = ["부산", "제주도", "수원", "서울", "경주", "속초", "강릉"]; /* 추가: 서울, 속초, 강릉 */

    var CITY_CARD = {
      "부산": { img: "/img/sea.jpg", tags: ["#바다", "#맛집"], meta: "국내 · 추천" },
      "제주도": { img: "/img/sea.jpg", tags: ["#자연", "#힐링"], meta: "국내 · 추천" },
      "수원": { img: "/img/hero.jpg", tags: ["#당일치기", "#성곽"], meta: "국내 · 추천" },
      "서울": { img: "#", tags: ["#도심", "#문화"], meta: "국내 · 추천" },
      "경주": { img: "/img/mountain.jpg", tags: ["#역사", "#감성"], meta: "국내 · 추천" },
      "속초": { img: "#", tags: ["#바다", "#설악산"], meta: "국내 · 추천" },
      "강릉": { img: "#", tags: ["#커피", "#바다"], meta: "국내 · 추천" }
    };

    function domesticBar(){ return document.getElementById("domesticBar"); }
    function cardsWrap(){ return document.getElementById("recommendCards"); }
    if(!domesticBar() || !cardsWrap()) return;

    function makeCityBtn(city){
      var btn = document.createElement("button");
      btn.className = "city-btn";
      btn.type = "button";
      btn.textContent = city;
      btn.addEventListener("click", function(){ selectCity(city, btn); });
      return btn;
    }

    function selectCity(city, btn){
      var all = document.querySelectorAll('.city-btn');
      Array.prototype.forEach.call(all, function(b){ b.classList.remove('active'); });
      if(btn) btn.classList.add('active');
      renderCards(city);
    }

    function renderCards(city){
      var wrap = cardsWrap();
      wrap.innerHTML = "";

      var base = CITY_CARD[city] || { img: "/img/hero.jpg", tags: ["#추천", "#핵심"], meta: "국내 · 추천" };
      var samples = [
        { title: city + " 핵심 일정", meta: base.meta, img: base.img, tags: base.tags },
        { title: city + " 맛집/명소 코스", meta: base.meta, img: base.img, tags: base.tags },
        { title: city + " 초보자 동선", meta: base.meta, img: base.img, tags: base.tags }
      ];

      samples.forEach(function(item){
        var a = document.createElement("a");
        a.className = "post-card";
        a.href = "/plan/" + encodeURIComponent(city);

        var tagsHtml = item.tags.map(function(t){ return '<span class="tag">' + t + '</span>'; }).join('');
        a.innerHTML =
          '<div class="post-img" style="background-image:url(\'' + item.img + '\')"></div>' +
          '<div class="post-body">' +
          '<div class="post-title">' + item.title + '</div>' +
          '<div class="post-meta">' + item.meta + '</div>' +
          '<div class="post-tags">' + tagsHtml + '</div>' +
          '</div>';

        wrap.appendChild(a);
      });
    }

    function renderDomestic(){
      domesticBar().innerHTML = "";
      DOMESTIC.forEach(function(city, idx){
        var btn = makeCityBtn(city);
        domesticBar().appendChild(btn);
        if(idx === 0) selectCity(city, btn);
      });
    }

    window.addEventListener('load', renderDomestic);

    // 화살표 버튼에서 호출
    window.scrollRecommend = function(dir){
      var wrap = document.getElementById('recommendCards');
      if(!wrap) return;
      var card = wrap.querySelector('.post-card');
      var amount = card ? (card.getBoundingClientRect().width + 16) : 360;
      wrap.scrollBy({ left: dir * amount, behavior: 'smooth' });
    };
  }

  function initHeaderSolid(){
    var header = document.querySelector('.header');
    var sheet = document.querySelector('#sheet');
    if(!header || !sheet) return;
    function update(){
      var sheetTop = sheet.getBoundingClientRect().top;
      var headerH = header.offsetHeight || 64;
      if(sheetTop <= headerH + 8) header.classList.add('is-solid');
      else header.classList.remove('is-solid');
    }
    window.addEventListener('scroll', update, { passive: true });
    window.addEventListener('resize', update);
    update();
  }

  function initDropdowns(){
    // 카테고리
    (function(){
      var wrap = document.getElementById('catWrap');
      var btn = document.getElementById('catBtn');
      if(!wrap || !btn) return;

      var hmBtn = document.getElementById('hmBtn');
      var hmMenu = document.getElementById('hm');

      function close(){
        wrap.classList.remove('open');
        btn.setAttribute('aria-expanded', 'false');
      }

      function closeHamburger(){
        if(!hmBtn || !hmMenu) return;
        hmMenu.classList.remove('open');
        hmBtn.setAttribute('aria-expanded', 'false');
      }

      btn.addEventListener('click', function(e){
        e.stopPropagation();
        var willOpen = !wrap.classList.contains('open');
        document.querySelectorAll('.nav-dropdown.open').forEach(function(el){ el.classList.remove('open'); });
        if(willOpen){
          closeHamburger();
          wrap.classList.add('open');
          btn.setAttribute('aria-expanded', 'true');
        }else close();
      });

      document.addEventListener('click', close);
    })();

    // 햄버거
    (function(){
      var btn = document.getElementById('hmBtn');
      var menu = document.getElementById('hm');
      var wrap = document.getElementById('hmWrap');
      if(!btn || !menu || !wrap) return;

      var catWrap = document.getElementById('catWrap');
      var catBtn = document.getElementById('catBtn');

      function close(){
        menu.classList.remove('open');
        btn.setAttribute('aria-expanded', 'false');
      }

      function closeCategory(){
        if(!catWrap || !catBtn) return;
        catWrap.classList.remove('open');
        catBtn.setAttribute('aria-expanded', 'false');
      }

      btn.addEventListener('click', function(e){
        e.stopPropagation();
        var willOpen = !menu.classList.contains('open');
        close();
        if(willOpen){
          closeCategory();
          menu.classList.add('open');
          btn.setAttribute('aria-expanded', 'true');
        }
      });

      document.addEventListener('click', close);
      wrap.addEventListener('click', function(e){ e.stopPropagation(); });
    })();

    // 교통수단 드롭다운 (index.jsp 전용 헤더에만 필요)
    (function(){
      var wrap = document.getElementById('transportWrap');
      var btn = document.getElementById('transportBtn');
      if(!wrap || !btn) return;

      var hmBtn = document.getElementById('hmBtn');
      var hmMenu = document.getElementById('hm');

      function close(){
        wrap.classList.remove('open');
        btn.setAttribute('aria-expanded','false');
      }

      function closeHamburger(){
        if(!hmMenu || !hmBtn) return;
        hmMenu.classList.remove('open');
        hmBtn.setAttribute('aria-expanded','false');
      }

      btn.addEventListener('click', function(e){
        e.preventDefault();
        e.stopPropagation();

        var willOpen = !wrap.classList.contains('open');
        document.querySelectorAll('.nav-dropdown.open').forEach(function(el){ el.classList.remove('open'); });

        if (willOpen){
          closeHamburger();
          wrap.classList.add('open');
          btn.setAttribute('aria-expanded','true');
        } else {
          close();
        }
      });

      document.addEventListener('click', close);
      wrap.addEventListener('click', function(e){ e.stopPropagation(); });
    })();
  }

  document.addEventListener('DOMContentLoaded', function(){
    initSheetLift();
    initMarquee();
    initDomestic();
    initHeaderSolid();
    initDropdowns();
  });
})();
