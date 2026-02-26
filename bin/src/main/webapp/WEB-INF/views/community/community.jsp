<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">

<head>
	<meta charset="UTF-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<title>커뮤니티</title>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/community.css">
	<link rel="stylesheet" href="/css/ui-toast.css" />

	<script defer src="/js/ui-toast.js"></script>
	<script defer src="/js/theme.js"></script>

</head>

<body>

	<div class="cm-shell">

		<!-- 좌측 사이드바는 마이페이지와 동일한 구조로 유지 -->
		<aside class="mp-side">
			<div class="mp-brand">
				<div class="mp-logo"></div>
				<div class="mp-brand-name">Community</div>
			</div>

			<div class="sec">
				<div class="sec-title">MENU</div>
				<nav class="mp-nav">
					<a class="active" href="${pageContext.request.contextPath}/community">
						<span class="mp-ico" aria-hidden="true">
							<svg viewBox="0 0 24 24" fill="none">
								<path d="M4 6h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
								<path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
								<path d="M4 18h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
							</svg>
						</span>
						여행 후기 목록
					</a>

					<a href="${pageContext.request.contextPath}/community/write">
						<span class="mp-ico" aria-hidden="true">
							<svg viewBox="0 0 24 24" fill="none">
								<path d="M12 5v14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
								<path d="M5 12h14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
							</svg>
						</span>
						후기 작성
					</a>

					<a href="${pageContext.request.contextPath}/community/my-reviews">
						<span class="mp-ico" aria-hidden="true">
							<svg viewBox="0 0 24 24" fill="none">
								<path d="M4 7h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
								<path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
								<path d="M4 17h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
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
									stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" />
							</svg>
						</span>
						마이페이지로
					</a>

					<button class="menu-btn" type="button"
						onclick="location.href='${pageContext.request.contextPath}/'">
						<span class="mp-ico" aria-hidden="true">
							<svg viewBox="0 0 24 24" fill="none">
								<path d="M3 10.5 12 3l9 7.5V21a2 2 0 0 1-2 2h-4v-7H9v7H5a2 2 0 0 1-2-2V10.5Z"
									stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" />
							</svg>
						</span>
						메인으로
					</button>
				</nav>
			</div>
		</aside>

		<!-- 가운데 콘텐츠 -->
		<main class="cm-main">

			<section class="mp-card">
				<div class="mp-card-head">
					<div>
						<div class="mp-card-title">여행 후기 목록</div>
						<div class="mp-card-sub">모든 사용자의 후기를 확인할 수 있어요</div>
					</div>
					<button class="mp-btn" type="button"
						onclick="location.href='${pageContext.request.contextPath}/community/write'">
						새 후기
					</button>
				</div>

				<div class="mp-card-body">

					<!-- 검색/필터는 컨트롤러 파라미터 이름과 동일하게 맞춤 -->
					<form action="${pageContext.request.contextPath}/community" method="get"
						style="margin-bottom:12px;">
						<div class="cm-toolbar">

							<div class="mp-search cm-search">
								<input type="text" name="keyword" value="${keyword}" placeholder="작성자 또는 제목으로 검색">
								<button class="mp-btn" type="submit" style="padding:10px 14px;">검색</button>
							</div>

							<div class="cm-filters">
								<select class="cm-select" name="minStar">
									<option value="">최소 별점</option>
									<option value="5" <c:if test="${minStar == 5}">selected</c:if>>5점
									</option>
									<option value="4" <c:if test="${minStar == 4}">selected</c:if>>4점 이상
									</option>
									<option value="3" <c:if test="${minStar == 3}">selected</c:if>>3점 이상
									</option>
									<option value="2" <c:if test="${minStar == 2}">selected</c:if>>2점 이상
									</option>
									<option value="1" <c:if test="${minStar == 1}">selected</c:if>>1점 이상
									</option>
								</select>

								<select class="cm-select" name="sort">
									<option value="latest" <c:if test="${sort == 'latest'}">selected
										</c:if>>최신순</option>
									<option value="star" <c:if test="${sort == 'star'}">selected</c:if>
										>별점순</option>
								</select>

								<button class="mp-btn" type="submit" style="padding:10px 14px;">적용</button>
							</div>
						</div>
					</form>

					<!-- 목록 -->
					<c:choose>
						<c:when test="${empty reviews}">
							<div class="cm-empty">
								아직 등록된 후기가 없습니다.
								<div class="sub">첫 번째 후기를 작성해 보세요.</div>
							</div>
						</c:when>

						<c:otherwise>
							<div class="cm-table-wrap">
								<table class="cm-table">
									<thead>
										<tr>
											<th style="width:220px;">여행지</th>
											<th>제목</th>
											<th style="width:160px;">작성자</th>
											<th style="width:140px;">등록일</th>
											<th style="width:90px;">조회</th>
										</tr>
									</thead>
									<tbody>
										<c:forEach var="r" items="${reviews}">
											<tr>
												<!--
						                        ⚠️ 백엔드(CommunityController)가 model에 넘겨주는 값은 reviews/keyword/minStar/sIdx/sort 뿐이라
						                        여기서는 Review 객체의 필드만 사용합니다.
						                        또한 프로젝트의 Review getter는 getSIdx()/getMIdx() 형태라 EL 프로퍼티는 SIdx/MIdx로 접근해야
						                        (기존 코드와 동일) 500이 나지 않습니다.
						                      -->
											  <td class="cm-wrap">
											    <c:out value="${r.spot.city.name}" />
											  </td>
												<td class="cm-wrap" style="max-width:520px;">
													<a class="cm-title-link"
														href="${pageContext.request.contextPath}/community/view?rvIdx=${r.rvIdx}">
														<c:out value="${r.rvTitle}" />
													</a>
												</td>
												<td>
												  <c:out value="${r.member.MName}" />
												</td>
												<td><span class="cm-muted">-</span></td>
												<td><span class="cm-muted">-</span></td>
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

	</div>
</body>

</html>