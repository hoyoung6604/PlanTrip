<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>내 여행 계획</title>
  
  <link rel="stylesheet" href="/css/header.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
  <link rel="stylesheet" href="/css/redesign.css" />
  <link rel="stylesheet" href="/css/auth-modal.css" />
  <link rel="stylesheet" href="/css/ui-toast.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/auth-modal.js"></script>
  <script defer src="/js/auth-guard.js"></script>
  <script defer src="/js/nav-wave.js"></script>
</head>
<body class="page-solid">

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="mp-shell">
  <aside class="mp-side">
    <nav class="mp-nav">
      <a href="${pageContext.request.contextPath}/members/mypage">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M4 13h7V4H4v9Zm9 7h7V11h-7v9ZM4 20h7v-5H4v5Zm9-16v5h7V4h-7Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg></span>대시보드
      </a>
      <a href="${pageContext.request.contextPath}/members/mypage/check">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M12 20h9" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4 11.5-11.5Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg></span>회원정보 수정
      </a>
      <a class="active" href="${pageContext.request.contextPath}/members/mypage/plans">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M7 3v3M17 3v3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M4 8h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M5 6h14a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg></span>내 여행 계획
      </a>
      <a href="${pageContext.request.contextPath}/members/mypage/reviews">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M7 3h8l4 4v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M15 3v5h5" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M8 13h8M8 17h8" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg></span>내 여행 후기
      </a>
      <a href="${pageContext.request.contextPath}/members/mypage/wishlist">
        <span class="mp-ico" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none"><path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" stroke-linecap="round"/></svg></span>내 찜 목록
      </a>
    </nav>
  </aside>

  <main class="mp-main">
    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">내 여행 계획</div>
          <div class="mp-card-sub">작성한 계획 목록</div>
        </div>
        <button class="mp-btn" type="button" onclick="location.href='${pageContext.request.contextPath}/plans/planRoute'">새 계획</button>
      </div>

	  <div class="mp-card-body">
		<table class="data-table">
		  <thead>
		    <tr>
		      <th style="width:80px;">번호</th>
		      <th>제목</th>
		      <th style="width:140px;">작성일</th>
		      <th style="width:140px;">관리</th>
		    </tr>
		  </thead>
		  <tbody>
		    <c:choose>
		      <c:when test="${empty plans}">
		        <tr>
		          <td colspan="4" style="text-align: center; color: #999;">등록된 여행 계획이 없습니다.</td>
		        </tr>
		      </c:when>
		      <c:otherwise>
		        <c:forEach var="plan" items="${plans}">
		          <tr>
		            <td><c:out value="${plan.no}"/></td>
		            <td>
		              <a href="${pageContext.request.contextPath}/members/mypage/plans/view?pIdx=${plan.pIdx}">
		                <c:out value="${plan.title}"/>
		              </a>
		            </td>
		            <td><c:out value="${plan.regDate}"/></td>
		            <td>
		              <button type="button" class="mp-pill"
		                onclick="if(confirm('삭제하시겠습니까?')) location.href='${pageContext.request.contextPath}/members/mypage/plans/delete?pIdx=${plan.pIdx}'">
		                삭제
		              </button>
		            </td>
		          </tr>
		        </c:forEach>
		      </c:otherwise>
		    </c:choose>
		  </tbody>
		</table>
	  </div>
    </section>
  </main>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
<%@ include file="/WEB-INF/views/common/authModal.jspf" %>

</body>
</html>