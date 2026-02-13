<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>커뮤니티</title>
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

	<!-- 좌측 사이드바는 마이페이지와 동일한 구조로 유지 -->
	 <aside class="mp-side">
	   <div class="mp-brand">
	     <div class="mp-logo"></div>
	     <div class="mp-brand-name">Community</div>
	   </div>

	   <div class="sec">
	     <div class="sec-title">MENU</div>
	     <nav class="mp-nav">
	       <a class="active" href="${pageContext.request.contextPath}/community">
	         <span class="mp-ico" aria-hidden="true">
	           <svg viewBox="0 0 24 24" fill="none">
	             <path d="M4 6h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
	             <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
	             <path d="M4 18h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
	           </svg>
	         </span>
	         여행 후기 목록
	       </a>

	       <a href="${pageContext.request.contextPath}/community/write">
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

  <!-- 가운데 콘텐츠 -->
  <main class="cm-main">

    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">여행 후기 목록</div>
          <div class="mp-card-sub">모든 사용자의 후기를 확인할 수 있어요</div>
        </div>
        <button class="mp-btn" type="button"
                onclick="location.href='${pageContext.request.contextPath}/community/write'">
          새 후기
        </button>
      </div>

      <div class="mp-card-body">

        <!-- 검색/필터는 컨트롤러 파라미터 이름과 동일하게 맞춤 -->
        <form action="${pageContext.request.contextPath}/community" method="get" style="margin-bottom:12px;">
          <div class="mp-search" style="margin-bottom:10px;">
			<span class="sico" aria-hidden="true">
			  <svg viewBox="0 0 24 24" fill="none">
			    <path d="M10.5 18a7.5 7.5 0 1 1 0-15 7.5 7.5 0 0 1 0 15Z" stroke="currentColor" stroke-width="1.8"/>
			    <path d="M16.5 16.5 21 21" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
			  </svg>
			</span>

            <input type="text" name="keyword" value="${keyword}" placeholder="작성자 또는 제목으로 검색">
            <button class="mp-btn" type="submit" style="padding:10px 14px;">검색</button>
          </div>

          <div class="cm-filters">
            <select class="cm-select" name="minStar">
              <option value="">최소 별점</option>
              <option value="5" <c:if test="${minStar == 5}">selected</c:if>>5점</option>
              <option value="4" <c:if test="${minStar == 4}">selected</c:if>>4점 이상</option>
              <option value="3" <c:if test="${minStar == 3}">selected</c:if>>3점 이상</option>
              <option value="2" <c:if test="${minStar == 2}">selected</c:if>>2점 이상</option>
              <option value="1" <c:if test="${minStar == 1}">selected</c:if>>1점 이상</option>
            </select>

        <!--<select class="cm-select" name="sIdx">
              <option value="">카테고리</option>
              <option value="1" <c:if test="${sIdx == 1}">selected</c:if>>국내여행</option>
              <option value="2" <c:if test="${sIdx == 2}">selected</c:if>>해외여행</option>
            </select>-->

            <select class="cm-select" name="sort">
              <option value="latest" <c:if test="${sort == 'latest'}">selected</c:if>>최신순</option>
              <option value="star" <c:if test="${sort == 'star'}">selected</c:if>>별점순</option>
            </select>

            <button class="mp-btn" type="submit" style="padding:10px 14px;">적용</button>
          </div>
        </form>

        <!-- 목록 -->
        <c:choose>
          <c:when test="${empty reviews}">
            <div class="cm-empty">
              아직 등록된 후기가 없습니다.
              <div class="sub">첫 번째 후기를 작성해 보세요.</div>
            </div>
          </c:when>

          <c:otherwise>
            <div class="cm-table-wrap">
              <table class="cm-table">
                <thead>
                  <tr>
                    <th style="width:90px;">번호</th>
                    <th style="width:160px;">작성자</th>
                    <th style="width:120px;">별점</th>
                    <th>제목</th>
                    <th style="width:140px;">관리</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="r" items="${reviews}">
                    <tr>
                      <td>${r.rvIdx}</td>
                      <td>${r.MIdx}</td>
                      <td>
                        <span class="cm-stars">
                          <c:forEach begin="1" end="${r.rvStar}">⭐</c:forEach>
                        </span>
                      </td>
					  <td style="white-space:normal;">
					    <a href="${pageContext.request.contextPath}/community/view?rvIdx=${r.rvIdx}">
					      <c:out value="${r.rvTitle}"/>
					    </a>
					  </td>

                      <!-- 본인 글일 때만 수정/삭제 노출 -->
                      <td>
                        <c:choose>
							<c:when test="${not empty sessionScope.loginMember and sessionScope.loginMember.MIdx == r.MIdx}">
                            <a href="${pageContext.request.contextPath}/community/edit?rvIdx=${r.rvIdx}">
                              <button class="cm-linkbtn" type="button">수정</button>
                            </a>
                            <span style="opacity:.5;"> | </span>
                            <form action="${pageContext.request.contextPath}/community/delete" method="post" style="display:inline;">
                              <input type="hidden" name="rvIdx" value="${r.rvIdx}">
                              <button type="submit" class="cm-linkbtn">삭제</button>
                            </form>
                          </c:when>
                          <c:otherwise>
                            <span style="color:rgba(255,255,255,.55);">-</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </c:otherwise>
        </c:choose>

      </div>
    </section>

  </main>

</div>
<%@ include file="/WEB-INF/views/common/authModal.jspf" %>
</body>
</html>
