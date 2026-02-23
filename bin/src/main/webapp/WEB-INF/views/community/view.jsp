<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>후기 상세</title>

  <!-- 커뮤니티/테마 공통 리소스 (다른 커뮤니티 JSP들과 통일) -->
  <link rel="stylesheet" href="/css/theme-sky.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/community.css" />
  <link rel="stylesheet" href="/css/auth-modal.css" />
  <link rel="stylesheet" href="/css/ui-toast.css" />
  <!-- 상세 전용은 마지막에 로드해서 덮어쓰기 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/community-review-view.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/auth-modal.js"></script>
  <script defer src="/js/auth-guard.js"></script>
</head>
<body>
<div class="cm-shell">

  <!-- 좌측 사이드바는 커뮤니티 목록과 동일 구조로 유지 (통일감) -->
  <aside class="mp-side">
    <div class="mp-brand">
      <div class="mp-logo"></div>
      <div class="mp-brand-name">Community</div>
    </div>

    <div class="sec">
      <div class="sec-title">MENU</div>
      <nav class="mp-nav">
        <a href="${pageContext.request.contextPath}/community">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 6h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              <path d="M4 18h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
            </svg>
          </span>
          여행 후기 목록
        </a>

        <a href="${pageContext.request.contextPath}/community/write">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M12 5v14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              <path d="M5 12h14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
            </svg>
          </span>
          후기 작성
        </a>

        <a href="${pageContext.request.contextPath}/community/my-reviews">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 7h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              <path d="M4 17h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
            </svg>
          </span>
          내 여행 후기
        </a>
      </nav>
    </div>

    <div class="sec sec-bottom">
      <div class="sec-title">SETTINGS</div>
      <nav class="mp-nav">
        <!-- auth-guard.js가 로그인 여부 확인 후 팝업/이동 처리 -->
        <a href="${pageContext.request.contextPath}/members/mypage">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 13h7V4H4v9Zm9 7h7V11h-7v9ZM4 20h7v-5H4v5Zm9-16v5h7V4h-7Z"
                stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" />
            </svg>
          </span>
          마이페이지로
        </a>

        <a href="${pageContext.request.contextPath}/">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M3 10.5 12 3l9 7.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
              <path d="M5 10.5V21h14V10.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </span>
          메인으로
        </a>
      </nav>
    </div>
  </aside>

  <!-- ✅ 본문 -->
  <main class="cm-main">
    <div class="rv-card">

      <!-- 상단 헤더 (제목 + 목록 버튼) -->
      <div class="rv-header">
        <div class="rv-title">
          <h1 class="rv-h1">${review.rvTitle}</h1>
          <div class="rv-sub">
            <span class="rv-muted">${review.member.MName}</span>
            <span class="rv-dot">·</span>
            <span class="rv-muted">장소: ${review.rvRegion}</span>
            <span class="rv-dot">·</span>
            <span class="rv-muted">조회 ${review.rvVCount}</span>
          </div>
        </div>

        <button class="rv-btn rv-btn-ghost" type="button"
                onclick="location.href='${pageContext.request.contextPath}/community'">
          목록
        </button>
      </div>

      <!-- ✅ Trip.com 느낌의 2열 레이아웃 -->
      <div class="rv-grid">

        <!-- LEFT: 사진 -->
        <section class="rv-left">
	          <c:choose>
	            <%-- 1) reviewPhotoT(메타) 기준으로 사진이 있으면 그걸 우선 사용 --%>
            <c:when test="${not empty photos}">
              <div class="rv-photo">
                <div class="rv-photo-main">
                  <img id="rvMainImg"
                       src="<c:url value='/review-photos/${photos[0].rpIdx}'/>"
                       alt="후기 사진" />
                  <button class="rv-nav rv-prev" type="button" aria-label="이전">‹</button>
                  <button class="rv-nav rv-next" type="button" aria-label="다음">›</button>
                  <div class="rv-photo-count" id="rvPhotoCount">1 / ${fn:length(photos)}</div>
                </div>

                <div class="rv-thumbs">
                  <c:forEach var="p" items="${photos}" varStatus="st">
                    <c:url var="pSrc" value="/review-photos/${p.rpIdx}"/>
                    <button type="button" class="rv-thumb ${st.index==0 ? 'is-active' : ''}"
                            data-idx="${st.index}"
                            data-src="${pSrc}">
                      <img src="${pSrc}" alt="thumb"/>
                    </button>
                  </c:forEach>
                </div>
              </div>
            </c:when>
	            <%-- 2) (호환) DB에 c_img(파일명 묶음)만 남아있는 경우에도 사진 표시 --%>
            <c:when test="${empty photos and not empty review.rvImg}">
              <c:set var="imgNames" value="${fn:split(review.rvImg,'|')}" />
              <div class="rv-photo">
                <div class="rv-photo-main">
                  <c:url var="mainNameSrc" value="/review-photos/name/${fn:trim(imgNames[0])}"/>
                  <img id="rvMainImg"
                       src="${mainNameSrc}"
                       alt="후기 사진" />
                  <button class="rv-nav rv-prev" type="button" aria-label="이전">‹</button>
                  <button class="rv-nav rv-next" type="button" aria-label="다음">›</button>
                  <div class="rv-photo-count" id="rvPhotoCount">1 / ${fn:length(imgNames)}</div>
                </div>

                <div class="rv-thumbs">
                  <c:forEach var="n" items="${imgNames}" varStatus="st">
                    <c:url var="nSrc" value="/review-photos/name/${fn:trim(n)}"/>
                    <button type="button" class="rv-thumb ${st.index==0 ? 'is-active' : ''}"
                            data-idx="${st.index}"
                            data-src="${nSrc}">
                      <img src="${nSrc}" alt="thumb"/>
                    </button>
                  </c:forEach>
                </div>
              </div>
            </c:when>
            <c:otherwise>
              <div class="rv-photo-empty">
                <div class="rv-photo-empty-box">후기 사진</div>
                <div class="rv-muted">등록된 사진이 없습니다.</div>
              </div>
            </c:otherwise>
          </c:choose>
        </section>

        <!-- RIGHT: 작성자/별점 + 내용(스크롤) -->
        <aside class="rv-side">
          <div class="rv-side-head">
            <div class="rv-user">
              <div class="rv-user-avatar">
                <c:choose>
                  <c:when test="${not empty review.member and not empty review.member.MName}">${fn:substring(review.member.MName,0,1)}</c:when>
                  <c:otherwise>?</c:otherwise>
                </c:choose>
              </div>
              <div class="rv-user-meta">
                <div class="rv-user-name">${review.member.MName}</div>
                <div class="rv-user-sub">
                  작성일:
                  <c:choose>
                    <c:when test="${not empty review.rvRegDate}">${fn:replace(fn:substring(review.rvRegDate,0,10),'-','.')}</c:when>
                    <c:otherwise>-</c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>

            <div class="rv-rating">
              <span class="rv-stars">★★★★★</span>
              <span class="rv-score">${review.rvStar != null ? review.rvStar : 0}/5</span>
            </div>
          </div>

          <div class="rv-body">
            <div class="rv-body-title">후기 내용</div>
            <div class="rv-content">
              ${fn:escapeXml(review.rvCont)}
            </div>
          </div>
        </aside>

      </div>
    </div>
  </main>
