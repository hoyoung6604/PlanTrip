<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>

<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>회원 관리 | PlanTrip</title>

  <link rel="stylesheet" href="/css/admin-console.css" />
  <link rel="stylesheet" href="/css/admin-components.css" />

  <script defer src="/js/theme.js"></script>
  <script defer src="/js/auth-guard.js"></script>
</head>

<body class="admin-page">

<div class="admin-shell">
  <%@ include file="/WEB-INF/views/admin/admin_sidebar.jspf" %>

  <main class="admin-main">
    <div class="admin-topbar">
      <div>
        <h1 class="admin-title">회원 관리</h1>
        <p class="admin-subtitle">가입한 회원을 조회하고 검색할 수 있어요.</p>
      </div>
      <div class="admin-actions">
        <span class="admin-userchip">
          <c:choose>
            <c:when test="${not empty sessionScope.loginMember}">
              ${sessionScope.loginMember.MName}님 (ADMIN)
            </c:when>
            <c:otherwise>
              ADMIN
            </c:otherwise>
          </c:choose>
        </span>
        <%-- <button type="button" class="theme-toggle theme-toggle--pill" id="themeToggle" aria-label="테마 전환">
          <span class="tt-icon" aria-hidden="true">☀️</span>
          <span class="tt-icon" aria-hidden="true">🌙</span>
          <span class="tt-indicator" aria-hidden="true"></span>
        </button> --%>
      </div>
    </div>

    <div class="admin-pagewrap">
      <section class="admin-card padded">
        <div class="admin-row is-between">
          <div style="font-weight:1000;">회원 목록</div>
          <div class="admin-userchip">총 ${members.size()}명</div>
        </div>

        <form class="admin-row" method="get" action="${pageContext.request.contextPath}/admin/members" style="margin-top:12px;">
          <input class="admin-input" type="text" name="kw" value="${kw}" placeholder="아이디/이름/이메일로 검색" style="flex:1; min-width: 240px;" />
          <button class="admin-btn is-primary" type="submit">검색</button>
        </form>

        <div class="admin-tablewrap" style="margin-top:14px;">
          <table class="admin-table">
            <thead>
              <tr>
                <th style="width:90px;">번호</th>
                <th style="width:160px;">아이디</th>
                <th style="width:140px;">이름</th>
                <th>이메일</th>
                <th style="width:120px;">권한</th>
                <th style="width:200px;">가입일</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="u" items="${members}">
                <tr>
                  <td>${u.MIdx}</td>
                  <td>${u.MId}</td>
                  <td>${u.MName}</td>
                  <td>${u.MEmail}</td>
                  <td>
                    <span class="admin-status ${u.MRole eq 9 ? 'is-done' : ''}">
                      <c:choose>
                        <c:when test="${u.MRole eq 9}">ADMIN</c:when>
                        <c:otherwise>USER</c:otherwise>
                      </c:choose>
                    </span>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${empty u.MRegDate}">-</c:when>
                      <c:otherwise>${fn:substring(u.MRegDate,0,10)}</c:otherwise>
                    </c:choose>
                  </td>
                </tr>
              </c:forEach>

              <c:if test="${empty members}">
                <tr>
                  <td colspan="6" class="admin-empty">표시할 회원이 없습니다.</td>
                </tr>
              </c:if>
            </tbody>
          </table>
        </div>
      </section>
    </div>
  </main>
</div>

</body>
</html>
