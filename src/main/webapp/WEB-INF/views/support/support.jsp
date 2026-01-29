<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>고객센터</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0;">
  <div style="display:flex; align-items:flex-end; justify-content:space-between; gap:12px; margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:24px;">고객센터</h1>
      <p style="margin:6px 0 0; color:#6b7280;">공지사항/FAQ/문의하기를 이용할 수 있어요.</p>
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
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
            📢 공지사항
          </a>

          <a class="btn" href="${pageContext.request.contextPath}/support/faq"
             style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
            ❓ 자주 묻는 질문
          </a>

          <c:choose>
            <c:when test="${not empty sessionScope.loginMember}">
              <a class="btn solid" href="${pageContext.request.contextPath}/support/qna"
                 style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
                ✍️ 문의하기
              </a>
            </c:when>
            <c:otherwise>
              <a class="btn solid" href="${pageContext.request.contextPath}/members/login"
                 onclick="alert('로그인 후 문의하기가 가능합니다.');"
                 style="display:block; text-align:left; padding:10px 12px; border-radius:10px;">
                ✍️ 문의하기
              </a>
              <div style="margin-top:6px; color:#6b7280; font-size:12px;">
                * 문의 작성/조회는 로그인 후 이용 가능합니다.
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </aside>

    <!-- 우측 컨텐츠 -->
    <main style="flex:1; min-width:0;">
      <!-- 안내 카드 -->
      <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:16px; margin-bottom:14px;">
        <div style="font-weight:800; font-size:16px; margin-bottom:6px;">무엇을 도와드릴까요?</div>
        <div style="color:#6b7280; line-height:1.5;">
          빠른 답변은 <b>FAQ</b>에서 확인하고, 해결이 안 되면 <b>문의하기</b>로 남겨주세요.
        </div>

        <div style="display:flex; gap:10px; margin-top:12px; flex-wrap:wrap;">
          <a class="btn" href="${pageContext.request.contextPath}/support/faq">FAQ 바로가기</a>
          <a class="btn" href="${pageContext.request.contextPath}/support/notice">공지사항 보기</a>

          <c:choose>
            <c:when test="${not empty sessionScope.loginMember}">
              <a class="btn solid" href="${pageContext.request.contextPath}/support/qna/new">문의 작성</a>
              <a class="btn" href="${pageContext.request.contextPath}/support/qna">내 문의 목록</a>
            </c:when>
            <c:otherwise>
              <a class="btn solid" href="${pageContext.request.contextPath}/members/login"
                 onclick="alert('로그인 후 문의 작성이 가능합니다.');">문의 작성</a>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <!-- 로그인 상태일 때: 내 문의 미리보기 -->
      <c:if test="${not empty sessionScope.loginMember}">
        <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:16px;">
          <div style="display:flex; align-items:center; justify-content:space-between; gap:10px;">
            <div>
              <div style="font-weight:800; font-size:16px;">내 문의사항</div>
              <div style="color:#6b7280; font-size:13px; margin-top:4px;">
				<c:set var="displayName" value="사용자" />
				<c:if test="${not empty sessionScope.loginUserName}">
				  <c:set var="displayName" value="${sessionScope.loginUserName}" />
				</c:if>
				${displayName} 님의 최근 문의를 보여줍니다.
              </div>
            </div>
            <a class="btn" href="${pageContext.request.contextPath}/support/qna" style="white-space:nowrap;">
              전체 보기 →
            </a>
          </div>
          <div style="margin-top:12px;">
            <c:choose>
              <c:when test="${empty qnaPreview}">
                <div style="padding:14px; border:1px dashed #e5e7eb; border-radius:12px; color:#6b7280;">
                  아직 작성한 문의가 없습니다. “문의 작성”으로 첫 문의를 남겨보세요.
                </div>
              </c:when>
              <c:otherwise>
                <table border="0" cellpadding="0" cellspacing="0" style="width:100%; border-collapse:collapse;">
                  <thead>
                    <tr style="text-align:left; color:#6b7280; font-size:12px;">
                      <th style="padding:10px 6px; width:90px;">상태</th>
                      <th style="padding:10px 6px;">제목</th>
                      <th style="padding:10px 6px; width:180px;">작성일</th>
                    </tr>
                  </thead>
                  <tbody>
                    <!-- 최대 5개만 -->
					<c:forEach var="q" items="${qnaPreview}" varStatus="st">
					  <c:if test="${st.index lt 5}">
					    <tr style="border-top:1px solid #f1f5f9;">
					      <td style="padding:10px 6px;">
					        <span style="display:inline-block; padding:4px 8px; border-radius:999px; border:1px solid #e5e7eb; font-size:12px;">
					          ${q['qStatusLabel']}
					        </span>
					      </td>

					      <td style="padding:10px 6px; max-width:0;">
					        <a href="${pageContext.request.contextPath}/support/qna/${q['qIdx']}"
					           style="display:inline-block; max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
					          ${q['qTitle']}
					        </a>
					      </td>

					      <td style="padding:10px 6px; color:#6b7280;">
					        ${q['qRegDate']}
					      </td>
					    </tr>
					  </c:if>
					</c:forEach>
                  </tbody>
                </table>
                <div style="margin-top:12px;">
                  <a class="btn solid" href="${pageContext.request.contextPath}/support/qna/new">문의 작성</a>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </c:if>
      <!-- 비로그인 상태 안내 -->
      <c:if test="${empty sessionScope.loginMember}">
        <div style="border:1px solid #e5e7eb; border-radius:14px; background:#fff; padding:16px;">
          <div style="font-weight:800; font-size:16px;">문의 조회/작성은 로그인 후 가능해요</div>
          <div style="margin-top:6px; color:#6b7280; line-height:1.5;">
            로그인하면 내 문의 내역을 확인하고, 답변도 받을 수 있습니다.
          </div>
          <div style="margin-top:12px;">
            <a class="btn solid" href="${pageContext.request.contextPath}/members/login">로그인</a>
          </div>
        </div>
      </c:if>

    </main>
  </div>
</div>

</body>
</html>
