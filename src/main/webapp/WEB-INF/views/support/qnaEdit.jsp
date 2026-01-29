<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>문의 수정 | 고객센터</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0;">
  <div style="display:flex; align-items:flex-end; justify-content:space-between; gap:12px; margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:24px;">고객센터</h1>
      <p style="margin:6px 0 0; color:#6b7280;">문의 수정</p>
    </div>
    <a class="btn solid" href="/" style="white-space:nowrap;">홈으로</a>
  </div>

  <c:if test="${not empty msg}">
    <div style="padding:10px 12px; border:1px solid #e5e7eb; border-radius:10px; background:#fff; margin-bottom:14px;">
      ${msg}
    </div>
  </c:if>

  <div style="display:flex; gap:18px;">
    <!-- 좌측 메뉴 -->
    <aside style="width:240px;">
      <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:14px;">
        <div style="font-weight:700; margin-bottom:10px;">라이브러리</div>

        <div style="display:flex; flex-direction:column; gap:10px;">
          <a class="btn" href="${pageContext.request.contextPath}/support/notice"
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">📢 공지사항</a>
          <a class="btn" href="${pageContext.request.contextPath}/support/faq"
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">❓ 자주 묻는 질문</a>
          <a class="btn solid" href="${pageContext.request.contextPath}/support/qna"
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">✍️ 문의하기</a>
        </div>
      </div>
    </aside>

    <!-- 우측 -->
    <main style="flex:1; min-width:0;">
      <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:16px;">
        <div style="display:flex; align-items:center; justify-content:space-between; gap:10px; flex-wrap:wrap;">
          <div>
            <div style="font-weight:900; font-size:16px;">문의 수정</div>
            <div style="margin-top:6px; color:#6b7280; font-size:13px;">
              문의번호 #${qna['qIdx']} · 상태 ${qna['qStatusLabel']}
            </div>
          </div>
          <div style="display:flex; gap:10px; flex-wrap:wrap;">
            <a class="btn" href="${pageContext.request.contextPath}/support/qna/${qna['qIdx']}">상세로</a>
            <a class="btn" href="${pageContext.request.contextPath}/support/qna">목록</a>
          </div>
        </div>

        <form action="${pageContext.request.contextPath}/support/qna/${qna['qIdx']}/edit"
              method="post"
              style="margin-top:14px; display:flex; flex-direction:column; gap:10px;">

          <label style="font-weight:700; font-size:13px;">제목</label>
          <input type="text" name="qTitle" maxlength="200" required
                 value="${qna['qTitle']}"
                 style="width:100%; padding:10px 12px; border:1px solid #e5e7eb; border-radius:12px; outline:none;" />

          <label style="font-weight:700; font-size:13px; margin-top:6px;">내용</label>
          <textarea name="qCont" rows="10" required
                    style="width:100%; padding:10px 12px; border:1px solid #e5e7eb; border-radius:12px; outline:none; resize:vertical;">${qna['qCont']}</textarea>

          <div style="display:flex; gap:10px; margin-top:6px; flex-wrap:wrap;">
            <button type="submit" class="btn solid" style="border:0; cursor:pointer;">수정 저장</button>
            <a class="btn" href="${pageContext.request.contextPath}/support/qna/${qna['qIdx']}">취소</a>
          </div>

          <div style="margin-top:6px; color:#6b7280; font-size:12px;">
            * 답변이 완료된 문의는 정책에 따라 수정이 제한될 수 있습니다.
          </div>
        </form>
      </div>
    </main>
  </div>
</div>

</body>
</html>
