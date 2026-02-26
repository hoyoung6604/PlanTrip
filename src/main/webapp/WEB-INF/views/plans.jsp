<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>내 일정 목록</title>
  <link rel="stylesheet" href="/css/header.css" />
  <script src="/js/theme.js"></script>
  <script defer src="/js/nav-wave.js"></script>
  <link rel="stylesheet" href="<c:url value='/css/plan.css'/>" />
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container">
  <div class="header">
    <div>
      <h2 class="title">내 일정 목록</h2>
      <p class="sub">저장한 일정들을 확인하고 상세로 들어갈 수 있어요.</p>
    </div>
    <div class="top-actions">
      <a class="btn primary" href="<c:url value='/plan'/>">+ 새 일정 만들기</a>
    </div>
  </div>


  <div class="panel">
    <c:if test="${empty plans}">
      <p class="sub">저장된 일정이 없습니다.</p>
    </c:if>

    <c:forEach var="p" items="${plans}">
      <div class="section">
        <div class="section-head">
          <div>
            <div class="section-title"><span class="step">#</span>${p.PTitle}</div>
            <div class="section-desc">${p.PStart} ~ ${p.PEnd}</div>

            <div class="section-desc">
              이동 수단: ${empty transportMap[p.PIdx] ? '-' : transportMap[p.PIdx]}
            </div>
            <div class="section-desc">
              여행 목적: ${empty goalsMap[p.PIdx] ? '-' : goalsMap[p.PIdx]}
            </div>
          </div>

          <div class="btns">
            <a class="btn" href="<c:url value='/plans/view'/>?pIdx=${p.PIdx}">상세보기</a>

            <!-- ✅ 삭제: 폼 submit 방식만 사용 -->
            <form method="post" action="<c:url value='/plans/delete'/>" style="display:inline;">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
              <input type="hidden" name="pIdx" value="${p.PIdx}" />
              <button type="submit" class="btn danger" onclick="return confirm('정말 삭제할까요?');">삭제</button>
            </form>
          </div>
        </div>
      </div>
    </c:forEach>

  </div>

  <p style="margin-top:14px;">
    <a href="<c:url value='/plan'/>">일정만들기로 돌아가기</a> |
    <a href="<c:url value='/'/>">홈으로</a>
  </p>
</div>

<script>
  (function(){
    const params = new URLSearchParams(location.search);
    const del = params.get("del");
    if(!del) return;

    if(del === "ok") alert("삭제 완료!");
    if(del === "fail") alert("삭제 실패! (콘솔 로그 확인)");

    // ✅ alert 뜬 뒤 URL에서 del 파라미터 제거 (새로고침해도 계속 안 뜨게)
    params.delete("del");
    const newQuery = params.toString();
    const newUrl = location.pathname + (newQuery ? ("?" + newQuery) : "");
    history.replaceState({}, "", newUrl);
  })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>

</body>
</html>