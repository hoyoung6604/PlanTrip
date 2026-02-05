<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>공지사항 | 고객센터</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0;">
  <div style="display:flex; align-items:flex-end; justify-content:space-between; gap:12px; margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:24px;">고객센터</h1>
      <p style="margin:6px 0 0; color:#6b7280;">공지사항</p>
    </div>
    <a class="btn solid" href="/" style="white-space:nowrap;">홈으로</a>
  </div>

  <div style="display:flex; gap:18px;">
    <!-- 좌측 메뉴 -->
    <aside style="width:240px;">
      <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:14px;">
        <div style="font-weight:700; margin-bottom:10px;">라이브러리</div>

        <div style="display:flex; flex-direction:column; gap:10px;">
          <a class="btn solid" href="${pageContext.request.contextPath}/support/notice"
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
            📢 공지사항
          </a>

          <a class="btn" href="${pageContext.request.contextPath}/support/faq"
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
            ❓ 자주 묻는 질문
          </a>

          <c:choose>
            <c:when test="${not empty sessionScope.loginMember}">
              <a class="btn" href="${pageContext.request.contextPath}/support/qna"
                 style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
                ✍️ 문의하기
              </a>
            </c:when>
            <c:otherwise>
              <a class="btn" href="${pageContext.request.contextPath}/members/login"
                 onclick="alert('로그인 후 문의하기가 가능합니다.');"
                 style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
                ✍️ 문의하기
              </a>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </aside>

    <!-- 우측 컨텐츠 -->
    <main style="flex:1; min-width:0;">
      <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:16px;">
        <div style="display:flex; align-items:center; justify-content:space-between; gap:10px;">
          <div style="font-weight:800; font-size:16px;">공지사항</div>
          <!-- 관리자 글쓰기 버튼을 나중에 여기 붙이면 됨 -->
        </div>

        <div style="margin-top:12px;">
          <table style="width:100%; border-collapse:collapse;">
            <thead>
            <tr style="text-align:left; color:#6b7280; font-size:12px;">
              <th style="padding:10px 6px; width:90px;">고정</th>
              <th style="padding:10px 6px;">제목</th>
              <th style="padding:10px 6px; width:180px;">등록일</th>
            </tr>
            </thead>
            <tbody>
            <c:if test="${empty noticeList}">
              <tr>
                <td colspan="3" style="padding:14px 6px; color:#6b7280; border-top:1px solid #f1f5f9;">
                  등록된 공지사항이 없습니다.
                </td>
              </tr>
            </c:if>

            <c:forEach var="n" items="${noticeList}">
              <tr style="border-top:1px solid #f1f5f9;">
                <td style="padding:10px 6px;">
                  <c:if test="${n.bIsTop == 1}">
                    <span style="display:inline-block; padding:4px 8px; border-radius:999px; border:1px solid #e5e7eb; font-size:12px;">TOP</span>
                  </c:if>
                </td>
                <td style="padding:10px 6px; max-width:0;">
                  <!-- 상세 페이지 만들면 링크로 교체 -->
                  <span style="display:inline-block; max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                    ${n.bTitle}
                  </span>
                </td>
                <td style="padding:10px 6px; color:#6b7280;">${n.bRegDate}</td>
              </tr>
            </c:forEach>
            </tbody>
          </table>
        </div>

      </div>
    </main>
  </div>
</div>

</body>
</html>
