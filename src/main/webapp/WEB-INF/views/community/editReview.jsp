<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>후기 수정</title>

  <link rel="stylesheet" href="/css/theme-sky.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/community.css">
  <link rel="stylesheet" href="/css/auth-modal.css" />
  <link rel="stylesheet" href="/css/ui-toast.css" />

  <script defer src="/js/ui-toast.js"></script>
  <script defer src="/js/theme.js"></script>
  <script defer src="/js/auth-modal.js"></script>
  <script defer src="/js/auth-guard.js"></script>
</head>
<body>

<div class="cm-shell">

  <aside class="mp-side">
    <div class="mp-brand">
      <div class="mp-logo"></div>
      <div class="mp-brand-name">Community</div>
    </div>

    <div class="sec">
      <div class="sec-title">MENU</div>
      <nav class="mp-nav">
        <a href="${pageContext.request.contextPath}/community">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 6h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 18h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          여행 후기 목록
        </a>

        <a href="${pageContext.request.contextPath}/community/my-reviews">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 7h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 17h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          내 여행 후기
        </a>
      </nav>
    </div>

    <div class="sec sec-bottom">
      <div class="sec-title">SETTINGS</div>
      <nav class="mp-nav">
        <a href="${pageContext.request.contextPath}/members/mypage">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 13h7V4H4v9Zm9 7h7V11h-7v9ZM4 20h7v-5H4v5Zm9-16v5h7V4h-7Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          마이페이지로
        </a>

        <button class="menu-btn" type="button"
                onclick="location.href='${pageContext.request.contextPath}/'">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M3 10.5 12 3l9 7.5V21a2 2 0 0 1-2 2h-4v-7H9v7H5a2 2 0 0 1-2-2V10.5Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          메인으로
        </button>
      </nav>
    </div>
  </aside>

  <main class="cm-main">
    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">후기 수정</div>
          <div class="mp-card-sub">제목, 내용, 별점을 변경할 수 있어요</div>
        </div>
      </div>

      <div class="mp-card-body">

        <!-- =========================
             ✅ 수정 폼 (중첩 form 금지!)
             제목/내용/별점만 담당
        ========================= -->
        <form class="cm-form"
              action="${pageContext.request.contextPath}/community/edit"
              method="post">

          <input type="hidden" name="rvIdx" value="${review.rvIdx}"/>

          <div class="cm-field">
            <label>별점</label>
            <select name="rvStar" required>
              <option value="5" <c:if test="${review.rvStar == 5}">selected</c:if>>★★★★★</option>
              <option value="4" <c:if test="${review.rvStar == 4}">selected</c:if>>★★★★</option>
              <option value="3" <c:if test="${review.rvStar == 3}">selected</c:if>>★★★</option>
              <option value="2" <c:if test="${review.rvStar == 2}">selected</c:if>>★★</option>
              <option value="1" <c:if test="${review.rvStar == 1}">selected</c:if>>★</option>
            </select>
          </div>

          <div class="cm-field">
            <label>후기 제목</label>
            <input type="text" name="rvTitle" value="${review.rvTitle}" required/>
          </div>

          <div class="cm-field">
            <label>후기 내용</label>
            <textarea name="rvCont" required>${review.rvCont}</textarea>
          </div>

          <div class="cm-actions">
            <button class="cm-primary" type="submit">수정 저장</button>
            <button class="cm-ghost" type="button" onclick="history.back()">취소</button>
          </div>

        </form>
        <!-- ✅ 수정 폼 끝 -->

        <!-- =========================
             ✅ 사진 첨부/관리 (수정 폼 밖으로 이동)
             - 기존 사진: ${photos}
             - 추가 업로드: /reviewphoto/upload
             - 삭제: /reviewphoto/delete
        ========================= -->
        <section class="cm-photo" style="margin-top:18px;">
          <h3 style="margin:0 0 10px; font-size:16px;">사진</h3>

          <c:if test="${not empty photos}">
            <div class="cm-photo-grid" style="display:flex; flex-wrap:wrap; gap:10px; margin-bottom:10px;">
              <c:forEach var="p" items="${photos}">
                <div class="cm-photo-item" style="position:relative; width:120px; height:90px; border-radius:12px; overflow:hidden; background:#f3f4f6;">
                  <img
                    src="${pageContext.request.contextPath}/reviewphoto/${p.rpIdx}"
                    alt="후기 사진"
                    style="width:100%; height:100%; object-fit:cover;"
                  />

                  <!-- ✅ 사진 삭제 폼 (단독 form) -->
                  <form method="post"
                        action="${pageContext.request.contextPath}/reviewphoto/delete"
                        style="position:absolute; top:6px; right:6px;">
                    <input type="hidden" name="rpIdx" value="${p.rpIdx}" />
                    <input type="hidden" name="rvIdx" value="${review.rvIdx}" />
                    <button type="submit"
                            style="border:0; cursor:pointer; padding:4px 8px; border-radius:999px; background:rgba(0,0,0,.55); color:#fff; font-size:12px;">
                      삭제
                    </button>
                  </form>

                </div>
              </c:forEach>
            </div>
          </c:if>

          <!-- ✅ 사진 업로드 폼 (단독 form) -->
          <form method="post"
                action="${pageContext.request.contextPath}/reviewphoto/upload"
                enctype="multipart/form-data"
                style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
            <input type="hidden" name="rvIdx" value="${review.rvIdx}" />
            <input type="hidden" name="redirectBase" value="/community/edit?rvIdx=" />
            <input type="file" name="photos" accept="image/*" multiple style="max-width:280px;" />
            <button type="submit" class="cm-btn cm-btn-primary" style="padding:10px 14px;">
              사진 추가
            </button>
            <p style="margin:0; font-size:12px; color:#6b7280;">여러 장 선택 가능</p>
          </form>
        </section>

      </div>
    </section>
  </main>

</div>

<%@ include file="/WEB-INF/views/common/authModal.jspf" %>
</body>
</html>