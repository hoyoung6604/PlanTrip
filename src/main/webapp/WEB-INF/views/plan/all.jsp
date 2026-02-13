<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${city.name} - 전체보기</title>
    <style>
        body { font-family: 'Pretendard', sans-serif; background-color: #f8f9fa; margin: 0; }
        .container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; }
        
        .header-section { margin-bottom: 40px; }
        .category-title { font-size: 28px; font-weight: 800; color: #333; }
        .city-name { color: #3264ff; }

        /* 격자 레이아웃: 한 줄에 4개씩 */
        .spot-grid { 
            display: grid; 
            grid-template-columns: repeat(4, 1fr); 
            gap: 25px; 
        }

        .card { 
            background: white; border-radius: 16px; overflow: hidden; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); transition: 0.3s;
            cursor: pointer; text-decoration: none; color: inherit;
            display: block;
        }
        .card:hover { transform: translateY(-8px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
        
        .img-box { height: 200px; background-color: #eee; background-size: cover; background-position: center; }
        
        .info-box { padding: 20px; }
        .spot-title { font-size: 18px; font-weight: 700; margin-bottom: 8px; color: #333; }
        .spot-addr { font-size: 14px; color: #777; line-height: 1.4; }
    </style>
</head>
<body>

<div class="container">
	<div class="header-section">
	    <a href="${pageContext.request.contextPath}/spots/list?cityId=${selectedCity}" 
	       style="text-decoration: none; color: #888; font-size: 14px; display: inline-block; margin-bottom: 15px; font-weight: bold;">
	       &lt; 뒤로가기
	    </a>
	    
	    <div class="category-title">
	        <span class="city-name">${city.name}</span> 
	        <j:choose>
	            <j:when test="${catCode eq 'TOUR'}">인기 관광지</j:when>
	            <j:when test="${catCode eq 'STAY'}">추천 숙소</j:when>
	            <j:when test="${catCode eq 'ACT'}">문화/액티비티</j:when>
	            <j:when test="${catCode eq 'FOOD'}">추천 맛집</j:when>
	        </j:choose>
	        전체보기
	    </div>
	</div>

    <div class="spot-grid">
        <j:forEach var="s" items="${spotList}">
            <a href="${pageContext.request.contextPath}/spots/detail/${s.id}" class="card">
                <%-- 임시로 hero.jpg를 사용하고, 나중에 DB 이미지 필드 추가 시 변경 가능 --%>
                <div class="img-box" style="background-image: url('${pageContext.request.contextPath}/img/hero.jpg');"></div>
                <div class="info-box">
                    <div class="spot-title">${s.name}</div>
                    <div class="spot-addr">${s.addr}</div>
                </div>
            </a>
        </j:forEach>
    </div>
    
    <j:if test="${empty spotList}">
        <div style="text-align: center; padding: 100px 0; color: #999;">
            등록된 장소가 없습니다.
        </div>
    </j:if>
</div>

</body>
</html>