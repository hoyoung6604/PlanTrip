<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>문의 작성 | 고객센터</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0; max-width:900px;">
  <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:22px;">문의 작성</h1>
      <p style="margin:6px 0 0; color:#6b7280;">문의 내용을 작성해주세요.</p>
    </div>
    <a class="btn" href="${pageContext.request.contextPath}/support/qna">목록으로</a>
  </div>

  <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:16px;">
    <form action="${pageContext.request.contextPath}/support/qna" method="post">
      <div style="font-weight:700; margin-bottom:6px;">제목</div>
      <input name="qTitle" type="text" required maxlength="200"
             style="width:100%;padding:12px;border-radius:10px;border:1px solid #e5e7eb;">

      <div style="font-weight:700; margin:14px 0 6px;">내용</div>
      <textarea name="qCont" required
                style="width:100%;min-height:240px;padding:12px;border-radius:10px;border:1px solid #e5e7eb;resize:vertical;"></textarea>

      <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:14px;">
        <a class="btn" href="${pageContext.request.contextPath}/support/qna">취소</a>
        <button class="btn solid" type="submit">등록</button>
      </div>
    </form>
  </div>
</div>

</body>
</html>
