<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>고속버스 시간 조회</title>
  <link rel="stylesheet" href="/css/home.css"/>
</head>
<body>
<div class="container" style="padding:24px 0;">
  <h1 style="margin:0 0 14px;">고속버스 운행시간 조회</h1>

  <a href="${pageContext.request.contextPath}/"
     class="btn" style="background:#fff; border:1px solid #e5e7eb;">메인으로</a>

  <form method="get" action="${pageContext.request.contextPath}/transport/expbus"
        style="display:flex; gap:10px; flex-wrap:wrap; align-items:flex-end;">

    <div>
      <div style="font-size:12px; color:#6b7280;">출발일</div>
      <input id="depDate" type="date" class="input" value="${depPlandTimeIso}" required />

      <input type="hidden" name="depPlandTime" id="depPlandTime" value="${depPlandTime}" />
      <input type="hidden" name="depCity" value="${depCity}" />
      <input type="hidden" name="arrCity" value="${arrCity}" />

      <!-- ✅ 터미널 선택값 유지 -->
      <input type="hidden" name="depTerminalId" value="${depTerminalId}" />
      <input type="hidden" name="arrTerminalId" value="${arrTerminalId}" />
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

  <!-- ✅ 출발(도시) -->
  <div style="margin-top:10px;">
    <div style="font-size:12px; color:#6b7280; margin-bottom:6px;">출발 도시</div>
    <div style="display:flex; gap:8px; flex-wrap:wrap;">
      <j:forEach var="c" items="${cities}">
        <a class="btn ${c == depCity ? 'solid' : ''}"
           href="${pageContext.request.contextPath}/transport/expbus?depCity=${c}&arrCity=${arrCity}&depPlandTime=${depPlandTime}&arrTerminalId=${arrTerminalId}">
          ${c}
        </a>
      </j:forEach>
    </div>

    <!-- ✅ 출발 터미널 목록 -->
    <div style="margin-top:10px;">
      <div style="font-size:12px; color:#6b7280; margin-bottom:6px;">출발 터미널</div>
      <j:if test="${empty depTerminals}">
        <div style="color:#6b7280;">터미널 목록을 찾지 못했습니다.</div>
      </j:if>
      <j:if test="${not empty depTerminals}">
        <div style="display:flex; gap:8px; flex-wrap:wrap;">
          <j:forEach var="t" items="${depTerminals}">
            <a class="btn ${t.terminalId == depTerminalId ? 'solid' : ''}"
               href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}&depTerminalId=${t.terminalId}&arrTerminalId=${arrTerminalId}">
              ${t.terminalNm}
            </a>
          </j:forEach>
        </div>
      </j:if>
    </div>
  </div>

  <!-- ✅ 도착(도시) -->
  <div style="margin-top:16px;">
    <div style="font-size:12px; color:#6b7280; margin-bottom:6px;">도착 도시</div>
    <div style="display:flex; gap:8px; flex-wrap:wrap;">
      <j:forEach var="c" items="${cities}">
        <a class="btn ${c == arrCity ? 'solid' : ''}"
           href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${c}&depPlandTime=${depPlandTime}&depTerminalId=${depTerminalId}">
          ${c}
        </a>
      </j:forEach>
    </div>

    <!-- ✅ 도착 터미널 목록 -->
    <div style="margin-top:10px;">
      <div style="font-size:12px; color:#6b7280; margin-bottom:6px;">도착 터미널</div>
      <j:if test="${empty arrTerminals}">
        <div style="color:#6b7280;">터미널 목록을 찾지 못했습니다.</div>
      </j:if>
      <j:if test="${not empty arrTerminals}">
        <div style="display:flex; gap:8px; flex-wrap:wrap;">
          <j:forEach var="t" items="${arrTerminals}">
            <a class="btn ${t.terminalId == arrTerminalId ? 'solid' : ''}"
               href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}&depTerminalId=${depTerminalId}&arrTerminalId=${t.terminalId}">
              ${t.terminalNm}
            </a>
          </j:forEach>
        </div>
      </j:if>
    </div>
  </div>

  <div style="margin-top:14px; background:#fff; border:1px solid #e5e7eb; border-radius:16px;
              box-shadow:0 10px 30px rgba(0,0,0,0.08); padding:16px; overflow:hidden;">

    <j:if test="${not empty errorMsg}">
      <div style="color:#ef4444; margin-bottom:10px;">${errorMsg}</div>
    </j:if>

    <j:if test="${empty depTerminalId || empty arrTerminalId}">
      <div style="color:#6b7280;">출발/도착 터미널을 선택하면 운행 목록이 표시됩니다.</div>
    </j:if>

    <j:if test="${not empty depTerminalId && not empty arrTerminalId}">
      <j:if test="${empty result}">
        <div style="color:#6b7280;">조회 결과가 없습니다.</div>
      </j:if>

      <j:if test="${not empty result}">
        <div style="overflow:auto;">
          <table style="width:100%; border-collapse:collapse; margin-top:6px; background:#fff;">
            <thead>
            <tr style="text-align:left; color:#6b7280; font-size:12px; background:#f8fafc;">
              <th style="padding:10px 8px;">등급</th>
              <th style="padding:10px 8px;">출발시각</th>
              <th style="padding:10px 8px;">도착시각</th>
              <th style="padding:10px 8px;">요금</th>
            </tr>
            </thead>

            <tbody>
            <j:forEach var="r" items="${result}">
              <tr style="border-top:1px solid #f1f5f9;">
                <td style="padding:10px 8px;">${r.gradeText}</td>
                <td style="padding:10px 8px;">${r.depTimeText}</td>
                <td style="padding:10px 8px;">${r.arrTimeText}</td>
                <td style="padding:10px 8px;">${r.chargeText}</td>
              </tr>
            </j:forEach>
            </tbody>
          </table>

          <!-- ✅ 페이지네이션: terminalId까지 유지 -->
          <div style="margin-top:16px; display:flex; gap:6px; flex-wrap:wrap; justify-content:center;">
            <j:forEach begin="1" end="${totalPages}" var="p">
              <a class="btn ${p == currentPage ? 'solid' : ''}"
                 href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}&depTerminalId=${depTerminalId}&arrTerminalId=${arrTerminalId}&page=${p}">
                ${p}
              </a>
            </j:forEach>
          </div>
        </div>
      </j:if>
    </j:if>

  </div>
</div>
</body>
</html>
