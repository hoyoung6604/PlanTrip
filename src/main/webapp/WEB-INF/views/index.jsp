<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>PlanTrip</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Dancing+Script:wght@400;600;700&display=swap" rel="stylesheet">

  <link rel="stylesheet" href="/css/home.css" />
</head>

<body>

<header class="header" id="header">
  <div class="container header-inner">
    <div class="brand-top">
      <a class="brand-top" href="/" title="홈으로 돌아가기" aria-label="홈으로 돌아가기">
        <img class="brand-logo-img" src="/img/PlanTriplog.png" alt="PlanTrip">
      </a>
    </div>

    <nav class="nav">
		<j:if test="${not empty sessionScope.loginMember and sessionScope.loginMember.getMRole() eq 9}">
		  <a href="/admin">관리자</a>
		</j:if>
      <div class="nav-dropdown" id="catWrap">
        <button class="nav-drop-btn" type="button" id="catBtn" aria-haspopup="true" aria-expanded="false">
          카테고리 <span class="chev" aria-hidden="true">▾</span>
        </button>
        <div class="nav-drop-menu" id="catMenu" role="menu" aria-label="카테고리">
          <a href="#">관광지</a>
          <a href="#">숙소</a>
          <a href="#">문화/액티비티</a>
          <a href="#">맛집</a>
        </div>
      </div>

      <a href="/plan">여행 계획</a>
      <a href="/community">커뮤니티</a>
      <a href="/maps">지도</a>

      <j:if test="${not empty sessionScope.loginMember}">
        <a href="/members/mypage">마이페이지</a>
      </j:if>
    </nav>

    <div class="header-right">
      <!-- 비로그인: 글자 링크만 -->
      <j:if test="${empty sessionScope.loginMember}">
        <a class="header-auth" href="/members/login">로그인</a>
        <a class="header-auth" href="/members/register">회원가입</a>
		
      </j:if>

       <!--로그인: 내 예약 + 햄버거--> 
      <j:if test="${not empty sessionScope.loginMember}">
        <a class="header-link" href="/reservations">내 예약</a>

        <div class="hamburger" id="hmWrap">
          <button class="hamburger-btn" type="button" id="hmBtn" aria-label="메뉴" aria-haspopup="true" aria-expanded="false">
            <span></span><span></span><span></span>
			
          </button>

           <!--✅ hm은 딱 1개만 존재 -->
          <div class="hamburger-menu" id="hm" role="menu" aria-label="메뉴">
            <div class="hm-title">${sessionScope.loginMember.MName}님</div>
            <a class="menu-item" href="/profile">프로필</a>
            <a class="menu-item" href="/members/mypage">마이페이지</a>
            <a class="menu-item" href="/plan">내 여행 계획</a>

            <div class="hm-divider"></div>

            <form action="/members/logout" method="post" style="margin:0;">
              <button class="menu-btn" type="submit">로그아웃</button>
            </form>
          </div>
        </div>
      </j:if>
		  <button type="button" class="theme-toggle" id="themeToggle">🌙</button>
    </div>
  </div>
</header>