</div>

<script>
(function(){
  const thumbs = Array.from(document.querySelectorAll('.rv-thumb'));
  const mainImg = document.getElementById('rvMainImg');
  const countEl = document.getElementById('rvPhotoCount');
  const prevBtn = document.querySelector('.rv-prev');
  const nextBtn = document.querySelector('.rv-next');

  if(!mainImg || thumbs.length === 0) return;

  let cur = 0;
  const total = thumbs.length;

  function setActive(idx){
    cur = (idx + total) % total;
    const src = thumbs[cur].dataset.src;
    mainImg.src = src;

    thumbs.forEach(t => t.classList.remove('is-active'));
    thumbs[cur].classList.add('is-active');

    if(countEl) countEl.textContent = (cur + 1) + " / " + total;

    // 썸네일이 많을 때 현재 썸네일이 보이도록
    thumbs[cur].scrollIntoView({block:'nearest', inline:'nearest', behavior:'smooth'});
  }

  thumbs.forEach(t => {
    t.addEventListener('click', () => setActive(parseInt(t.dataset.idx, 10)));
  });

  if(prevBtn) prevBtn.addEventListener('click', () => setActive(cur - 1));
  if(nextBtn) nextBtn.addEventListener('click', () => setActive(cur + 1));
})();
</script>

	<%@ include file="/WEB-INF/views/common/authModal.jspf" %>

</body>
</html>
