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
	
    <link rel="stylesheet" href="/css/header.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/community.css">
<link rel="stylesheet" href="/css/redesign.css" />
	<link rel="stylesheet" href="/css/ui-toast.css" />

	<script defer src="/js/ui-toast.js"></script>
	<script defer src="/js/theme.js"></script>

    <script defer src="/js/nav-wave.js"></script>
</head>

<body class="page-solid">

	
    <jsp:include page="/WEB-INF/views/common/header.jsp" />
<div class="cm-shell">

		<!-- 좌측 사이드바는 마이페이지와 동일한 구조로 유지 -->
<!-- 가운데 콘텐츠 -->
		<main class="cm-main">

			<section class="mp-card">
				<div class="mp-card-head">
					<div>
						<div class="mp-card-title">여행 후기 목록</div>
						<div class="mp-card-sub">모든 사용자의 후기를 확인할 수 있어요</div>
					</div>
					<div class="cm-head-right">
						<!-- ✅ 새후기 버튼 제거, 우측 상단에 총 건수만 표시 -->
						<div class="cm-total">
							총 <b><c:out value="${fn:length(reviews)}"/></b>건
						</div>
					</div>
				</div>

				<div class="mp-card-body">

					<!-- 검색/필터는 컨트롤러 파라미터 이름과 동일하게 맞춤 -->
					<form action="${pageContext.request.contextPath}/community" method="get">
						<div class="cm-toolbar">

							<div class="mp-search cm-search">
								<input type="text" name="keyword" value="${keyword}" placeholder="작성자 또는 제목으로 검색">
								<button class="mp-btn" type="submit" style="padding:10px 14px;">검색</button>
							</div>

							<div class="cm-filters">
								<div class="cm-filter-row">
									<select class="cm-select" name="sort">
										<option value="latest" <c:if test="${sort == 'latest'}">selected
											</c:if>>최신순</option>
										<option value="star" <c:if test="${sort == 'star'}">selected</c:if>
											>별점순</option>
									</select>

									<button class="mp-btn" type="submit" style="padding:10px 14px;">적용</button>
								</div>
							</div>
						</div>
					</form>

					<!-- ✅ 후기 작성: 버튼 느낌 제거 + B영역(실선 아래)로 이동 -->
					<div class="cm-write-row">
						<a class="cm-write-link" href="${pageContext.request.contextPath}/community/write">후기 작성</a>
					</div>

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
										<td class="cm-col-date">
												  <c:out value="${r.member.MName}" />
												</td>
											<td>
												<c:choose>
													<c:when test="${empty r.rvRegDate}"><span class="cm-muted">-</span></c:when>
													<c:otherwise>
														<span class="cm-muted">${fn:replace(fn:substring(r.rvRegDate,0,10),'-','.')}</span>
													</c:otherwise>
												</c:choose>
											</td>
											<td>
												<c:out value="${empty r.rvVCount ? 0 : r.rvVCount}"/>
											</td>
											</tr>
										</c:forEach>
									</tbody>
								</table>
							</div>

						<!-- ✅ 페이지네이션(클라이언트) : 로직/DB 건드리지 않고 10개씩 나눠서 보여줌 -->
						<div class="cm-pagination" id="cmPagination" aria-label="페이지네이션"></div>
						<script>
						(function(){
						  const table = document.querySelector('.cm-table');
						  if(!table) return;
						  const tbody = table.querySelector('tbody');
						  if(!tbody) return;
						  const rows = Array.from(tbody.querySelectorAll('tr'));
						  const pager = document.getElementById('cmPagination');
						  const pageSize = 10;
						  const total = rows.length;
						  const pages = Math.max(1, Math.ceil(total / pageSize));
						  let current = 1;
						
						  function render(){
						    rows.forEach((row, idx)=>{
						      const page = Math.floor(idx / pageSize) + 1;
						      row.style.display = (page === current) ? '' : 'none';
						    });
						
						    if(!pager) return;
						    pager.innerHTML = '';
						    for(let i=1;i<=pages;i++){
						      const a = document.createElement('button');
						      a.type = 'button';
						      a.className = 'cm-page' + (i===current ? ' is-active' : '');
						      a.textContent = String(i);
						      a.addEventListener('click', ()=>{ current=i; render(); window.scrollTo({top:0, behavior:'smooth'}); });
						      pager.appendChild(a);
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
<%@ include file="/WEB-INF/views/common/footer.jspf" %>

</body>

</html>