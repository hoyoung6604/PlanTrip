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

    <div class="tp-tabs">
      <a class="tp-tab is-active" href="${pageContext.request.contextPath}/transport/flight">항공권</a>
      <a class="tp-tab" href="${pageContext.request.contextPath}/transport/expbus">버스</a>
      <a class="tp-tab" href="${pageContext.request.contextPath}/transport/train">기차</a>
    </div>

    <!-- 검색 -->
    <div class="tp-card">
      <div class="tp-card-h">
        <p class="tp-card-title">검색</p>
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
      <div class="tp-card-h">
        <p class="tp-card-title">조회 결과</p>
        
      </div>
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
