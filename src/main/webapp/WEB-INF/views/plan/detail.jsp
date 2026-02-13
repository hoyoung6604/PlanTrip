<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${spot.name} - 상세 정보</title>
    <style>
        body { font-family: 'Pretendard', sans-serif; background-color: #f5f7fa; margin: 0; }
        .container { max-width: 1100px; margin: 0 auto; padding: 20px; }
        
        /* 상단 이미지 갤러리 */
        .image-gallery { display: grid; grid-template-columns: 2fr 1fr; gap: 10px; height: 400px; border-radius: 15px; overflow: hidden; margin-bottom: 30px; }
        .main-img { background: #eee; width: 100%; height: 100%; object-fit: cover; }
        .sub-imgs { display: grid; grid-template-rows: 1fr 1fr; gap: 10px; }
        
        /* 정보 섹션과 예약 박스 배치 */
        .content-wrapper { display: grid; grid-template-columns: 7fr 3fr; gap: 30px; }
        
        /* 좌측 정보 영역 */
        .info-section { background: white; padding: 30px; border-radius: 15px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .spot-name { font-size: 32px; font-weight: 800; margin-bottom: 10px; }
        .rating { color: #3264ff; font-weight: bold; margin-bottom: 20px; }
        .detail-item { display: flex; margin-bottom: 15px; font-size: 15px; }
        .detail-label { width: 100px; color: #777; font-weight: bold; }

        /* 우측 예약 박스 */
        .booking-box { background: white; padding: 25px; border-radius: 15px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); position: sticky; top: 20px; text-align: center; }
        .btn-booking { background: #3264ff; color: white; border: none; padding: 15px; width: 100%; border-radius: 10px; font-size: 18px; font-weight: bold; cursor: pointer; }
    </style>
</head>
<body>

<div class="container">
	<%-- 1. 이미지 갤러리 (로컬 이미지 연결) --%>
	    <div class="image-gallery">
	        <%-- 메인 이미지는 hero.jpg로 설정해봅니다 --%>
	        <div class="main-img" style="background-image: url('${pageContext.request.contextPath}/img/hero.jpg'); background-size: cover; background-position: center;"></div>
	        
	        <div class="sub-imgs">
	            <%-- 서브 이미지는 mountain.jpg와 sea.jpg --%>
	            <div style="background-image: url('${pageContext.request.contextPath}/img/mountain.jpg'); background-size: cover; background-position: center;"></div>
	            <div style="background-image: url('${pageContext.request.contextPath}/img/sea.jpg'); background-size: cover; background-position: center;"></div>
	        </div>
	    </div>

    <div class="content-wrapper">
		<%-- 2. 상세 정보 영역 --%>
		        <div class="info-section">
		            <%-- 이름은 그대로 둡니다 --%>
		            <div class="spot-name">${spot.name} <span style="font-size: 18px; cursor: pointer;">🤍</span></div>
		            
		            <%-- 별점 부분: spot.price 필드를 별점 대용으로 쓰거나 기본값 출력 --%>
		            <div class="rating">⭐ ${not empty spot.price ? spot.price : '4.5'} <span style="color: #888; font-weight: normal;">(추천 장소)</span></div>
		            
		            <hr style="border: 0.5px solid #eee; margin: 25px 0;">

		            <%-- 영업 시간: Java 필드명 hours와 매칭 --%>
		            <div class="detail-item">
		                <div class="detail-label">🕒 영업 시간</div>
		                <div>${not empty spot.hours ? spot.hours : "영업 시간 정보가 없습니다."}</div>
		            </div>

		            <%-- 주소: Java 필드명 addr와 매칭 --%>
		            <div class="detail-item">
		                <div class="detail-label">📍 주소</div>
		                <div>${spot.addr}</div>
		            </div>

		            <%-- 휴무일: Java 필드명 holiday와 매칭 (새로 추가!) --%>
		            <div class="detail-item">
		                <div class="detail-label">📅 휴무일</div>
		                <div>${not empty spot.holiday ? spot.holiday : "연중무휴"}</div>
		            </div>
		            
		            <%-- ❗ 가장 중요한 수정: description 대신 info를 사용합니다 --%>
		            <div style="margin-top: 30px; line-height: 1.8; color: #555; white-space: pre-wrap;">
		                ${not empty spot.info ? spot.info : "이 장소에 대한 상세 설명이 아직 등록되지 않았습니다."}
		            </div>

		            <%-- 4. 후기(커뮤니티) 미리보기 --%>
		            <hr style="border: 0.5px solid #eee; margin: 28px 0;">
		            <div style="display:flex; align-items:center; justify-content:space-between; gap:12px;">
		              <div style="font-size:18px; font-weight:800;">후기</div>
		              <div style="display:flex; gap:8px;">
		                <a href="${pageContext.request.contextPath}/community?sIdx=${spot.id}" style="text-decoration:none;">
		                  <button type="button" style="border:1px solid #d6def5; background:#fff; color:#3264ff; padding:10px 12px; border-radius:10px; cursor:pointer;">더보기</button>
		                </a>
		                <a href="${pageContext.request.contextPath}/community/write?sIdx=${spot.id}" style="text-decoration:none;">
		                  <button type="button" style="border:none; background:#3264ff; color:#fff; padding:10px 12px; border-radius:10px; cursor:pointer;">후기 작성</button>
		                </a>
		              </div>
		            </div>

		            <div style="margin-top:14px; display:flex; flex-direction:column; gap:10px;">
		              <j:choose>
		                <j:when test="${empty spotReviews}">
		                  <div style="padding:14px 16px; border:1px dashed #d9e0f5; border-radius:12px; color:#667085;">아직 등록된 후기가 없습니다. 첫 후기를 남겨보세요.</div>
		                </j:when>
		                <j:otherwise>
		                  <j:forEach var="r" items="${spotReviews}">
		                    <a href="${pageContext.request.contextPath}/community/view?rvIdx=${r.rvIdx}" style="text-decoration:none; color:inherit;">
		                      <div style="padding:14px 16px; border:1px solid #eef2ff; border-radius:12px; background:#fff;">
		                        <div style="display:flex; align-items:center; justify-content:space-between; gap:10px;">
		                          <div style="font-weight:800; font-size:15px;">${r.rvTitle}</div>
		                          <div style="color:#3264ff; font-weight:800; font-size:13px;">⭐ ${r.rvStar}</div>
		                        </div>
		                        <div style="margin-top:6px; font-size:13px; color:#475467; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${r.rvCont}</div>
		                      </div>
		                    </a>
		                  </j:forEach>
		                </j:otherwise>
		              </j:choose>
		            </div>
		        </div>

        <%-- 3. 고정 예약 박스 --%>
        <aside>
            <div class="booking-box">
                <div style="font-size: 14px; color: #777; margin-bottom: 20px;">지금 바로 계획을 세워보세요</div>
                <button class="btn-booking">지금 예약</button>
            </div>
        </aside>
    </div>
</div>

</body>
</html>