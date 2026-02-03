<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8"/>
<title>문의 상세 | 관리자</title>
<link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0; max-width:980px;">

  <div style="display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:14px;">
    <div>
      <h1 style="margin:0;font-size:22px;">문의 상세</h1>
      <p style="margin:6px 0 0;color:#6b7280;">
        상태: ${qna['qStatusLabel']} · 등록일: ${qna['qRegDate']}
      </p>
    </div>
    <a class="btn" href="${pageContext.request.contextPath}/admin/inquiries">목록</a>
  </div>

  <div style="background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:16px;">
    <div style="font-weight:800;font-size:18px;">${qna['qTitle']}</div>
    <div style="margin-top:8px;color:#6b7280;font-size:13px;">
      작성자: ${qna['mName']} (${qna['mId']})
    </div>
    <div style="margin-top:14px;white-space:pre-wrap;line-height:1.7;">
      ${qna['qCont']}
    </div>
  </div>

  <div style="background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:16px;margin-top:14px;">
    <div style="font-weight:800;">관리자 답변</div>
    <div style="margin-top:8px;color:#6b7280;font-size:13px;">저장하면 상태가 자동으로 완료로 바뀝니다.</div>

    <form action="${pageContext.request.contextPath}/admin/inquiries/${qna['qIdx']}/answer"
          method="post" style="margin-top:12px;">
      <textarea name="qAnswer"
                style="width:100%;min-height:220px;padding:12px;border-radius:10px;border:1px solid #e5e7eb;resize:vertical;"
                placeholder="답변을 입력하세요.">${qna['qAnswer']}</textarea>

      <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:12px;">
        <a class="btn" href="${pageContext.request.contextPath}/admin/inquiries">취소</a>
        <button class="btn solid" type="submit">답변 저장</button>
      </div>
    </form>
  </div>

</div>

</body>
</html>
