<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>PlanTrip | 로그인</title>

  <link rel="stylesheet" href="/css/header.css" />

  
  <link rel="stylesheet" href="/css/ui-toast.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/pages/login-page.js"></script>
  <script defer src="/js/nav-wave.js"></script>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

  <div style="position:fixed; top:16px; left:16px; z-index:10001;">
    <a href="/" style="padding:10px 12px; border-radius:12px; background:rgba(0,0,0,.04); text-decoration:none; color:inherit; font-weight:800;">홈으로</a>
  </div>

  <div id="serverAuthError" style="display:none;">
    <c:out value="${error}" />
  </div>

  <%@ include file="/WEB-INF/views/common/footer.jspf" %>


</body>
</html>
