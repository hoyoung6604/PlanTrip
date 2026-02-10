<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>FAQ | 고객센터</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0;">
  <div style="display:flex; align-items:flex-end; justify-content:space-between; gap:12px; margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:24px;">고객센터</h1>
      <p style="margin:6px 0 0; color:#6b7280;">자주 묻는 질문</p>
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

          <a class="btn solid" href="${pageContext.request.contextPath}/support/faq"
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
        <div style="font-weight:800; font-size:16px;">자주 묻는 질문 (FAQ)</div>
        <div style="margin-top:6px; color:#6b7280;">질문을 클릭하면 답변이 펼쳐집니다.</div>

        <div style="margin-top:12px; display:flex; flex-direction:column; gap:10px;">
          <c:if test="${empty faqList}">
            <div style="padding:14px; border:1px dashed #e5e7eb; border-radius:12px; color:#6b7280;">
              등록된 FAQ가 없습니다.
            </div>
          </c:if>

          <c:forEach var="f" items="${faqList}" varStatus="st">
            <details style="border:1px solid #e5e7eb; border-radius:12px; padding:10px 12px; background:#fff;">
              <summary style="cursor:pointer; font-weight:700; list-style:none;">
                <span style="display:flex; align-items:center; gap:8px;">
                  <span style="flex:1; min-width:0;">
                    Q${st.count}. ${f.getBTitle()}
                  </span>

                  <!-- TOP 표시 -->
                  <c:if test="${f.getBIsTop() == 1}">
                    <span style="display:inline-block; padding:2px 8px; border-radius:999px; border:1px solid #e5e7eb; font-size:12px; color:#111;">
                      TOP
                    </span>
                  </c:if>
                </span>

                <!-- 등록일(작게) -->
                <div style="margin-top:6px; font-weight:400; font-size:12px; color:#6b7280;">
                  ${f.getBRegDate()}
                </div>
              </summary>

              <div style="margin-top:10px; color:#374151; white-space:pre-wrap; line-height:1.6;">
                ${f.getBCont()}
              </div>
            </details>
          </c:forEach>
        </div>

      </div>
    </main>
  </div>
</div>

</body>
</html>

