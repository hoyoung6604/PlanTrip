<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>PlanTrip | 회원가입</title>

  <link rel="stylesheet" href="/css/header.css" />

  
  <link rel="stylesheet" href="/css/ui-toast.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/nav-wave.js"></script>
  <script defer src="/js/pages/register-page.js"></script>

  <style>
    body{ margin:0; min-height:100vh; background: linear-gradient(180deg, rgba(17,24,39,.06), rgba(17,24,39,.02)); }
    [data-theme="dark"] body{ background: linear-gradient(180deg, rgba(0,0,0,.55), rgba(0,0,0,.25)); }
    .auth-page-fallback{
      position: fixed;
      top: 18px;
      left: 18px;
      z-index: 10001;
    }
    .auth-page-home{
      display:inline-flex;
      align-items:center;
      gap:8px;
      padding:10px 12px;
      border-radius:14px;
      background: rgba(255,255,255,.78);
      border: 1px solid rgba(15,23,42,.12);
      color: #0f172a;
      text-decoration:none;
      font-weight:800;
    }
    [data-theme="dark"] .auth-page-home{
      background: rgba(15,23,42,.6);
      border-color: rgba(255,255,255,.1);
      color: rgba(255,255,255,.92);
    }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
  <div class="auth-page-fallback">
    <a class="auth-page-home" href="/">← 홈으로</a>
  </div>

  <c:if test="${not empty error}">
    <div id="serverAuthError" style="display:none;"><c:out value="${error}" /></div>
  </c:if>

  <%@ include file="/WEB-INF/views/common/footer.jspf" %>

</body>
</html>
