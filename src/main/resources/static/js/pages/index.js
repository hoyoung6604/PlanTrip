(function(){
  function ctx(){
    return (window.CONTEXT_PATH || (document.body && document.body.getAttribute("data-context")) || "");
  }

  // 1) 공통 찜(하트) 토글
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
    });
  };

  // 2) 추천 카드 로드 & 렌더
  window.loadRecommend = function(category, btn){
    var wrap = document.getElementById("recommendCards");
    if(!wrap) return;

    document.querySelectorAll(".block-recommend .seg-btn").forEach(b => b.classList.remove("active"));
    if(btn) btn.classList.add("active");

    wrap.innerHTML = "<div style='padding:12px 4px; color:#888;'>불러오는 중...</div>";

    fetch(ctx() + "/spots/api/recommend?category=" + encodeURIComponent(category))
      .then(res => res.json())
      .then(data => {
        if(!data || data.length === 0){
          wrap.innerHTML = "<div style='padding:12px 4px; color:#888;'>추천 결과가 없습니다.</div>";
          return;
        }

        wrap.innerHTML = data.map(item => {
          var id = item.id;
          var name = (item.name && item.name !== "false") ? item.name : "장소명";
          var city = (item.cityName && item.cityName !== "false") ? item.cityName : "기타";

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
      })
      .catch(() => {
        wrap.innerHTML = "<div style='padding:12px 4px; color:#888;'>추천을 불러오지 못했어요.</div>";
      });
  };

  // 3) 추천 덱 좌우 스크롤(화살표 버튼)
  window.scrollRecommend = function(dir){
    var el = document.getElementById("recommendCards");
    if(!el) return;

    var cardW = 380; // CSS --homeCardW 기본값과 맞춤
    var gap = 20;    // CSS --homeCardGap 기본값과 맞춤
    var step = (cardW + gap);

    el.scrollBy({ left: (dir < 0 ? -step : step), behavior: "smooth" });
  };

  // 4) 초기 실행
  document.addEventListener("DOMContentLoaded", function(){
    var firstBtn = document.querySelector(".block-recommend .seg-btn");
    if(firstBtn) window.loadRecommend("TOUR", firstBtn);
  });
})();