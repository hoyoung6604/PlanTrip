<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>항공권 시간 조회</title>

  <link rel="stylesheet" href="/css/header.css" />
  <link rel="stylesheet" href="/css/transport.css" />
  <script defer src="/js/nav-wave.js"></script>
  <script defer src="/js/transport.js"></script>
</head>
<body class="page-solid tp-page" data-tp-mode="flight">
  <jsp:include page="/WEB-INF/views/common/header.jsp" />

  <div class="tp-wrap">
    <div class="tp-breadcrumb">
      <a href="${pageContext.request.contextPath}/">메인</a>
      <span>›</span>
      <span>교통수단</span>
      <span>›</span>
      <span>항공권</span>
    </div>

    <div class="tp-head">
      <div>
        <h1 class="tp-title">항공권 조회</h1>
        <p class="tp-sub">제주 ↔ 국내 전 공항 운항편을 날짜 기준으로 확인할 수 있습니다.</p>
      </div>
</div>
<!-- 검색 -->
    <div class="tp-card">
<div class="tp-tabs2" role="tablist" aria-label="교통수단">
  <a class="tp-tab2 is-active" href="${pageContext.request.contextPath}/transport/flight?depAirport=${depAirport}&arrAirport=${arrAirport}&depPlandTime=${depPlandTime}"><span class="tp-tab2__icon"><svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 0 0-3 0V9L2 14v2l8-2.5V19l-2 1.5V22l3-1 3 1v-1.5L13 19v-5.5l8 2.5Z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg></span><span class="tp-tab2__label">항공권</span></a>
  <a class="tp-tab2" href="${pageContext.request.contextPath}/transport/expbus?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}"><span class="tp-tab2__icon"><svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h12a2 2 0 0 1 2 2v11a3 3 0 0 1-3 3H7a3 3 0 0 1-3-3V5a2 2 0 0 1 2-2z" fill="none" stroke="currentColor" stroke-width="1.8"/><path d="M4 10h16" fill="none" stroke="currentColor" stroke-width="1.8"/><path d="M7.5 19.5v1.5M16.5 19.5v1.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><circle cx="8" cy="16" r="1" fill="currentColor"/><circle cx="16" cy="16" r="1" fill="currentColor"/></svg></span><span class="tp-tab2__label">버스</span></a>
  <a class="tp-tab2" href="${pageContext.request.contextPath}/transport/train?depCity=${depCity}&arrCity=${arrCity}&depPlandTime=${depPlandTime}"><span class="tp-tab2__icon"><svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h12a2 2 0 0 1 2 2v10a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4V5a2 2 0 0 1 2-2z" fill="none" stroke="currentColor" stroke-width="1.8"/><path d="M8 19l-2 2M16 19l2 2" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M7 8h10M7 12h10" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><circle cx="9" cy="16" r="1" fill="currentColor"/><circle cx="15" cy="16" r="1" fill="currentColor"/></svg></span><span class="tp-tab2__label">기차</span></a>
