<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>

<h1>여행지 목록</h1>

<form method="get" action="${pageContext.request.contextPath}/plan/spots">
  <input name="keyword" value="${keyword}" placeholder="여행지명 검색" />

  <select name="cat">
    <option value="">전체</option>
    <option value="CITY" ${cat == 'CITY' ? 'selected' : ''}>도시</option>
    <option value="TOUR" ${cat == 'TOUR' ? 'selected' : ''}>관광지</option>
    <option value="HOTEL" ${cat == 'HOTEL' ? 'selected' : ''}>숙소</option>
    <option value="FOOD" ${cat == 'FOOD' ? 'selected' : ''}>맛집</option>
  </select>

  <button type="submit">검색</button>
</form>

<hr/>

<j:if test="${spots.totalElements == 0}">
  <p>검색 결과가 없습니다.</p>
</j:if>

<div style="display:grid; grid-template-columns: repeat(4, 1fr); gap:16px;">
  <j:forEach var="s" items="${spots.content}">
    <a href="${pageContext.request.contextPath}/plan/spots/${s.id}"
       style="border:1px solid #ddd; padding:12px; text-decoration:none; color:inherit;">
      <div style="font-weight:700;">${s.name}</div>
      <div style="opacity:.7;">카테고리: ${s.catCode}</div>
      <div style="opacity:.7;">주소: ${s.addr}</div>

      <j:if test="${not empty s.stats}">
        <div style="margin-top:8px; font-size:12px; opacity:.8;">
          조회수 ${s.stats.viewCount} · 찜 ${s.stats.wishCount} · 평점 ${s.stats.ratingAvg} (${s.stats.ratingCount})
        </div>
      </j:if>
    </a>
  </j:forEach>
</div>

<div style="margin-top:16px;">
  <j:if test="${spots.hasPrevious()}">
    <a href="?page=${spots.number-1}&keyword=${keyword}&cat=${cat}">이전</a>
  </j:if>

  <span style="margin:0 12px;">${spots.number + 1} / ${spots.totalPages}</span>

  <j:if test="${spots.hasNext()}">
    <a href="?page=${spots.number+1}&keyword=${keyword}&cat=${cat}">다음</a>
  </j:if>
</div>
