<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>내 여행 후기</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
</head>
<body>

<c:set var="displayName" value="사용자" />
<c:choose>
  <c:when test="${not empty sessionScope.loginUserName}">
    <c:set var="displayName" value="${sessionScope.loginUserName}" />
  </c:when>
  <c:when test="${not empty sessionScope.loginMember and not empty sessionScope.loginMember.MName}">
    <c:set var="displayName" value="${sessionScope.loginMember.MName}" />
  </c:when>
  <c:when test="${not empty sessionScope.member and not empty sessionScope.member.MName}">
    <c:set var="displayName" value="${sessionScope.member.MName}" />
  </c:when>
  <c:when test="${not empty pageContext.request.userPrincipal}">
    <c:set var="displayName" value="${pageContext.request.userPrincipal.name}" />
  </c:when>
</c:choose>

<div class="mp-shell">

  <!-- Left Sidebar -->
  <aside class="mp-side">
    <div class="mp-brand">
      <div class="mp-logo"></div>
      <div class="mp-brand-name"><c:out value="${displayName}"/></div>
    </div>

    <div class="sec">
      <div class="sec-title">OVERVIEW</div>

      <!-- 여기서 글씨 깨짐 원인: span 미닫힘 이슈 -> 전부 정상 닫힘 처리 -->
      <nav class="mp-nav">
        <a href="${pageContext.request.contextPath}/members/mypage">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 13h7V4H4v9Zm9 7h7V11h-7v9ZM4 20h7v-5H4v5Zm9-16v5h7V4h-7Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          대시보드
        </a>

        <a href="${pageContext.request.contextPath}/members/mypage/check">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M12 20h9" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4 11.5-11.5Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          회원정보 수정
        </a>

        <a href="${pageContext.request.contextPath}/members/mypage/plans">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M7 3v3M17 3v3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 8h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M5 6h14a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          내 여행 계획
        </a>

        <a class="active" href="${pageContext.request.contextPath}/members/mypage/reviews">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 6h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 18h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          내 여행 후기
        </a>
      </nav>
    </div>

    <div class="sec sec-bottom">
      <div class="sec-title">SETTINGS</div>
      <nav class="mp-nav">
        <button class="menu-btn" type="button" onclick="location.href='${pageContext.request.contextPath}/'">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M3 10.5 12 3l9 7.5V21a2 2 0 0 1-2 2h-4v-7H9v7H5a2 2 0 0 1-2-2V10.5Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          메인으로
        </button>

        <form action="${pageContext.request.contextPath}/members/logout" method="post" style="margin:0;">
          <button class="menu-btn danger" type="submit">
            <span class="mp-ico" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none">
                <path d="M10 17l-1 0a4 4 0 0 1-4-4V7a4 4 0 0 1 4-4h1"
                      stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                <path d="M15 7l5 5-5 5" stroke="currentColor" stroke-width="1.8"
                      stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M20 12H10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              </svg>
            </span>
            로그아웃
          </button>
        </form>
      </nav>
    </div>
  </aside>

  <!-- Center -->
  <main class="mp-main">
    <section class="mp-card mp-grow">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title">내 여행 후기</div>
          <div class="mp-card-sub">작성한 후기 목록</div>
        </div>

        <c:if test="${not empty sessionScope.loginMember}">
          <button class="mp-btn" type="button"
                  onclick="location.href='${pageContext.request.contextPath}/community/write'">
            새 후기
          </button>
        </c:if>
      </div>

      <div class="mp-card-body">
        <form action="${pageContext.request.contextPath}/members/mypage/reviews" method="get" style="margin-bottom:12px;">
          <div class="mp-search">
			<span class="sico" aria-hidden="true">
			  <svg viewBox="0 0 24 24" fill="none">
			    <path d="M10.5 18a7.5 7.5 0 1 1 0-15 7.5 7.5 0 0 1 0 15Z" stroke="currentColor" stroke-width="1.8"/>
			    <path d="M16.5 16.5 21 21" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
			  </svg>
			</span>

            <input type="text" name="keyword" value="${keyword}" placeholder="후기 제목 검색">
            <button class="mp-btn" type="submit" style="padding:10px 14px;">검색</button>
          </div>
        </form>

        <c:choose>
			<c:when test="${empty reviews}">
            <div class="mp-row">
              <div>
                <div class="ttl">등록된 여행 후기가 없습니다.</div>
                <div class="sub">후기를 작성하면 여기에 표시돼요.</div>
              </div>
            </div>
          </c:when>

          <c:otherwise>
            <div class="table-wrap">
              <table class="data-table">
                <thead>
                <tr>
                  <th>제목</th>
                  <th>별점</th>
                  <th>관리</th>
                </tr>
                </thead>
                <tbody>
					<c:forEach var="r" items="${reviews}">

                  <tr>
                    <td><c:out value="${r.rvTitle}"/></td>
                    <td><c:out value="${r.rvStar}"/></td>
                    <td>
						<a href="${pageContext.request.contextPath}/community/edit?rvIdx=${r.rvIdx}&from=mypage">수정</a>
                      &nbsp;
					  <form action="${pageContext.request.contextPath}/community/delete" method="post" style="display:inline;">
					    <input type="hidden" name="rvIdx" value="${r.rvIdx}">
					    <input type="hidden" name="from" value="mypage">
					    <button type="submit" class="link-btn">삭제</button>
					  </form>

                    </td>
                  </tr>
                </c:forEach>
                </tbody>
              </table>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </section>
  </main>

  <!-- Right -->
  <aside class="mp-right">
    <section class="mp-profile">
      <div class="mp-profile-top">
        <div class="ttl">내 계정</div>
        <div class="mp-mini"></div>
      </div>

      <div class="name"><c:out value="${displayName}"/></div>
      <div class="desc">계정 정보 및 여행 기록을 확인할 수 있어요</div>

      <div class="mp-row" style="margin-top:12px;">
        <div>
          <div class="ttl">회원정보 수정</div>
          <div class="sub">비밀번호 확인 후 수정</div>
        </div>
        <button class="mp-pill" type="button"
                onclick="location.href='${pageContext.request.contextPath}/members/mypage/check'">
          이동
        </button>
      </div>
    </section>

    <section class="mp-card" style="padding:16px;">
      <div class="mp-card-title" style="margin-bottom:6px;">추후 확장</div>
      <div class="mp-card-sub">후기 상세 페이지, 사진 업로드 등도 추후 추가할 수 있어요</div>
      <div class="mp-card-sub" style="margin-top:10px;">현재는 UI만 만들어 둔 상태예요.</div>
    </section>
  </aside>

</div>

</body>
</html>
