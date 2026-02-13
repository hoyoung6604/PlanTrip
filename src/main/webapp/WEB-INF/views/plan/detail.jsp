<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<%@ taglib prefix="j" uri="jakarta.tags.core" %>
		<!DOCTYPE html>
		<html>

		<head>
			<meta charset="UTF-8">
			<title>${spot.name} - 상세 정보</title>
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
					border-radius: 10px;
					font-size: 18px;
					font-weight: bold;
					cursor: pointer;
				}
			</style>
		</head>

		<body>
			<header style="background: white; border-bottom: 1px solid #f0f0f0; padding: 12px 0; position: sticky; top: 0; z-index: 1000; box-shadow: 0 2px 10px rgba(0,0,0,0.02);">
				    <div style="max-width: 1200px; margin: 0 auto; padding: 0 20px; display: flex; align-items: center; justify-content: space-between;">
				        
				        <a href="${pageContext.request.contextPath}/index" style="text-decoration: none; display: flex; align-items: center;">
				            <img src="${pageContext.request.contextPath}/img/PlanTriplog.png" 
				                 alt="PlanTrip 로고" 
				                 style="height: 45px; width: auto; object-fit: contain;">
				        </a>

				        <nav style="display: flex; gap: 20px; font-size: 15px; font-weight: 600;">
				            </nav>
				        
				    </div>
				</header>
			<div class="container">
				<%-- 1. 이미지 갤러리 (로컬 이미지 연결) --%>
					<div class="image-gallery">
						<%-- 메인 이미지는 hero.jpg로 설정해봅니다 --%>
							<div class="main-img"
								style="background-image: url('${pageContext.request.contextPath}/img/hero.jpg'); background-size: cover; background-position: center;">
							</div>

							<div class="sub-imgs">
								<%-- 서브 이미지는 mountain.jpg와 sea.jpg --%>
									<div
										style="background-image: url('${pageContext.request.contextPath}/img/mountain.jpg'); background-size: cover; background-position: center;">
									</div>
									<div
										style="background-image: url('${pageContext.request.contextPath}/img/sea.jpg'); background-size: cover; background-position: center;">
									</div>
							</div>
					</div>

					<div class="content-wrapper">
						<%-- 2. 상세 정보 영역 --%>
							<div class="info-section">
								<%-- 1. 장소 이름 --%>
									<div class="spot-name"
										style="font-size: 32px; font-weight: 800; margin-bottom: 10px;">
										${spot.name}
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


							<%-- 3. 고정 예약 박스 --%>
								<aside>
									<div class="booking-box">
										<div style="font-size: 14px; color: #777; margin-bottom: 20px;">지금 바로 계획을 세워보세요
										</div>
										<button class="btn-booking">지금 예약</button>
									</div>
								</aside>
					</div>
			</div>

		</body>

		</html>