</div>
<div class="tp-body">
        
        <form method="get" action="${pageContext.request.contextPath}/transport/flight/search">
          <div class="tp-form-panel">
            <!-- 검색 바 (공통 UI) -->
            <div class="tp-searchbar tp-searchbar--flight">
              <div class="tp-searchbar__loc">
                <div class="tp-field">
                  <div class="tp-field__label">출발 공항</div>
                  <input class="tp-field__input" type="text" id="tpDepAirportText" readonly />
                </div>

                <button type="button" class="tp-swap-btn" data-tp-swap-air aria-label="출발/도착 바꾸기">⇄</button>

                <div class="tp-field">
                  <div class="tp-field__label">도착 공항</div>
                  <input class="tp-field__input" type="text" id="tpArrAirportText" readonly />
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

            <div class="tp-help">날짜/공항 변경 시 자동 조회됩니다.</div>

            <div class="tp-grid" style="margin-top:14px;">
              <div class="tp-col-6">
                <div class="tp-label">출발 공항</div>
                <div class="tp-chip-row tp-chip-row-scroll" data-tp-air-chips="depAirportId">
                  <button type="button"
                          class="tp-chip ${'NAARKPC' == (empty depAirportId ? 'NAARKPC' : depAirportId) ? 'is-active' : ''}"
                          data-air-id="NAARKPC">제주</button>
                  <j:forEach var="a" items="${airports}">
                    <j:if test="${a.key != 'NAARKPC'}">
                      <button type="button"
                              class="tp-chip ${a.key == (empty depAirportId ? 'NAARKPC' : depAirportId) ? 'is-active' : ''}"
                              data-air-id="${a.key}">
                        ${a.value}
                      </button>
                    </j:if>
                  </j:forEach>
                </div>
              </div>

              <div class="tp-col-6">
                <div class="tp-label">도착 공항</div>
                <div class="tp-chip-row tp-chip-row-scroll" data-tp-air-chips="arrAirportId">
                  <button type="button"
                          class="tp-chip ${'NAARKPC' == (empty arrAirportId ? selectedAirportId : arrAirportId) ? 'is-active' : ''}"
                          data-air-id="NAARKPC">제주</button>
                  <j:forEach var="a" items="${airports}">
                    <j:if test="${a.key != 'NAARKPC'}">
                      <button type="button"
                              class="tp-chip ${a.key == (empty arrAirportId ? selectedAirportId : arrAirportId) ? 'is-active' : ''}"
                              data-air-id="${a.key}">
                        ${a.value}
                      </button>
                    </j:if>
                  </j:forEach>
                </div>
              </div>
            </div>

            <input type="hidden" name="depAirportId" id="depAirportId" value="${empty depAirportId ? 'NAARKPC' : depAirportId}" />
            <input type="hidden" name="arrAirportId" id="arrAirportId" value="${empty arrAirportId ? selectedAirportId : arrAirportId}" />
          </div>
        </form>

      </div>
    </div>
    </div>

    <!-- 결과 -->
    <div class="tp-card">
<div class="tp-body">
        <j:if test="${empty result}">
          <div class="tp-empty">조회 결과가 없습니다.</div>
        </j:if>

        <j:if test="${not empty result}">
          <div class="tp-table-wrap">
            <table class="tp-table">
              <thead>
              <tr>
                <th>편명</th>
                <th>항공사</th>
                <th>출발공항</th>
                <th>도착공항</th>
                <th>출발시각</th>
                <th>도착시각</th>
              </tr>
              </thead>
              <tbody>
              <j:forEach var="r" items="${result}">
                <tr>
                  <td>${r.vihicleId}</td>
                  <td>${r.airlineNm}</td>
                  <td>${r.depAirportNm}</td>
                  <td>${r.arrAirportNm}</td>
                  <td>${r.depTimeText}</td>
                  <td>${r.arrTimeText}</td>
                </tr>
              </j:forEach>
              </tbody>
            </table>
          </div>

          <div class="tp-pagination">
    <j:forEach begin="1" end="${totalPages}" var="p">
      <j:if test="${not empty depAirportId && not empty arrAirportId}">
        <a class="tp-pagebtn ${p == currentPage ? 'is-active' : ''}"
           href="${pageContext.request.contextPath}/transport/flight/search?depAirportId=${depAirportId}&arrAirportId=${arrAirportId}&depPlandTime=${depPlandTime}&page=${p}">
          ${p}
        </a>
      </j:if>
      <j:if test="${empty depAirportId || empty arrAirportId}">
        <a class="tp-pagebtn ${p == currentPage ? 'is-active' : ''}"
           href="${pageContext.request.contextPath}/transport/flight?airportId=${selectedAirportId}&depPlandTime=${depPlandTime}&direction=${direction}&page=${p}">
          ${p}
        </a>
      </j:if>
    </j:forEach>
  </div>
</j:if>
      </div>
    </div>

  </div>

  <%@ include file="/WEB-INF/views/common/footer.jspf" %>
</body>
</html>
