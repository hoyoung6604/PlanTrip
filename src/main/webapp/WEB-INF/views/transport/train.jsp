<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>기차 시간 조회</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>
<div class="container" style="padding:24px 0;">
  <h1 style="margin:0 0 14px;">기차 운행시간 조회</h1>

  <a href="${pageContext.request.contextPath}/"
     class="btn" style="background:#fff; border:1px solid #e5e7eb;">메인으로</a>

  <form method="get" action="${pageContext.request.contextPath}/transport/train"
        style="display:flex; gap:10px; flex-wrap:wrap; align-items:flex-end;">

    <div>
      <div style="font-size:12px; color:#6b7280;">출발일</div>

      <!-- 달력: value는 yyyy-MM-dd -->
      <input id="depDate" type="date" class="input" value="${depPlandTimeIso}" required />

      <!-- 서버로 보낼 YYYYMMDD -->
      <input type="hidden" name="depPlandTime" id="depPlandTime" value="${depPlandTime}" />

      <!-- ✅ 컨트롤러 파라미터와 일치 -->
      <input type="hidden" name="depCity" value="${depCity}" />
      <input type="hidden" name="arrCity" value="${arrCity}" />
    </div>

    <script>
      (function () {
        const depDate = document.getElementById('depDate');
        const depPlandTime = document.getElementById('depPlandTime');
        function toYYYYMMDD(iso) { return iso ? iso.replaceAll('-', '') : ''; }

        depDate.addEventListener('change', function () {
          depPlandTime.value = toYYYYMMDD(depDate.value);
          depDate.form.submit();
        });
      })();
    </script>
  </form>

  <!-- ✅ 출발역(도시) 버튼 -->
  <div style="margin-top:10px;">
    <div style="font-size:12px; color:#6b7280; margin-bottom:6px;">출발</div>
    <div style="display:flex; gap:8px; flex-wrap:wrap;">
      <j:forEach var="c" items="${cities}">
        <a class="btn ${c == depCity ? 'solid' : ''}"
           href="${pageContext.request.contextPath}/transport/train?depCity=${c}&arrCity=${arrCity}&depPlandTime=${depPlandTime}">
          ${c}
        </a>
      </j:forEach>
    </div>
  </div>

  <!-- ✅ 도착역(도시) 버튼 -->
  <div style="margin-top:10px;">
    <div style="font-size:12px; color:#6b7280; margin-bottom:6px;">도착</div>
    <div style="display:flex; gap:8px; flex-wrap:wrap;">
      <j:forEach var="c" items="${cities}">
        <a class="btn ${c == arrCity ? 'solid' : ''}"
           href="${pageContext.request.contextPath}/transport/train?depCity=${depCity}&arrCity=${c}&depPlandTime=${depPlandTime}">
          ${c}
        </a>
      </j:forEach>
    </div>
  </div>

  <div style="margin-top:14px; background:#fff; border:1px solid #e5e7eb; border-radius:16px;
              box-shadow:0 10px 30px rgba(0,0,0,0.08); padding:16px; overflow:hidden;">

    <!-- ✅ 서비스/컨트롤러에서 errorMsg 내려줄 수 있게 처리 -->
    <j:if test="${not empty errorMsg}">
      <div style="color:#ef4444; margin-bottom:10px;">${errorMsg}</div>
    </j:if>

    <j:if test="${empty result}">
      <div style="color:#6b7280;">조회 결과가 없습니다.</div>
    </j:if>

    <j:if test="${not empty result}">
      <div style="overflow:auto;">
        <table style="width:100%; border-collapse:collapse; margin-top:6px; background:#fff;">
          <thead>
          <tr style="text-align:left; color:#6b7280; font-size:12px; background:#f8fafc;">
            <th style="padding:10px 8px;">종류</th>
            <th style="padding:10px 8px;">열차번호</th>
            <th style="padding:10px 8px;">출발</th>
            <th style="padding:10px 8px;">도착</th>
            <th style="padding:10px 8px;">출발시각</th>
            <th style="padding:10px 8px;">도착시각</th>
            <th style="padding:10px 8px;">요금</th>
          </tr>
          </thead>
          <tbody>
          <j:forEach var="r" items="${result}">
            <tr style="border-top:1px solid #f1f5f9;">
              <td style="padding:10px 8px;">${r.trainTypeText}</td>
              <td style="padding:10px 8px;">${r.trainNoText}</td>
              <td style="padding:10px 8px;">${depCity}</td>
              <td style="padding:10px 8px;">${arrCity}</td>
              <td style="padding:10px 8px;">${r.depTimeText}</td>
              <td style="padding:10px 8px;">${r.arrTimeText}</td>
              <td style="padding:10px 8px;">${r.chargeText}</td>
            </tr>
          </j:forEach>
          </tbody>
        </table>

        <!-- ✅ 페이지네이션: depCity/arrCity로 유지해야 함 -->
        <div style="margin-top:16px; display:flex; gap:6px; flex-wrap:wrap; justify-content:center;">
          <j:forEach begin="1" end="${totalPages}" var="p">
            <a class="btn ${p == currentPage ? 'solid' : ''}"
               href="${pageContext.request.contextPath}/transport/train?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}&page=${p}">
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