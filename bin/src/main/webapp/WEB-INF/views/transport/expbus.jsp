<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>버스 운행시간 조회</title>

  <link rel="stylesheet" href="/css/header.css" />
  <link rel="stylesheet" href="/css/transport.css" />
  <script defer src="/js/nav-wave.js"></script>
  <script defer src="/js/transport.js"></script>
</head>
<body class="page-solid tp-page" data-tp-mode="expbus">
  <jsp:include page="/WEB-INF/views/common/header.jsp" />

  <div class="tp-wrap">
    <div class="tp-breadcrumb">
      <a href="${pageContext.request.contextPath}/">메인</a>
      <span>›</span>
      <span>교통수단</span>
      <span>›</span>
      <span>버스</span>
    </div>

    <div class="tp-head">
      <div>
        <h1 class="tp-title">버스 운행시간 조회</h1>
        <p class="tp-sub">출발/도착 터미널을 선택하면 운행 목록이 표시됩니다.</p>
      </div>
</div>

    <div class="tp-tabs">
      <a class="tp-tab" href="${pageContext.request.contextPath}/transport/flight">항공권</a>
      <a class="tp-tab is-active" href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}">버스</a>
      <a class="tp-tab" href="${pageContext.request.contextPath}/transport/train">기차</a>
    </div>

    <!-- 검색 -->
    <div class="tp-card">
      <div class="tp-card-h">
        <p class="tp-card-title">검색</p>
      </div>
      <div class="tp-body">
        <form method="get" action="${pageContext.request.contextPath}/transport/expbus">
          <div class="tp-form-panel">
            <!-- 검색 바 (공통 UI) -->
            <div class="tp-searchbar">
              <div class="tp-searchbar__loc">
                <div class="tp-field">
                  <div class="tp-field__label">출발지</div>
                  <input class="tp-field__input" type="text" value="${depCity}" readonly />
                </div>

                <button type="button" class="tp-swap-btn" data-tp-swap-city aria-label="출발/도착 바꾸기">⇄</button>

                <div class="tp-field">
                  <div class="tp-field__label">도착지</div>
                  <input class="tp-field__input" type="text" value="${arrCity}" readonly />
                </div>
              </div>

              <div class="tp-searchbar__date">
                <div class="tp-field">
                  <div class="tp-field__label">출발일</div>
                  <input id="depDate" data-tp-date-text type="text" readonly class="tp-input tp-input--bar" value="${depPlandTimeIso}" required data-tp-hidden="depPlandTime" />
                  <input type="hidden" name="depPlandTime" id="depPlandTime" value="${depPlandTime}" />
                </div>
              </div>

              <div class="tp-searchbar__action">
                <button class="tp-btn-primary" type="submit">검색</button>
              </div>
            </div>

            <!-- 현재 선택값 유지 -->
            <input type="hidden" name="depCity" value="${depCity}" />
            <input type="hidden" name="arrCity" value="${arrCity}" />
            <input type="hidden" name="depTerminalId" value="${depTerminalId}" />
            <input type="hidden" name="arrTerminalId" value="${arrTerminalId}" />

            <div class="tp-help">날짜를 변경하면 자동 조회됩니다.</div>
          