<main>
  <section class="hero">
    <div class="hero-copy hero-copy--top">
      <div class="hero-pill hero-title">Wellcome to PlanTrip</div>
    </div>

    <!-- ✅ searchbar 내부에 다른 div 넣지 말기(레이아웃 밀림 방지) -->
    <div class="searchbar">
      <div class="sb-item">
        <div class="sb-icon"></div>
        <input type="text" placeholder="목적지를 입력해주세요" />
      </div>

      <div class="sb-item">
        <div class="sb-icon"></div>
        <input type="date" placeholder="연도-월-일" />
      </div>

      <div class="sb-item sb-select">
        <div class="sb-icon"></div>
        <select aria-label="인원" name="people" required>
          <option value="" selected disabled>인원</option>
          <option value="1">1인</option>
          <option value="2">2인</option>
          <option value="3">3인</option>
          <option value="4+">4인 이상</option>
        </select>
      </div>

      <button class="sb-btn" type="button">검색</button>
    </div>

    <a class="scroll-down" href="#sheet" aria-label="아래로 스크롤"></a>
  </section>

  <section class="sheet" id="sheet">
    <div class="container">
		 <section class="block">
		        <div class="block-head">
		          <h2 class="block-title">인기 여행지</h2>
		          <p class="block-sub">요즘 많이 찾는 여행지로 추천 해드려요 !</p>
		        </div>

		        <div class="marquee" data-marquee>
		          <div class="marquee__track" data-marquee-track>
		            <a class="post-card" href="/spot/sea">
		              <div class="post-img" style="background-image:url('/img/sea.jpg')"></div>
		              <div class="post-body">
		                <div class="post-title">바다 감성 여행</div>
		                <div class="post-meta">테마 · 인기</div>
		                <div class="post-tags">
		                  <span class="tag">#바다</span>
		                  <span class="tag">#감성</span>
		                </div>
		              </div>
		            </a>

		            <a class="post-card" href="/spot/city">
		              <div class="post-img" style="background-image:url('/img/hero.jpg')"></div>
		              <div class="post-body">
		                <div class="post-title">도심 힐링 코스</div>
		                <div class="post-meta">테마 · 인기</div>
		                <div class="post-tags">
		                  <span class="tag">#힐링</span>
		                  <span class="tag">#카페</span>
		                </div>
		              </div>
		            </a>

		            <a class="post-card" href="/spot/mountain">
		              <div class="post-img" style="background-image:url('/img/mountain.jpg')"></div>
		              <div class="post-body">
		                <div class="post-title">산/자연 코스</div>
		                <div class="post-meta">테마 · 인기</div>
		                <div class="post-tags">
		                  <span class="tag">#자연</span>
		                  <span class="tag">#트레킹</span>
		                </div>
		              </div>
		            </a>

		            <a class="post-card" href="/spot/food">
		              <div class="post-img" style="background-image:url('/img/main.jpg')"></div>
		              <div class="post-body">
		                <div class="post-title">맛집 투어</div>
		                <div class="post-meta">테마 · 인기</div>
		                <div class="post-tags">
		                  <span class="tag">#맛집</span>
		                  <span class="tag">#현지</span>
		                </div>
		              </div>
		            </a>
		          </div>
		        </div>
		      </section>

		      <section class="block block-recommend">
		        <div class="course-head">
		          <div class="course-head-left block-head">
		            <h2 class="block-title">맞춤형 여행 코스</h2>
		            <p class="block-sub">원하는 지역과, 원하는 도시를 선택해서 본인에 맞는 맞춤형 여행 코스를 추천해드려요!</p>
		          </div>

		          <div class="course-head-right">
		            <div class="segmented" role="tablist" aria-label="추천 일정 탭">
		              <button class="seg-btn active" type="button">국내</button>
		            </div>
		          </div>
		        </div>

		        <div class="citybar" id="domesticBar"></div>

		        <div class="recommend-wrap">
		          <button class="arrow-btn arrow-left" type="button" aria-label="이전" onclick="scrollRecommend(-1)">
		            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
		              stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
		              <polyline points="15 18 9 12 15 6"></polyline>
		            </svg>
		          </button>

		          <div class="cards" id="recommendCards"></div>

		          <button class="arrow-btn arrow-right" type="button" aria-label="다음" onclick="scrollRecommend(1)">
		            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
		              stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
		              <polyline points="9 18 15 12 9 6"></polyline>
		            </svg>
		          </button>
		        </div>
		      </section>

		    </div>
		  </section>
		</main>
		
		<script>
		  (function () {
		    var sheet = document.querySelector('.sheet');
		    var hero = document.querySelector('.hero');
		    if (!sheet || !hero) return;

		    var MAX_LIFT = 260;
		    var SMOOTH = 0.14;

		    function clamp(v, min, max) { return Math.max(min, Math.min(max, v)); }

		    var target = 0;
		    var current = 0;
		    var rafId = null;

		    function computeTarget() {
		      var rect = hero.getBoundingClientRect();
		      target = clamp(-rect.top, 0, MAX_LIFT);
		      if (!rafId) rafId = requestAnimationFrame(tick);
		    }

		    function tick() {
		      current += (target - current) * SMOOTH;
		      if (Math.abs(target - current) < 0.1) current = target;
		      sheet.style.setProperty('--sheetLift', current.toFixed(2));
		      if (Math.abs(target - current) >= 0.1) rafId = requestAnimationFrame(tick);
		      else rafId = null;
		    }

		    window.addEventListener('scroll', computeTarget, { passive: true });
		    window.addEventListener('resize', computeTarget);
		    computeTarget();
		  })();
		</script>

		<script>
		  (function () {
		    var marquee = document.querySelector('[data-marquee]');
		    var track = document.querySelector('[data-marquee-track]');
		    if (!marquee || !track) return;

		    var SPEED = 60;

		    function fill() {
		      var children = Array.prototype.slice.call(track.children);
		      var originals = children.filter(function (el) { return !el.dataset || !el.dataset.clone; });

		      var clones = track.querySelectorAll('[data-clone="1"]');
		      Array.prototype.forEach.call(clones, function (el) { el.remove(); });

		      var minWidth = marquee.clientWidth * 2.2;
		      var totalWidth = track.scrollWidth;

		      while (totalWidth < minWidth) {
		        originals.forEach(function (node) {
		          var clone = node.cloneNode(true);
		          clone.dataset.clone = "1";
		          track.appendChild(clone);
		        });
		        totalWidth = track.scrollWidth;
		      }

		      var oneSetWidth = 0;
		      originals.forEach(function (el) { oneSetWidth += el.getBoundingClientRect().width; });

		      var gap = parseFloat(getComputedStyle(track).gap || "0");
		      oneSetWidth += gap * (originals.length);

		      track.style.setProperty('--marquee-distance', oneSetWidth + "px");
		      track.style.setProperty('--marquee-duration', (oneSetWidth / SPEED) + "s");
		    }

		    var ro = new ResizeObserver(fill);
		    ro.observe(marquee);
		    window.addEventListener('load', fill);
		  })();
		</script>

		<script>
		  (function () {
		    var DOMESTIC = ["부산", "제주도", "수원", "경주"];

		    var CITY_CARD = {
		      "부산": { img: "/img/sea.jpg", tags: ["#바다", "#맛집"], meta: "국내 · 추천" },
		      "제주도": { img: "/img/sea.jpg", tags: ["#자연", "#힐링"], meta: "국내 · 추천" },
		      "수원": { img: "/img/hero.jpg", tags: ["#당일치기", "#성곽"], meta: "국내 · 추천" },
		      "경주": { img: "/img/mountain.jpg", tags: ["#역사", "#감성"], meta: "국내 · 추천" }
		    };

		    function domesticBar() { return document.getElementById("domesticBar"); }
		    function cardsWrap() { return document.getElementById("recommendCards"); }

		    function makeCityBtn(city) {
		      var btn = document.createElement("button");
		      btn.className = "city-btn";
		      btn.type = "button";
		      btn.textContent = city;
		      btn.addEventListener("click", function () { selectCity(city, btn); });
		      return btn;
		    }

		    function selectCity(city, btn) {
		      var all = document.querySelectorAll(".city-btn");
		      Array.prototype.forEach.call(all, function (b) { b.classList.remove("active"); });
		      if (btn) btn.classList.add("active");
		      renderCards(city);
		    }

		    function renderCards(city) {
		      var wrap = cardsWrap();
		      wrap.innerHTML = "";

		      var base = CITY_CARD[city] || { img: "/img/hero.jpg", tags: ["#추천", "#핵심"], meta: "국내 · 추천" };

		      var samples = [
		        { title: city + " 핵심 일정", meta: base.meta, img: base.img, tags: base.tags },
		        { title: city + " 맛집/명소 코스", meta: base.meta, img: base.img, tags: base.tags },
		        { title: city + " 초보자 동선", meta: base.meta, img: base.img, tags: base.tags }
		      ];

		      samples.forEach(function (item) {
		        var a = document.createElement("a");
		        a.className = "post-card";
		        a.href = "/plan/" + encodeURIComponent(city);

		        var tagsHtml = item.tags.map(function (t) {
		          return '<span class="tag">' + t + '</span>';
		        }).join('');

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

		    function renderDomestic() {
		      domesticBar().innerHTML = "";
		      DOMESTIC.forEach(function (city, idx) {
		        var btn = makeCityBtn(city);
		        domesticBar().appendChild(btn);
		        if (idx === 0) selectCity(city, btn);
		      });
		    }

		    window.addEventListener("load", function () {
		      renderDomestic();
		    });
		  })();
		</script>

		<script>
		  window.scrollRecommend = function (dir) {
		    var wrap = document.getElementById('recommendCards');
		    if (!wrap) return;

		    var card = wrap.querySelector('.post-card');
		    var amount = card ? (card.getBoundingClientRect().width + 16) : 360;
		    wrap.scrollBy({ left: dir * amount, behavior: 'smooth' });
		  };
		</script>

		<script>
		  /* [추가] sheet가 헤더 아래로 올라오면 헤더를 흰색으로 전환 */
		  (function () {
		    var header = document.querySelector('.header');
		    var sheet = document.querySelector('#sheet');
		    if (!header || !sheet) return;

		    function update() {
		      var sheetTop = sheet.getBoundingClientRect().top;
		      var headerH = header.offsetHeight || 64;

		      if (sheetTop <= headerH + 8) header.classList.add('is-solid');
		      else header.classList.remove('is-solid');
		    }

		    window.addEventListener('scroll', update, { passive: true });
		    window.addEventListener('resize', update);
		    update();
		  })();
		</script>

<script>
  // 카테고리 드롭다운(클릭 토글 + 바깥 클릭 닫기)
  (function(){
    const wrap = document.getElementById('catWrap');
    const btn  = document.getElementById('catBtn');

    if(!wrap || !btn) return;

    const close = () => {
      wrap.classList.remove('open');
      btn.setAttribute('aria-expanded', 'false');
    };

    // 햄버거 열려있으면 같이 닫기(겹침 방지)
    const hmBtn  = document.getElementById('hmBtn');
    const hmMenu = document.getElementById('hm');
    const closeHamburger = () => {
      if (!hmBtn || !hmMenu) return;
      hmMenu.classList.remove('open');
      hmBtn.setAttribute('aria-expanded', 'false');
    };

    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const willOpen = !wrap.classList.contains('open');
      document.querySelectorAll('.nav-dropdown.open').forEach(el => el.classList.remove('open'));
      if (willOpen) {
        closeHamburger();
        wrap.classList.add('open');
        btn.setAttribute('aria-expanded', 'true');
      } else close();
    });

    document.addEventListener('click', close);
  })();

  // 햄버거 메뉴(클릭 토글 + 바깥 클릭 닫기)
  (function(){
    const btn  = document.getElementById('hmBtn');
    const menu = document.getElementById('hm');
    const wrap = document.getElementById('hmWrap');

    if(!btn || !menu || !wrap) return;

    const close = () => {
      menu.classList.remove('open');
      btn.setAttribute('aria-expanded', 'false');
    };

    // 카테고리 열려있으면 같이 닫기(겹침 방지)
    const catWrap = document.getElementById('catWrap');
    const catBtn  = document.getElementById('catBtn');
    const closeCategory = () => {
      if (!catWrap || !catBtn) return;
      catWrap.classList.remove('open');
      catBtn.setAttribute('aria-expanded', 'false');
    };

    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const willOpen = !menu.classList.contains('open');
      close();
      if (willOpen) {
        closeCategory();
        menu.classList.add('open');
        btn.setAttribute('aria-expanded', 'true');
      }
    });

    document.addEventListener('click', close);
    wrap.addEventListener('click', (e) => e.stopPropagation());
  })();
</script>

<script>
(function(){
  const root = document.documentElement;
  const key = "plantrip-theme";

  function apply(theme){
    root.dataset.theme = theme;
    const btn = document.getElementById("themeToggle");
    if(btn) btn.textContent = (theme === "light") ? "☀️" : "🌙";
  }

  // 첫 로딩: 저장값 적용
  apply(localStorage.getItem(key) || "dark");

  // 클릭: 저장 + 적용
  document.getElementById("themeToggle")?.addEventListener("click", function(){
    const next = (root.dataset.theme === "light") ? "dark" : "light";
    localStorage.setItem(key, next);
    apply(next);
  });
})();
</script>

  <!-- Floating 고객센터 -->
  <a class="cs-fab" href="${pageContext.request.contextPath}/support" aria-label="고객센터">
    <span class="cs-fab__icon" aria-hidden="true">?</span>
    <span class="cs-fab__label">고객센터</span>
  </a>

</body>
</html>
