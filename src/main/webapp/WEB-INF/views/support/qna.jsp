<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>문의하기 | 고객센터</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0;">
  <div style="display:flex; align-items:flex-end; justify-content:space-between; gap:12px; margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:24px;">고객센터</h1>
      <p style="margin:6px 0 0; color:#6b7280;">내 문의사항</p>
    </div>
    <a class="btn solid" href="/" style="white-space:nowrap;">홈으로</a>
  </div>

  <div style="display:flex; gap:18px;">
    <!-- 좌측 메뉴 -->
    <aside style="width:240px;">
      <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:14px;">
        <div style="font-weight:700; margin-bottom:10px;">라이브러리</div>

        <div style="display:flex; flex-direction:column; gap:10px;">
          <a class="btn" href="${pageContext.request.contextPath}/support/notice"
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
            📢 공지사항
          </a>

          <a class="btn" href="${pageContext.request.contextPath}/support/faq"
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
            ❓ 자주 묻는 질문
          </a>

          <a class="btn solid" href="${pageContext.request.contextPath}/support/qna"
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
            ✍️ 문의하기
          </a>
        </div>
      </div>
    </aside>

    <!-- 우측 컨텐츠 -->
    <main style="flex:1; min-width:0;">
      <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:16px;">
        <div style="display:flex; align-items:center; justify-content:space-between; gap:10px;">
          <div style="font-weight:800; font-size:16px;">내 문의 목록</div>
          <a class="btn solid" href="${pageContext.request.contextPath}/support/qna/new" style="white-space:nowrap;">
            문의 작성
          </a>
        </div>

        <div style="margin-top:12px;">
          <table style="width:100%; border-collapse:collapse;">
            <thead>
            <tr style="text-align:left; color:#6b7280; font-size:12px;">
              <th style="padding:10px 6px; width:100px;">상태</th>
              <th style="padding:10px 6px;">제목</th>
              <th style="padding:10px 6px; width:180px;">작성일</th>
            </tr>
            </thead>
            <tbody>

            <c:if test="${empty qnaList}">
              <tr>
                <td colspan="3" style="padding:14px 6px; color:#6b7280; border-top:1px solid #f1f5f9;">
                  등록된 문의가 없습니다.
                </td>
              </tr>
            </c:if>

            <c:forEach var="q" items="${qnaList}">
              <tr style="border-top:1px solid #f1f5f9;">
                <td style="padding:10px 6px;">
                  <c:choose>
                    <c:when test="${q.qStatus eq 0}">
                      <span style="display:inline-block; padding:4px 8px; border-radius:999px; border:1px solid #e5e7eb; font-size:12px;">대기</span>
                    </c:when>
                    <c:otherwise>
                      <span style="display:inline-block; padding:4px 8px; border-radius:999px; border:1px solid #e5e7eb; font-size:12px;">완료</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td style="padding:10px 6px; max-width:0;">
                  <!-- 상세 페이지를 이미 만들었다면 링크로 -->
                  <a href="${pageContext.request.contextPath}/support/qna/${q.qIdx}"
                     style="display:inline-block; max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                    ${q.qTitle}
                  </a>
                </td>
                <td style="padding:10px 6px; color:#6b7280;">${q.qRegDate}</td>
              </tr>
            </c:forEach>

            </tbody>
          </table>
        </div>

        <div style="margin-top:12px; color:#6b7280; font-size:12px;">
          * 문의 상세에서 관리자 답변을 확인할 수 있습니다.
        </div>

      </div>
    </main>
  </div>
</div>

</body>
</html>