<div class="tp-grid" style="margin-top:14px;">
          <div class="tp-col-6">
            <div class="tp-label">출발 도시</div>
            <div class="tp-chip-row" data-tp-city-row="dep">
              <j:forEach var="c" items="${cities}">
                <a class="tp-chip ${c == depCity ? 'is-active' : ''}"
                   href="${pageContext.request.contextPath}/transport/expbus?depCity=${c}&arrCity=${arrCity}&depPlandTime=${depPlandTime}&arrTerminalId=${arrTerminalId}">
                  ${c}
                </a>
              </j:forEach>
            </div>

            <div style="margin-top:12px;">
              <div class="tp-label">출발 터미널</div>
              <j:if test="${empty depTerminals}">
                <div class="tp-empty">터미널 목록을 찾지 못했습니다.</div>
              </j:if>
              <j:if test="${not empty depTerminals}">
                <div class="tp-chip-row">
                  <j:forEach var="t" items="${depTerminals}">
                    <a class="tp-chip ${t.terminalId == depTerminalId ? 'is-active' : ''}"
                       href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}&depTerminalId=${t.terminalId}&arrTerminalId=${arrTerminalId}">
                      ${t.terminalNm}
                    </a>
                  </j:forEach>
                </div>
              </j:if>
            </div>
          </div>

          <div class="tp-col-6">
            <div class="tp-label">도착 도시</div>
            <div class="tp-chip-row" data-tp-city-row="arr">
              <j:forEach var="c" items="${cities}">
                <a class="tp-chip ${c == arrCity ? 'is-active' : ''}"
                   href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${c}&depPlandTime=${depPlandTime}&depTerminalId=${depTerminalId}">
                  ${c}
                </a>
              </j:forEach>
            </div>

            <div style="margin-top:12px;">
              <div class="tp-label">도착 터미널</div>
              <j:if test="${empty arrTerminals}">
                <div class="tp-empty">터미널 목록을 찾지 못했습니다.</div>
              </j:if>
              <j:if test="${not empty arrTerminals}">
                <div class="tp-chip-row">
                  <j:forEach var="t" items="${arrTerminals}">
                    <a class="tp-chip ${t.terminalId == arrTerminalId ? 'is-active' : ''}"
                       href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}&depTerminalId=${depTerminalId}&arrTerminalId=${t.terminalId}">
                      ${t.terminalNm}
                    </a>
                  </j:forEach>
                </div>
              </j:if>
            </div>
          </div>
        </div>
</div>
        </form>

        
      </div>
    </div>

    <!-- 결과 -->
    <div class="tp-card">
      <div class="tp-card-h">
        <p class="tp-card-title">조회 결과</p>
        
      </div>
      <div class="tp-body">
        <!-- 에러/빈 결과 문구 통일: '조회 결과가 없습니다.' -->
        <j:if test="${not empty errorMsg}">
          <div class="tp-empty">조회 결과가 없습니다.</div>
        </j:if>

        <j:if test="${empty depTerminalId || empty arrTerminalId}">
          <div class="tp-empty">출발/도착 터미널을 선택하면 운행 목록이 표시됩니다.</div>
        </j:if>

        <j:if test="${not empty depTerminalId && not empty arrTerminalId}">
          <j:if test="${empty result and empty errorMsg}">
            <div class="tp-empty">조회 결과가 없습니다.</div>
          </j:if>

          <j:if test="${not empty result}">
            <div class="tp-table-wrap">
              <table class="tp-table">
                <thead>
                <tr>
                  <th>등급</th>
                  <th>출발시각</th>
                  <th>도착시각</th>
                  <th>요금</th>
                </tr>
                </thead>
                <tbody>
                <j:forEach var="r" items="${result}">
                  <tr>
                    <td>
  <j:choose>
    <j:when test="${r.gradeText == '우등'}"><span class="tp-badge tp-badge-blue">우등</span></j:when>
    <j:when test="${r.gradeText == '일반'}"><span class="tp-badge tp-badge-green">일반</span></j:when>
    <j:when test="${r.gradeText == '프리미엄'}"><span class="tp-badge tp-badge-purple">프리미엄</span></j:when>
    <j:otherwise><span class="tp-badge">${r.gradeText}</span></j:otherwise>
  </j:choose>
</td>
                    <td>${r.depTimeText}</td>
                    <td>${r.arrTimeText}</td>
                    <td>${r.chargeText}</td>
                  </tr>
                </j:forEach>
                </tbody>
              </table>
            </div>

            <div class="tp-pagination">
              <j:forEach begin="1" end="${totalPages}" var="p">
                <a class="tp-pagebtn ${p == currentPage ? 'is-active' : ''}"
                   href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}&depTerminalId=${depTerminalId}&arrTerminalId=${arrTerminalId}&page=${p}">
                  ${p}
                </a>
              </j:forEach>
            </div>
          </j:if>
        </j:if>
      </div>
    </div>

  </div>

  <%@ include file="/WEB-INF/views/common/footer.jspf" %>
</body>
</html>
