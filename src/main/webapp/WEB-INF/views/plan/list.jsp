<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>여행지 목록</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0;">
  <div style="display:flex; align-items:flex-end; justify-content:space-between; gap:12px; margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:24px;">여행지 목록</h1>
      <p style="margin:6px 0 0; color:#6b7280;">
        <j:if test="${not empty cat}">카테고리: ${cat}</j:if>
      </p>
    </div>
    <a class="btn" href="/" style="white-space:nowrap;">홈으로</a>
  </div>

  <!-- 검색바(선택) -->
  <form method="get" action="${pageContext.request.contextPath}/spots"
        style="display:flex; gap:8px; margin-bottom:14px; flex-wrap:wrap;">
    <input type="hidden" name="cat" value="${cat}"/>
    <input class="input" name="keyword" value="${keyword}" placeholder="장소명 검색" />
    <button class="btn solid" type="submit">검색</button>
  </form>

  <j:if test="${empty spots}">
    <div style="padding:14px; border:1px dashed #e5e7eb; border-radius:12px; color:#6b7280;">
      등록된 여행지가 없습니다.
    </div>
  </j:if>

  <j:if test="${not empty spots}">
    <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(240px, 1fr)); gap:14px;">
      <j:forEach var="s" items="${spots}">
        <a class="post-card" href="${pageContext.request.contextPath}/spot/${s.id}">
          <div class="post-body">
            <div class="post-title">${s.name}</div>
            <div class="post-meta">
              <j:if test="${not empty s.city}">${s.city.name}</j:if>
              <j:if test="${not empty s.addr}"> · ${s.addr}</j:if>
            </div>
            <div class="post-tags" style="margin-top:8px;">
              <span class="tag">#${s.catCode}</span>
            </div>
          </div>
        </a>
      </j:forEach>
    </div>

    <!-- 페이징 -->
    <div style="display:flex; justify-content:center; gap:8px; margin-top:18px; flex-wrap:wrap;">
      <j:if test="${page.number > 0}">
        <a class="btn" href="${pageContext.request.contextPath}/spots?cat=${cat}&keyword=${keyword}&cityId=${cityId}&page=${page.number-1}&size=${page.size}">이전</a>
      </j:if>

      <span style="align-self:center; color:#6b7280;">
        ${page.number+1} / ${page.totalPages}
      </span>

      <j:if test="${page.number + 1 < page.totalPages}">
        <a class="btn" href="${pageContext.request.contextPath}/spots?cat=${cat}&keyword=${keyword}&cityId=${cityId}&page=${page.number+1}&size=${page.size}">다음</a>
      </j:if>
    </div>
  </j:if>
</div>

</body>
</html>
