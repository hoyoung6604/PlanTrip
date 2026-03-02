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

    var SPEED = 60;

    function fill(){
      var children = Array.prototype.slice.call(track.children);
      var originals = children.filter(function(el){ return !el.dataset || !el.dataset.clone; });

      var clones = track.querySelectorAll('[data-clone="1"]');
      Array.prototype.forEach.call(clones, function(el){ el.remove(); });

      var minWidth = marquee.clientWidth * 2.2;
      var totalWidth = track.scrollWidth;

      while(totalWidth < minWidth){
        originals.forEach(function(node){
          var clone = node.cloneNode(true);
          clone.dataset.clone = "1";
          track.appendChild(clone);
        });
        totalWidth = track.scrollWidth;
      }

      var oneSetWidth = 0;
      originals.forEach(function(el){ oneSetWidth += el.getBoundingClientRect().width; });
      var gap = parseFloat(getComputedStyle(track).gap || "0");
      oneSetWidth += gap * (originals.length);

      track.style.setProperty('--marquee-distance', oneSetWidth + "px");
      track.style.setProperty('--marquee-duration', (oneSetWidth / SPEED) + "s");
    }

    try{
      var ro = new ResizeObserver(fill);
      ro.observe(marquee);
    }catch(e){
      window.addEventListener('resize', fill);
    }

    window.addEventListener('load', fill);
  }

  function initDomestic(){
    var DOMESTIC = ["부산", "제주도", "수원", "경주"];

    var CITY_CARD = {
      "부산": { img: "/img/sea.jpg", tags: ["#바다", "#맛집"], meta: "국내 · 추천" },
      "제주도": { img: "/img/sea.jpg", tags: ["#자연", "#힐링"], meta: "국내 · 추천" },
      "수원": { img: "/img/hero.jpg", tags: ["#당일치기", "#성곽"], meta: "국내 · 추천" },
      "경주": { img: "/img/mountain.jpg", tags: ["#역사", "#감성"], meta: "국내 · 추천" }
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
  }

  document.addEventListener('DOMContentLoaded', function(){
    initSheetLift();
    initMarquee();
    initDomestic();
    initHeaderSolid();
    initDropdowns();
  });
})();

// ✅ 공통 찜(하트) 토글
window.toggleWish = function(event, sIdx, btn){
    event = event || window.event;
  try{ if(event){ event.preventDefault(); event.stopPropagation(); } }catch(e){}
  var ctx = (window.CONTEXT_PATH || (document.body && document.body.getAttribute('data-context')) || '');
  fetch(ctx + '/api/wish/toggle',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({sIdx:sIdx})})
    .then(function(r){ if(r.status===401){ alert('로그인이 필요한 서비스입니다.'); return null;} return r.json(); })
    .then(function(d){ if(d&&d.success){ if(btn) btn.textContent = d.isHearted?'❤️':'🤍'; } })
    .catch(function(e){ console.error(e); alert('처리 중 오류가 발생했습니다.');});
};