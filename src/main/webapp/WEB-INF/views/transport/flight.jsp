<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>항공권 시간 조회</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>
<div class="container" style="padding:24px 0;">
  <h1 style="margin:0 0 14px;">제주 ↔ 국내 전 공항 운항편</h1>
  <a href="${pageContext.request.contextPath}/"
       class="btn"
       style="background:#fff; border:1px solid #e5e7eb;">
      메인으로
    </a>
  <form method="get" action="${pageContext.request.contextPath}/transport/flight"
        style="display:flex; gap:10px; flex-wrap:wrap; align-items:flex-end;">
    <div>
	  <div>
	    <div style="font-size:12px; color:#6b7280;">출발일</div>

	    <!-- 달력 input: value는 yyyy-MM-dd -->
	    <input id="depDate"
	           type="date"
	           class="input"
	           value="${depPlandTimeIso}"
	           required />
	  </div>

	  <!-- ✅ 출발방향 토글 -->
	  <div style="margin-top:10px; display:flex; gap:8px; flex-wrap:wrap;">
	    <a class="btn ${direction eq 'JEJU_OUT' ? 'solid' : ''}"
	       href="${pageContext.request.contextPath}/transport/flight?airportId=${selectedAirportId}&depPlandTime=${depPlandTime}&direction=JEJU_OUT">
	      제주 출발
	    </a>

	    <a class="btn ${direction eq 'JEJU_IN' ? 'solid' : ''}"
	       href="${pageContext.request.contextPath}/transport/flight?airportId=${selectedAirportId}&depPlandTime=${depPlandTime}&direction=JEJU_IN">
	      선택공항 출발
	    </a>
	  </div>

	  <!-- depPlandTime(YYYYMMDD)를 서버로 보낼 hidden -->
	  <input type="hidden" name="depPlandTime" id="depPlandTime" value="${depPlandTime}" />

	  <!-- airportId 유지 -->
	  <input type="hidden" name="airportId" value="${selectedAirportId}" />

	  <script>
	    (function () {
	      const depDate = document.getElementById('depDate');
	      const depPlandTime = document.getElementById('depPlandTime');

	      function toYYYYMMDD(iso) {
	        // "2026-02-17" -> "20260217"
	        return iso ? iso.replaceAll('-', '') : '';
	      }

	      depDate.addEventListener('change', function () {
	        depPlandTime.value = toYYYYMMDD(depDate.value);

	        // ✅ 날짜 클릭/선택 즉시 자동 검색되게
	        depDate.form.submit();
	      });
	    })();
	  </script>
    </div>
  </form>

  <!-- ✅ 공항 버튼들 -->
  <div style="margin-top:10px; display:flex; gap:8px; flex-wrap:wrap;">
    <j:forEach var="a" items="${airports}">
      <a class="btn ${a.key == selectedAirportId ? 'solid' : ''}"
         href="${pageContext.request.contextPath}/transport/flight?airportId=${a.key}&depPlandTime=${depPlandTime}">
        ${a.value}
      </a>
    </j:forEach>
  </div>
  <div style="margin-top:14px;
              background:#fff;
              border:1px solid #e5e7eb;
              border-radius:16px;
              box-shadow:0 10px 30px rgba(0,0,0,0.08);
              padding:16px;
              overflow:hidden;">
    <j:if test="${empty result}">
      <div style="color:#6b7280;">조회 결과가 없습니다.</div>
    </j:if>
    <j:if test="${not empty result}">
      <div style="overflow:auto;">
        <table style="width:100%; border-collapse:collapse; margin-top:6px; background:#fff;">
          <thead>
          <tr style="text-align:left; color:#6b7280; font-size:12px; background:#f8fafc;">
            <th style="padding:10px 8px;">편명</th>
            <th style="padding:10px 8px;">항공사</th>
            <th style="padding:10px 8px;">출발공항</th>
            <th style="padding:10px 8px;">도착공항</th>
            <th style="padding:10px 8px;">출발시각</th>
            <th style="padding:10px 8px;">도착시각</th>
          </tr>
          </thead>

          <tbody>
          <j:forEach var="r" items="${result}">
            <tr style="border-top:1px solid #f1f5f9;">
              <td style="padding:10px 8px;">${r.vihicleId}</td>
              <td style="padding:10px 8px;">${r.airlineNm}</td>
              <td style="padding:10px 8px;">${r.depAirportNm}</td>
              <td style="padding:10px 8px;">${r.arrAirportNm}</td>
              <td style="padding:10px 8px;">${r.depTimeText}</td>
              <td style="padding:10px 8px;">${r.arrTimeText}</td>
            </tr>
          </j:forEach>
          </tbody>
        </table>
		<div style="margin-top:16px; display:flex; gap:6px; flex-wrap:wrap; justify-content:center;">
		  <j:forEach begin="1" end="${totalPages}" var="p">
		    <a class="btn ${p == currentPage ? 'solid' : ''}"
		       href="${pageContext.request.contextPath}/transport/flight?airportId=${selectedAirportId}&depPlandTime=${depPlandTime}&page=${p}">
		      ${p}
		    </a>
		  </j:forEach>
		</div>

      </div>
    </j:if>
  </div>
</div>
</body>
</html>
