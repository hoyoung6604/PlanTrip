<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>후기 작성</title>
  
  <link rel="stylesheet" href="/css/theme-sky.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/community.css">
    <link rel="stylesheet" href="/css/auth-modal.css" />
    <link rel="stylesheet" href="/css/ui-toast.css" />
	
	<script defer src="/js/ui-toast.js"></script>
	  <script defer src="/js/theme.js"></script>
	  <script defer src="/js/auth-modal.js"></script>
	  <script defer src="/js/auth-guard.js"></script>

</head>
<body>

<div class="cm-shell">

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
              <path d="M4 6h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 18h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          여행 후기 목록
        </a>

        <a class="active" href="${pageContext.request.contextPath}/community/write">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M12 5v14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M5 12h14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          후기 작성
        </a>

        <a href="${pageContext.request.contextPath}/community/my-reviews">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 7h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 17h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          내 여행 후기
        </a>
      </nav>
    </div>

    <div class="sec sec-bottom">
      <div class="sec-title">SETTINGS</div>
      <nav class="mp-nav">
        <a href="${pageContext.request.contextPath}/members/mypage">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 13h7V4H4v9Zm9 7h7V11h-7v9ZM4 20h7v-5H4v5Zm9-16v5h7V4h-7Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          마이페이지로
        </a>

        <button class="menu-btn" type="button"
                onclick="location.href='${pageContext.request.contextPath}/'">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M3 10.5 12 3l9 7.5V21a2 2 0 0 1-2 2h-4v-7H9v7H5a2 2 0 0 1-2-2V10.5Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          메인으로
        </button>
      </nav>
    </div>
  </aside>

  <main class="cm-main">
    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">후기 작성</div>
          <div class="mp-card-sub">여행에서 느낀 점을 공유해 보세요</div>
        </div>
      </div>

      <div class="mp-card-body">
        <form class="cm-form" action="${pageContext.request.contextPath}/community/write" method="post" enctype="multipart/form-data">
		  <div class="cm-field">
		    <label>장소</label>
		    <c:choose>
		      <%-- ✅ spots 상세에서 넘어온 경우: 장소 고정(숨김값 + 표시용 readonly) --%>
		      <c:when test="${not empty selectedSpot}">
		        <input type="hidden" name="sIdx" value="${selectedSpot.id}" />
		        <input type="text" value="${selectedSpot.name}" readonly
		               style="width:100%; padding:12px 14px; border-radius:12px; border:1px solid rgba(148,163,184,.35); background:rgba(148,163,184,.10);" />
		        <div class="cm-hint" style="margin-top:6px; font-size:12px; opacity:.7;">선택된 장소로 후기가 등록됩니다.</div>
		      </c:when>
		      <%-- ✅ 일반 작성: (기존) 하드코딩 목록 유지 --%>
		      <c:otherwise>
		        <select name="sIdx" required>
		          <option value="">장소 선택</option>
		          <option value="1">제주도</option>
		          <option value="2">부산</option>
		          <option value="3">수원</option>
		          <option value="4">경주</option>
		        </select>
		      </c:otherwise>
		    </c:choose>
		  </div>

		  
          <div class="cm-field">
            <label>별점</label>
            <select name="rvStar" required>
              <option value="5">★★★★★</option>
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
            <textarea name="rvCont" placeholder="여기에 후기를 작성하세요" required></textarea>
          </div>

          <!-- ✅ 사진 첨부(선택) : 여러 장 업로드 가능 -->
          <div class="cm-field">
            <label>사진 첨부</label>
            <input type="file" name="photos" accept="image/*" multiple />
            <div class="cm-hint" style="margin-top:6px; font-size:12px; opacity:.7;">
              사진은 선택 사항입니다. 여러 장 첨부할 수 있어요.
            </div>
          </div>

          <div class="cm-actions">
            <button class="cm-primary" type="submit">등록</button>
            <button class="cm-ghost" type="button" onclick="location.href='${pageContext.request.contextPath}/community'">취소</button>
          </div>

        </form>
      </div>
    </section>
  </main>

</div>
<%@ include file="/WEB-INF/views/common/authModal.jspf" %>
</body>
</html>
