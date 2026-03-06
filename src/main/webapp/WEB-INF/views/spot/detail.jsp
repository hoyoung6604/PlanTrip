<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
		<%@ taglib prefix="j" uri="jakarta.tags.core" %>
		<%@ include file="/WEB-INF/views/common/theme.jspf" %>
		<!DOCTYPE html>
		<html>

		<head>
			<meta charset="UTF-8">
			<title>${spot.name} - 상세 정보</title>
				<link rel="stylesheet" href="/css/header.css" />
				<script src="/js/theme.js"></script>
				<script defer src="/js/nav-wave.js"></script>
			<style>
				body {
					font-family: 'Pretendard', sans-serif;
					background-color: #f5f7fa;
					margin: 0;
				}

				.container {
					max-width: 1100px;
					margin: 0 auto;
					padding: 20px;
				}

				/* 상단 이미지 갤러리 */
				.image-gallery {
					display: grid;
					grid-template-columns: 2fr 1fr;
					gap: 10px;
					height: 400px;
					border-radius: 15px;
					overflow: hidden;
					margin-bottom: 30px;
				}

				.main-img {
					background: #eee;
					width: 100%;
					height: 100%;
					object-fit: cover;
				}

				.sub-imgs {
					display: grid;
					grid-template-rows: 1fr 1fr;
					gap: 10px;
				}

				/* 정보 섹션과 예약 박스 배치 */
				.content-wrapper {
					display: grid;
					grid-template-columns: 7fr 3fr;
					gap: 30px;
				}

				/* 좌측 정보 영역 */
				.info-section {
					background: white;
					padding: 30px;
					border-radius: 15px;
					box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
				}

				.spot-name {
					font-size: 32px;
					font-weight: 800;
					margin-bottom: 10px;
				}

				.rating {
					color: #3264ff;
					font-weight: bold;
					margin-bottom: 20px;
				}

				.detail-item {
					display: flex;
					align-items: flex-start;
					margin-bottom: 20px;
					font-size: 15px;
				}

				.detail-label {
					width: 150px;
					/* 100 → 150으로 통일 */
					color: #777;
					font-weight: bold;
					flex-shrink: 0;
				}

				.detail-content {
					flex: 1;
					line-height: 1.8;
					color: #555;
					font-size: 16px;
					white-space: pre-wrap;
					text-align: left;
				}


				/* 우측 예약 박스 */
				.booking-box {
					background: white;
					padding: 25px;
					border-radius: 15px;
					box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
					position: sticky;
					top: 20px;
					text-align: center;
				}

				.btn-booking {
					background: #3264ff;
					color: white;
					border: none;
					padding: 15px;
					width: 100%;
					display: inline-flex;
					align-items: center;
					justify-content: center;
					text-decoration: none;
					border-radius: 10px;
					font-size: 18px;
					font-weight: bold;
					cursor: pointer;
				}
			</style>
		</head>

		<body>
			
			<jsp:include page="/WEB-INF/views/common/header.jsp" />
			<div class="container">
				<%-- 1. 이미지 갤러리 (로컬 이미지 연결) --%>
				<%-- 1. 이미지 갤러리 (로컬 이미지 연결) --%>
				<div class="image-gallery">
				    <%-- ✅ 메인 이미지: 장소번호_1.jpg --%>
				    <div class="main-img"
				        style="background-image: url('${pageContext.request.contextPath}/img/spot/${spot.id}_1.jpg'); background-size: cover; background-position: center;">
				    </div>

				    <div class="sub-imgs">
				        <%-- ✅ 서브 이미지 1: 장소번호_2.jpg --%>
				        <div style="background-image: url('${pageContext.request.contextPath}/img/spot/${spot.id}_2.jpg'); background-size: cover; background-position: center;">
				        </div>
				        
				        <%-- ✅ 서브 이미지 2: 장소번호_3.jpg --%>
				        <div style="background-image: url('${pageContext.request.contextPath}/img/spot/${spot.id}_3.jpg'); background-size: cover; background-position: center;">
				        </div>
				    </div>
				</div>

					<div class="content-wrapper">
						<%-- 2. 상세 정보 영역 --%>
							<div class="info-section">
								<%-- 1. 장소 이름 --%>
								<div class="spot-name" style="font-size: 32px; font-weight: 800; margin-bottom: 10px; display: flex; justify-content: space-between; align-items: center;">
								    <span>${spot.name}</span>
								    <button class="wish-btn" onclick="toggleWish(event, ${spot.id}, this)" 
								            style="background: white; border: 1px solid #ddd; border-radius: 50%; width: 45px; height: 45px; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 22px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); flex-shrink: 0;">
								        ${spot.isHearted ? '❤️' : '🤍'}
								    </button>
								</div>

									<%-- 2. 별점 --%>
										<div class="rating"
											style="margin-bottom: 25px; display: flex; align-items: center; gap: 5px;">
											<span style="color: #ffc107; font-size: 20px;">★</span>
											<span style="font-size: 18px; font-weight: bold; color: #3264ff;">${not
												empty spot.price ? spot.price : '0.0'}</span>
											<span style="color: #888; font-size: 14px;"></span>
										</div>

										<hr style="border: 0.5px solid #eee; margin-bottom: 25px;">

										<%-- 3. 주소 (공통) --%>
											<div class="detail-item" style="display: flex; margin-bottom: 15px;">
												<div class="detail-label"
													style="width: 150px; color: #777; font-weight: bold;">주소</div>
												<div style="color: #333;">${spot.addr}</div>
											</div>

											<%-- 여기부터 카테고리에 따라 다르게 나옵니다 --%>
												<j:choose>
													<j:when test="${spot.catCode eq 'STAY'}">
														<div class="detail-item"
															style="display: flex; margin-bottom: 15px;">
															<div class="detail-label"
																style="width: 150px; color: #777; font-weight: bold;">
																체크인 / 체크아웃</div>
															<div style="color: #333;">
																<%-- DB에 '15:00 / 11:00' 형태로 들어있는 데이터를 그대로 출력 --%>
																	${not empty spot.hours ? spot.hours : '정보 없음'}
															</div>
														</div>
														<%-- 휴무일은 여기에 코드를 안 넣었으므로 숙소일 땐 자동으로 안 나옵니다 --%>
													</j:when>

													<j:otherwise>
														<%-- 그 외(관광지, 맛집 등): 기존 영업 시간/휴무일 표시 --%>
															<div class="detail-item"
																style="display: flex; margin-bottom: 15px;">
																<div class="detail-label"
																	style="width: 150px; color: #777; font-weight: bold;">
																	영업 시간</div>
																<div style="color: #333;">${not empty spot.hours ?
																	spot.hours : "정보 없음"}</div>
															</div>
															<div class="detail-item"
																style="display: flex; margin-bottom: 15px;">
																<div class="detail-label"
																	style="width: 150px; color: #777; font-weight: bold;">
																	휴무일</div>
																<div style="color: #333;">${not empty spot.holiday ?
																	spot.holiday : "연중무휴"}</div>
															</div>
													</j:otherwise>
												</j:choose>

												<%-- 6. 상세 설명 --%>
													<div class="detail-item"
														style="display: flex; margin-bottom: 15px;">
														<div class="detail-label"
															style="width: 150px; color: #777; font-weight: bold;">상세 내용
														</div>
														<div style="color: #333;">${spot.info}</div>
													</div>
							</div>


							<%-- 3. 여행 계획 만들기 --%>
							<aside>
							    <div class="booking-box">
							        <div style="font-size: 14px; color: #777; margin-bottom: 20px;">
							            지금 바로 계획을 세워보세요
							        </div>
									<a href="/plans/planRoute" class="btn-booking" data-auth-guard>일정 만들기</a>
							    </div>
							</aside>
					</div>
			</div>

			<%@ include file="/WEB-INF/views/common/footer.jspf" %>

		</body>
<script>
	
	// 하트 토글 통신 함수
	function toggleWish(event, sIdx, btn) {
	    event.preventDefault();
	    event.stopPropagation(); // 카드 링크로 이동하는 것을 방지하고 하트만 토글시킴
	    
	    fetch('/api/wish/toggle', {
	        method: 'POST',
	        headers: { 'Content-Type': 'application/json' },
	        body: JSON.stringify({ sIdx: sIdx })
	    })
	    .then(response => {
	        if (response.status === 401) {
	            if (window.LoginRequiredPrompt) { window.LoginRequiredPrompt.open(); } else { if (window.LoginRequiredPrompt) { window.LoginRequiredPrompt.open(); } else { alert('로그인이 필요한 서비스입니다.'); } }
	            return;
	        }
	        return response.json();
	    })
	    .then(data => {
	        if (data && data.success) {
	            btn.innerText = data.isHearted ? '❤️' : '🤍';
	            if (data.isHearted) btn.classList.add('active');
	            else btn.classList.remove('active');
	        }
	    })
	    .catch(error => {
	        console.error('Error:', error);
	        alert('처리 중 오류가 발생했습니다.');
	    });
	}
</script>
		</html>