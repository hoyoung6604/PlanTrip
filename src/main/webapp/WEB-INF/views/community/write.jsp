<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>후기 작성</title>

  
    <link rel="stylesheet" href="/css/header.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/community.css">
<link rel="stylesheet" href="/css/redesign.css" />
  <link rel="stylesheet" href="/css/ui-toast.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/pages/community-write.js"></script>
    <script defer src="/js/nav-wave.js"></script>
</head>
<body class="page-solid">


    <jsp:include page="/WEB-INF/views/common/header.jsp" />
<div class="cm-shell">
<main class="cm-main">
    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">후기 작성</div>
          <div class="mp-card-sub">여행에서 느낀 점을 공유해 보세요</div>
        </div>
      </div>

      <div class="mp-card-body">
        <form class="cm-form"
              action="${pageContext.request.contextPath}/community/write"
              method="post"
              enctype="multipart/form-data">

          <div class="cm-field">
            <label>장소</label>

            <c:choose>
              <c:when test="${not empty selectedSpot}">
                <input type="hidden" name="sIdx" value="${selectedSpot.id}" />

                <input type="text" value="${selectedSpot.name}" readonly
                  style="width:100%; padding:12px 14px; border-radius:12px; border:1px solid rgba(148,163,184,.35); background:rgba(148,163,184,.10);" />

                <div class="cm-hint" style="margin-top:6px; font-size:12px; opacity:.7;">선택된 장소로 후기가 등록됩니다.</div>
              </c:when>

              <c:otherwise>
							<!-- ✅ 2단 선택(지역 -> 장소) : UI는 2열(A=지역, B=장소), 데이터는 기존 spotList 그대로 사용 -->
							<div class="cm-two-grid">
							  <div class="cm-two-item">
							    <div class="cm-two-label">지역</div>
							    <select id="cmRegion" required>
							      <option value="">지역 선택</option>
							    </select>
							  </div>
							  <div class="cm-two-item">
							    <div class="cm-two-label">장소</div>
							    <select id="cmSpot" name="sIdx" required>
							      <option value="">장소 선택</option>
							      <c:forEach var="s" items="${spotList}">
							        <option value="${s.id}" data-city="${empty s.city ? '' : s.city.name}"><c:out value="${s.name}"/></option>
							      </c:forEach>
							    </select>
							  </div>
							</div>

								<script>
								(function(){
								  const region = document.getElementById('cmRegion');
								  const spot = document.getElementById('cmSpot');
								  if(!region || !spot) return;
								  const all = Array.from(spot.querySelectorAll('option')).slice(1);
								  // 지역 옵션(중복 제거) 생성
								  const cities = Array.from(new Set(all.map(o=>o.dataset.city).filter(Boolean)));
								  cities.forEach(c=>{
								    const opt = document.createElement('option');
								    opt.value = c;
								    opt.textContent = c;
								    region.appendChild(opt);
								  });
								
								  function filter(){
								    const city = region.value;
								    spot.value = '';
								    all.forEach(o=>{
								      const ok = !city || o.dataset.city === city;
								      o.hidden = !ok;
								      o.disabled = !ok;
								    });
								  }
								  region.addEventListener('change', filter);
								  filter();
								})();
								</script>
              </c:otherwise>
            </c:choose>
          </div>

          <div class="cm-field">
            <label>별점</label>
            <!-- 기존 파라미터(rvStar)는 그대로 유지하고, Trip.com 스타일 UI로만 교체 작업 함 UI 확인 부탁-->
            <div class="rv-rating" data-max="5" aria-label="별점 선택">
              <button type="button" class="rv-star" data-value="1" aria-label="1점"></button>
              <button type="button" class="rv-star" data-value="2" aria-label="2점"></button>
              <button type="button" class="rv-star" data-value="3" aria-label="3점"></button>
              <button type="button" class="rv-star" data-value="4" aria-label="4점"></button>
              <button type="button" class="rv-star" data-value="5" aria-label="5점"></button>
              <span class="rv-rating-text" aria-live="polite"></span>
            </div>
            <select class="rvStarSelect" name="rvStar" required>
              <option value="5" selected>★★★★★</option>
              <option value="4">★★★★</option>
              <option value="3">★★★</option>
              <option value="2">★★</option>
              <option value="1">★</option>
            </select>
          </div>

          <div class="cm-field">
            <label>후기 제목</label>
            <input type="text" name="rvTitle" placeholder="후기 제목을 입력하세요" required />
          </div>

          <div class="cm-field">
            <label>후기 내용</label>
            
            <div class="rv-tip" role="note" aria-label="리뷰 작성 가이드">
              <span class="rv-tip-ico" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none">
                  <path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10Z" stroke="currentColor" stroke-width="1.8"/>
                  <path d="M8.5 10.25c.6-1.6 2.1-2.75 3.95-2.75 2.2 0 3.95 1.55 3.95 3.45 0 2.2-2.1 2.95-3.2 3.55-.7.4-1.2.8-1.2 1.55v.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                  <path d="M12 18.3h.01" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"/>
                </svg>
              </span>
              <div class="rv-tip-text">
                <div class="rv-tip-title">여행은 어떠셨어요?</div>
                <div class="rv-tip-sub">위치나 교통, 편의시설 등 다른 여행자에게 추천하는 나만의 여행 팁을 알려주세요!</div>
              </div>
            </div>
            <div class="rv-cont-wrap">
              <textarea id="rvCont" name="rvCont" placeholder="여기에 후기를 작성하세요" required maxlength="5000"></textarea>
              <!-- ✅ 실시간 글자수 카운팅 (우측 하단) -->
              <div class="rv-cont-counter" aria-live="polite">
                <span id="rvContCount">0</span>/<span id="rvContMax">5000</span>
              </div>
            </div>
          </div>

          <div class="cm-field">
            <label>사진 첨부 <span class="rv-optional">(선택)</span></label>
            <!-- input은 유지하고 UI만 커스텀(미리보기/개수 표시) -->
            <div class="rv-photo">
              <input id="photosInput" class="rv-photo-input" type="file" name="photos" accept="image/*" multiple data-max="10" />
              <div class="rv-photo-head">
                <div class="rv-photo-sub">여행 사진을 공유해보세요!</div>
              </div>
              <div class="rv-photo-grid" data-empty="true">
                <div class="rv-photo-add" role="button" tabindex="0" data-action="pick" aria-label="사진 추가">
                  <div class="rv-photo-add-ico" aria-hidden="true"></div>
                  <div class="rv-photo-count"><span data-count>0</span>/<span data-max>10</span></div>
                </div>
              </div>
              <div class="cm-hint rv-photo-hint">
                사진은 선택 사항입니다. 여러 장 첨부할 수 있어요 (최대 10장).
              </div>
            </div>
          </div>

          <!-- 이용약관/커뮤니티 규칙 동의 (UI 전용) -->
          <div class="rv-agree">
            <label class="rv-check" for="rvAgree">
              <input id="rvAgree" type="checkbox" />
              <span class="rv-check-box" aria-hidden="true"></span>
              <span class="rv-check-text">콘텐츠 업로드에 있어서, PlanTrip의 이용약관에 동의합니다</span>
            <div class="rv-links">
              <a href="#" target="_blank" rel="noopener">이용약관</a>
              <span class="rv-dot">&amp;</span>
              <a href="#" target="_blank" rel="noopener">커뮤니티 규칙</a>
            </div>
          </div>
            </label>

          <div class="cm-actions">
            <button class="rv-btn rv-btn-primary" type="submit">등록</button>
            <button class="rv-btn rv-btn-ghost" type="button"
                    onclick="location.href='${pageContext.request.contextPath}/community'">취소</button>
          </div>

        </form>
      </div>
    </section>
  </main>

</div>

<!-- 사진 라이트박스(모달 확대) : UI 전용, 로직 영향 없음 -->
<div class="rv-lightbox" aria-hidden="true">
  <div class="rv-lightbox-backdrop" data-action="close"></div>
  <div class="rv-lightbox-panel" role="dialog" aria-modal="true" aria-label="사진 미리보기">
    <button type="button" class="rv-lightbox-close" data-action="close" aria-label="닫기"></button>
    <img class="rv-lightbox-img" alt="" />
  </div>
</div>


<!-- 사진/별점 UI 동작은 /js/pages/community-write.js에서 처리 -->

<%@ include file="/WEB-INF/views/common/footer.jspf" %>

</body>
</html>