// =========================================================
// 1. UI 및 애니메이션 담당 (기존 index.js 영역)
// =========================================================

// scroll-down: 맞춤형 여행 추천 섹션까지 이동
document.addEventListener("DOMContentLoaded", () => {
  const arrow = document.querySelector(".scroll-down");
  const target = document.querySelector("#recommendSection") || document.querySelector("#sheet");
  if (arrow && target) {
    arrow.addEventListener("click", (e) => {
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
    var heroCopy = document.querySelector('.hero-copy');
    var header = document.querySelector('.header');
    if(!sheet || !hero) return;

    var MAX_LIFT = 260;
    var SMOOTH = 0.14;
    var target = 0;
    var current = 0;
    var rafId = null;

    function computeTarget(){
      var rect = hero.getBoundingClientRect();
      target = clamp(-rect.top, 0, MAX_LIFT);

      if(heroCopy){
        var sheetTop = sheet.getBoundingClientRect().top;
        var headerH = header ? (header.offsetHeight || 64) : 64;
        var shouldHide = (target >= (MAX_LIFT - 1)) || (sheetTop <= headerH + 8);
        heroCopy.classList.toggle('is-hidden', shouldHide);
      }

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

    try{
      if(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches){
        return;
      }
    }catch(e){}

    var SPEED = 60;
    var state = { distance: 0, x: 0, raf: 0, lastTs: 0, paused: false, ro: null };

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
      var minWidth = marquee.clientWidth * 2.5 + state.distance;
      var safety = 0;
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
        sum += (el.offsetWidth || Math.round(el.getBoundingClientRect().width) || 0);
      });
      if(!baseItems.length) return 0;
      sum += gap * baseItems.length;
      return Math.max(1, Math.round(sum));
    }

    function rebuild(){
      var baseItems = getOriginalItems();
      if(!baseItems.length) return;

      track.classList.add('is-js');
      track.style.animation = 'none';
      track.style.willChange = 'transform';
      removeClones();

      var dist = measureDistance(baseItems);
      state.distance = dist;
      ensureEnoughWidth(baseItems);

      if(state.distance > 0){
        var mod = state.x % state.distance;
        state.x = (mod > 0) ? (mod - state.distance) : mod;
      }else{
        state.x = 0;
      }
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
        if(state.x <= -state.distance){
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

    marquee.addEventListener('mouseenter', function(){ state.paused = true; });
    marquee.addEventListener('mouseleave', function(){ state.paused = false; });
    marquee.addEventListener('touchstart', function(){ state.paused = true; }, { passive:true });
    marquee.addEventListener('touchend', function(){ state.paused = false; }, { passive:true });
    marquee.addEventListener('touchcancel', function(){ state.paused = false; }, { passive:true });

    try{
      state.ro = new ResizeObserver(function(){ requestAnimationFrame(rebuild); });
      state.ro.observe(marquee);
    }catch(e){
      window.addEventListener('resize', function(){ requestAnimationFrame(rebuild); });
    }

    window.addEventListener('load', function(){
      rebuild();
      start();
    });
    rebuild();
    start();
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
    (function(){
      var btn = document.getElementById('hmBtn');
      var menu = document.getElementById('hm');
      var wrap = document.getElementById('hmWrap');
      if(!btn || !menu || !wrap) return;

      function close(){
        menu.classList.remove('open');
        btn.setAttribute('aria-expanded', 'false');
      }

      btn.addEventListener('click', function(e){
        e.stopPropagation();
        var willOpen = !menu.classList.contains('open');
        close();
        if(willOpen){
          menu.classList.add('open');
          btn.setAttribute('aria-expanded', 'true');
        }
      });
      document.addEventListener('click', close);
      wrap.addEventListener('click', function(e){ e.stopPropagation(); });
    })();
  }

  document.addEventListener('DOMContentLoaded', function(){
    initSheetLift();
    initMarquee();
    initHeaderSolid();
    initDropdowns();
  });
})();

// =========================================================
// 2. 데이터 통신 및 렌더링 담당 (기존 page_index.js 병합)
// =========================================================

(function(){
  function ctx(){
    return (window.CONTEXT_PATH || (document.body && document.body.getAttribute("data-context")) || "");
  }

  // 1) 공통 찜(하트) 토글 기능
  window.toggleWish = function(event, sIdx, btn){
    if(event){ event.preventDefault(); event.stopPropagation(); }

    fetch(ctx() + "/api/wish/toggle", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ sIdx: sIdx })
    })
    .then(res => res.json())
    .then(data => {
      if(data && data.success){
        btn.textContent = data.isHearted ? "❤️" : "🤍";
        btn.classList.toggle("active", !!data.isHearted);
      }
    })
    .catch(err => console.error("Wish toggle error:", err));
  };

  // 2) 맞춤형 추천 카드 로드 & 렌더링 (깜빡임 방지 & 부드러운 전환 적용)
    window.loadRecommend = function(category, btn){
      var wrap = document.getElementById("recommendCards");
      if(!wrap) return;

      // 활성화된 버튼 색상 변경
      document.querySelectorAll(".block-recommend .seg-btn").forEach(b => b.classList.remove("active"));
      if(btn) btn.classList.add("active");

      // ✅ 1. 기존 카드를 싹 지우는 대신, 스르륵 투명해지는 애니메이션(Fade-out)을 줍니다.
      wrap.style.transition = "opacity 0.2s ease-in-out";
      wrap.style.opacity = "0";

      // 서버에 데이터 요청
      fetch(ctx() + "/spots/api/recommend?category=" + encodeURIComponent(category), {
        headers: { "Accept": "application/json" }
      })
      .then(res => res.json())
      .then(data => {
        // ✅ 2. 투명해지는 시간(0.2초)을 잠시 기다렸다가 내용을 새로운 카드로 교체합니다.
        setTimeout(() => {
          if(!data || !data.length){
            wrap.innerHTML = "<div style='padding:12px 4px; color:#888;'>추천 결과가 없습니다.</div>";
          } else {
            wrap.innerHTML = data.map(item => {
              var id = item.id;
              var name = item.name || "";
              var city = item.cityName || "";

              // 사진 경로
              var img = ctx() + "/img/spot/" + id + "_1.jpg";
              var fallback = ctx() + "/img/hero.jpg"; 

              return `
                <a class="post-card post-card--overlay" href="${ctx()}/spots/detail/${id}">
                  <img class="card-bg" src="${img}" alt="${name}" onerror="this.onerror=null;this.src='${fallback}';">
                  <div class="card-grad"></div>

                  <button class="wish-btn ${item.isHearted ? "active" : ""}" onclick="toggleWish(event, ${id}, this)">
                    ${item.isHearted ? "❤️" : "🤍"}
                  </button>

                  <div class="card-body">
                    <div class="card-title">${name}</div>
                    <div class="card-sub">${city} · 추천</div>
                  </div>
                </a>
              `;
            }).join("");
          }
          
          // ✅ 3. 내용 교체가 끝나면 다시 스르륵 선명하게 나타나도록(Fade-in) 합니다.
          wrap.style.opacity = "1";
        }, 200);
      })
      .catch(() => {
        setTimeout(() => {
          wrap.innerHTML = "<div style='padding:12px 4px; color:#ef4444;'>추천 데이터를 불러오지 못했습니다.</div>";
          wrap.style.opacity = "1";
        }, 200);
      });
    };

  // 3) 추천 덱 좌우 스크롤(화살표 버튼) 동작
  window.scrollRecommend = function(dir){
    var el = document.getElementById("recommendCards");
    if(!el) return;
    
    var cardW = 380; // home.css에 설정된 카드 폭
    var gap = 20;    // 카드 사이 간격
    el.scrollBy({ left: dir * (cardW + gap), behavior: "smooth" });
  };

  // 4) 초기 진입 시 "관광지" 탭 데이터 자동 로드
  window.addEventListener("DOMContentLoaded", function(){
    var firstBtn = document.querySelector(".block-recommend .seg-btn.active") || document.querySelector(".block-recommend .seg-btn");
    if(firstBtn){
      window.loadRecommend("TOUR", firstBtn);
    }
  });
})();