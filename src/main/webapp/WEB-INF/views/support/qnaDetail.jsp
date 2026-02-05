<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>문의 상세 | 고객센터</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0;">
  <div style="display:flex; align-items:flex-end; justify-content:space-between; gap:12px; margin-bottom:14px;">
    <div>
      <h1 style="margin:0; font-size:24px;">고객센터</h1>
      <p style="margin:6px 0 0; color:#6b7280;">문의 상세</p>
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
        <!-- 상단 헤더 -->
        <div style="display:flex; align-items:flex-start; justify-content:space-between; gap:12px; flex-wrap:wrap;">
          <div style="min-width:0;">
            <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
              <div style="font-weight:900; font-size:18px; max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                ${qna['qTitle']}
              </div>

              <span style="display:inline-block; padding:4px 10px; border-radius:999px; border:1px solid #e5e7eb; font-size:12px;">
                ${qna['qStatusLabel']}
              </span>
            </div>

            <div style="margin-top:6px; color:#6b7280; font-size:12px;">
              문의번호 #${qna['qIdx']} · 작성일 ${qna['qRegDate']}
            </div>
          </div>

          <div style="display:flex; gap:10px; flex-wrap:wrap;">
            <a class="btn" href="${pageContext.request.contextPath}/support/qna">목록으로</a>
            <a class="btn solid" href="${pageContext.request.contextPath}/support/qna/new">새 문의</a>

            <!-- 삭제 (POST) -->
            <form action="${pageContext.request.contextPath}/support/qna/${qna['qIdx']}/delete"
                  method="post"
                  onsubmit="return confirm('정말 삭제할까요? 삭제 후 복구할 수 없습니다.');"
                  style="margin:0;">
              <button type="submit" class="btn"
                      style="cursor:pointer; border:1px solid #e5e7eb; background:#fff;">
                삭제
              </button>
            </form>
			<!-- 수정 (POST) -->
			<a class="btn" href="${pageContext.request.contextPath}/support/qna/${qna['qIdx']}/edit">수정</a>
          </div>
        </div>

        <!-- 문의 내용 -->
        <div style="margin-top:14px; padding-top:14px; border-top:1px solid #f1f5f9;">
          <div style="font-weight:800; margin-bottom:8px;">문의 내용</div>
          <div style="white-space:pre-wrap; line-height:1.7; color:#111827;">
            ${qna['qCont']}
          </div>
        </div>

        <!-- 답변 -->
        <div style="margin-top:14px; padding-top:14px; border-top:1px solid #f1f5f9;">
          <div style="display:flex; align-items:center; justify-content:space-between; gap:10px;">
            <div style="font-weight:800;">관리자 답변</div>
            <c:if test="${qna['qStatus'] eq 0}">
              <span style="color:#6b7280; font-size:12px;">답변 준비 중</span>
            </c:if>
          </div>

          <c:choose>
            <c:when test="${empty qna['qAnswer']}">
              <div style="margin-top:10px; padding:12px; border:1px dashed #e5e7eb; border-radius:12px; color:#6b7280;">
                아직 답변이 등록되지 않았습니다. 조금만 기다려주세요.
              </div>
            </c:when>
            <c:otherwise>
              <div style="margin-top:10px; padding:12px; border:1px solid #e5e7eb; border-radius:12px; background:#fff;">
                <div style="white-space:pre-wrap; line-height:1.7; color:#111827;">
                  ${qna['qAnswer']}
                </div>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <div style="margin-top:14px; color:#6b7280; font-size:12px;">
          * 삭제는 작성자 본인만 가능합니다.
        </div>
      </div>
    </main>
  </div>
</div>

</body>
</html>
