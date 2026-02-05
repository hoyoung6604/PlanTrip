<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.springframework.context.ApplicationContext" %>
<%@ page import="com.exam.literaryplanner.repository.LiteraryRepository" %>
<%@ page import="com.exam.literaryplanner.domain.Member" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>후기 상세</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/community.css">
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
	  
  <main class="cm-main">
    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title"><c:out value="${review.rvTitle}"/></div>

          <div class="mp-card-sub">
            별점:
            <c:forEach begin="1" end="${review.rvStar}">⭐</c:forEach>

			<%
			  ApplicationContext ctx = WebApplicationContextUtils.getWebApplicationContext(application);
			  LiteraryRepository memberRepo = ctx.getBean(LiteraryRepository.class);

			  com.exam.literaryplanner.domain.Review rv =
			      (com.exam.literaryplanner.domain.Review) request.getAttribute("review");

			  Long mIdx = (rv != null ? rv.getMIdx() : null);

			  String authorName = "알 수 없음";
			  if (mIdx != null) {
			      Member m = memberRepo.findById(mIdx).orElse(null);
			      if (m != null) authorName = m.getMName();
			      else authorName = "탈퇴한 사용자";
			  }

			  request.setAttribute("authorName", authorName);
			%>

			작성자: <c:out value="${authorName}"/>

            &nbsp;|&nbsp; 장소:
            <c:choose>
              <c:when test="${review.SIdx == 1}">제주도</c:when>
              <c:when test="${review.SIdx == 2}">부산</c:when>
              <c:when test="${review.SIdx == 3}">수원</c:when>
              <c:when test="${review.SIdx == 4}">경주</c:when>
              <c:otherwise>알 수 없음</c:otherwise>
            </c:choose>
          </div>
        </div>

        <button class="mp-btn" type="button"
                onclick="location.href='${pageContext.request.contextPath}/community'">
          목록
        </button>
      </div>

      <div class="mp-card-body">
        <div style="white-space:pre-wrap; line-height:1.7;">
          <c:out value="${review.rvCont}"/>
        </div>

        <!-- 본인 글일 때만 수정/삭제 -->
        <div style="margin-top:14px;">
          <c:if test="${not empty sessionScope.loginMember and sessionScope.loginMember.MIdx == review.MIdx}">
            <button class="cm-linkbtn" type="button"
                    onclick="location.href='${pageContext.request.contextPath}/community/edit?rvIdx=${review.rvIdx}'">
              수정
            </button>
            <span style="opacity:.5;"> | </span>
            <form action="${pageContext.request.contextPath}/community/delete" method="post" style="display:inline;">
              <input type="hidden" name="rvIdx" value="${review.rvIdx}">
              <button type="submit" class="cm-linkbtn">삭제</button>
            </form>
          </c:if>
        </div>

      </div>
    </section>
  </main>
</div>

</body>
</html>
