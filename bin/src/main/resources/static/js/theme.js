(function(){
  var root = document.documentElement;
  var key = "plantrip-theme";

  function applyRouteClass(){
    try{
      var path = (location && location.pathname) ? location.pathname : "";
      var isHome =
        path === "/" ||
        /\/index(\.jsp)?$/.test(path) ||
        /\/home$/.test(path) ||
        /\/main$/.test(path);

      if(document.body){
        document.body.classList.toggle("is-home", !!isHome);
      }
    }catch(e){}
  }

  function ensureToggleUI(btn){
    if(!btn) return;
    if(btn.dataset.uiReady === '1') return;

    btn.dataset.uiReady = '1';
    btn.classList.add('theme-toggle--pill');
    btn.innerHTML = '';

    var sun = document.createElement('span');
    sun.className = 'tt-icon tt-sun';
    sun.setAttribute('aria-hidden','true');
    sun.textContent = '☀';

    var moon = document.createElement('span');
    moon.className = 'tt-icon tt-moon';
    moon.setAttribute('aria-hidden','true');
    moon.textContent = '☾';

    var dot = document.createElement('span');
    dot.className = 'tt-indicator';
    dot.setAttribute('aria-hidden','true');

    btn.appendChild(sun);
    btn.appendChild(moon);
    btn.appendChild(dot);
  }

  function setToggleState(btn, t){
    if(!btn) return;
    ensureToggleUI(btn);
    btn.setAttribute('aria-pressed', (t === 'dark') ? 'true' : 'false');
    btn.dataset.theme = t;
  }

  function applyTheme(t){
    root.dataset.theme = t;
    var btn = document.getElementById("themeToggle");
    if(btn) setToggleState(btn, t);
  }

  function getTheme(){
    try{ return localStorage.getItem(key) || root.dataset.theme || "dark"; }
    catch(e){ return root.dataset.theme || "dark"; }
  }

  function setTheme(t){
    try{ localStorage.setItem(key, t); }catch(e){}
    applyTheme(t);
  }

  function initThemeToggle(){
    var btn = document.getElementById("themeToggle");
    if(!btn) return;

    ensureToggleUI(btn);
    setToggleState(btn, getTheme());

    btn.addEventListener("click", function(){
      var next = (root.dataset.theme === "dark") ? "light" : "dark";
      setTheme(next);
    });
  }

  // =========================
  // Nav hover magnify (cursor-driven)
  // - 로그인/회원가입 버튼은 건드리지 않음 (header-auth는 제외)
  // =========================
  function initNavMagnify(){
    var nav = document.querySelector('header .nav');
    if(!nav) return;

    var items = Array.prototype.slice.call(
      nav.querySelectorAll(':scope > a, :scope > .nav-dropdown > .nav-drop-btn')
    );
    if(!items.length) return;

    var raf = 0;
    var lastX = 0;

    function apply(){
      raf = 0;
      items.forEach(function(el){
        var r = el.getBoundingClientRect();
        var cx = r.left + r.width/2;
        var dist = Math.abs(lastX - cx);

        // 0~1 (가까울수록 1) : 더 넓게 퍼지게 해서 '파도'처럼 한 덩어리로 움직이게
        var t = Math.max(0, 1 - dist/240);
        // 더 크게(확 눈에 보이게) + 부드럽게
        var scale = 1 + 0.28 * (t*t);
        var ty = -5 * t;

        // 개별 아이템이 옆으로 따로 노는 느낌을 줄이기 위해 X이동은 제거
        el.style.transition = 'transform 120ms cubic-bezier(.2,.85,.2,1)';
        el.style.transform = 'translate(0px,' + ty.toFixed(2) + 'px) scale(' + scale.toFixed(3) + ')';
      });
    }

    function onMove(e){
      lastX = e.clientX;
      if(!raf) raf = requestAnimationFrame(apply);
    }

    function reset(){
      if(raf){ cancelAnimationFrame(raf); raf = 0; }
      items.forEach(function(el){
        el.style.transition = 'transform 360ms cubic-bezier(.2,.85,.2,1)';
        el.style.transform = '';
      });
    }

    nav.addEventListener('mousemove', onMove);
    nav.addEventListener('mouseleave', reset);
  }

  function init(){
    applyRouteClass();
    applyTheme(getTheme());
    initThemeToggle();
    initNavMagnify();
  }

  if(document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', init);
  }else{
    init();
  }
})();