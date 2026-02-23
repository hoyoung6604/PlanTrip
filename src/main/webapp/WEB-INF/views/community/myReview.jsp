<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>내 여행 후기</title>
  
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

        <a href="${pageContext.request.contextPath}/community/write">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M12 5v14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M5 12h14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          후기 작성
        </a>

        <a class="active" href="${pageContext.request.contextPath}/community/my-reviews">
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
          <div class="mp-card-title">내 여행 후기</div>
          <div class="mp-card-sub">내가 작성한 후기만 모아 볼 수 있어요</div>
        </div>
        <div class="cm-head-right">
          <div class="cm-total">총 <b><c:out value="${fn:length(myReviews)}"/></b>건</div>
        </div>
      </div>

      <div class="mp-card-body">
        <c:choose>
          <c:when test="${empty myReviews}">
            <div class="cm-empty">
              아직 작성한 후기가 없습니다.
              <div class="sub">후기를 작성하면 여기에 표시돼요.</div>
            </div>
          </c:when>

          <c:otherwise>
            <div class="cm-table-wrap">
              <table class="cm-table">
                <thead>
                  <tr>
                    <th style="width:90px;">번호</th>
                    <th style="width:220px;">여행지</th>
                    <th>제목</th>
                    <th style="width:140px;">등록일</th>
                    <th style="width:90px;">조회</th>
                    <th style="width:160px;">관리</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="r" items="${myReviews}">
                    <tr>
                      <td>${r.rvIdx}</td>
                      <td class="cm-wrap"><c:out value="${r.spot.city.name}" /></td>
                      <td class="cm-wrap" style="max-width:520px; white-space:normal;">
                        <a class="cm-title-link" href="${pageContext.request.contextPath}/community/view?rvIdx=${r.rvIdx}">
                          <c:out value="${r.rvTitle}" />
                        </a>
                      </td>
	                      <td class="cm-col-date">
                        <c:choose>
                          <c:when test="${empty r.rvRegDate}"><span class="cm-muted">-</span></c:when>
                          <c:otherwise>
                            <span class="cm-muted">${fn:replace(fn:substring(r.rvRegDate,0,10),'-','.')}</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td><c:out value="${empty r.rvVCount ? 0 : r.rvVCount}"/></td>
                      <td>
                        <a href="${pageContext.request.contextPath}/community/edit?rvIdx=${r.rvIdx}">
                          <button class="cm-linkbtn" type="button">수정</button>
                        </a>
                        <span style="opacity:.5;"> | </span>
                        <form action="${pageContext.request.contextPath}/community/delete" method="post" style="display:inline;">
                          <input type="hidden" name="rvIdx" value="${r.rvIdx}">
                          <button type="submit" class="cm-linkbtn">삭제</button>
                        </form>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>

            <!-- ✅ 페이지네이션(클라이언트) : 10개씩 나눠서 보여줌 -->
            <div class="cm-pagination" id="myPagination" aria-label="페이지네이션"></div>
            <script>
            (function(){
              const table = document.querySelector('.cm-table');
              if(!table) return;
              const tbody = table.querySelector('tbody');
              if(!tbody) return;
              const rows = Array.from(tbody.querySelectorAll('tr'));
              const pager = document.getElementById('myPagination');
              const pageSize = 10;
              const total = rows.length;
              const pages = Math.max(1, Math.ceil(total / pageSize));
              let current = 1;

              function render(){
                rows.forEach((r, idx)=>{
                  const p = Math.floor(idx / pageSize) + 1;
                  r.style.display = (p === current) ? '' : 'none';
                });
                if(!pager) return;
                pager.innerHTML = '';
                for(let p=1; p<=pages; p++){
                  const b = document.createElement('button');
                  b.type = 'button';
                  b.className = 'cm-page' + (p === current ? ' is-active' : '');
                  b.textContent = p;
                  b.addEventListener('click', ()=>{ current = p; render(); });
                  pager.appendChild(b);
                }
              }
              render();
            })();
            </script>
          </c:otherwise>
        </c:choose>
      </div>
    </section>
  </main>

</div>
<%@ include file="/WEB-INF/views/common/authModal.jspf" %>
</body>
</html>
