<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>상세 일정</title>
  <link rel="stylesheet" href="<c:url value='/css/plan.css'/>" />
</head>
<body>

  <div style="margin-bottom:14px;">
    <a href="${pageContext.request.contextPath}/plans">← 내 일정 목록</a>
  </div>

  <div class="pt-section">
    <div class="pt-section-head">
      <div class="pt-badge">B</div>
      <div class="pt-title">상세 일정</div>
      <div class="pt-sub"><c:out value="${detailNote}" /></div>
    </div>

    <!-- ✅ 기본정보(상세일정에 포함) -->
    <div class="day-card">
      <div class="day-title">기본 정보</div>

      <!-- 일정 제목 -->
      <div class="field pt-detail-field">
        <div class="pt-detail-head">
          <label>일정 제목</label>
          <button type="button" class="pt-mini-btn" data-action="edit">수정</button>
        </div>
        <div class="value pt-detail-value"><c:out value="${plan.PTitle}" /></div>
        <form method="post" action="${pageContext.request.contextPath}/plans/meta/update" class="pt-edit-form" hidden>
          <input type="hidden" name="pIdx" value="${param.pIdx}" />
          <input type="hidden" name="field" value="title" />
          <input type="text" name="value" class="pt-edit-input" value="<c:out value='${plan.PTitle}'/>" />
          <div class="pt-edit-actions">
            <button type="submit" class="pt-mini-btn primary">저장</button>
            <button type="button" class="pt-mini-btn" data-action="cancel">취소</button>
          </div>
        </form>
      </div>

      <!-- 출발날짜(필수) -->
      <div class="field pt-detail-field">
        <div class="pt-detail-head">
          <label>출발 날짜(필수)</label>
          <button type="button" class="pt-mini-btn" data-action="edit">수정</button>
        </div>
        <div class="value pt-detail-value"><c:out value="${viewStart}" /></div>
        <form method="post" action="${pageContext.request.contextPath}/plans/meta/update" class="pt-edit-form" hidden>
          <input type="hidden" name="pIdx" value="${param.pIdx}" />
          <input type="hidden" name="field" value="start" />
          <input type="text" name="value" class="pt-edit-input" placeholder="YYYY-MM-DD 또는 -" value="<c:out value='${viewStart}'/>" />
          <div class="pt-edit-actions">
            <button type="submit" class="pt-mini-btn primary">저장</button>
            <button type="button" class="pt-mini-btn" data-action="cancel">취소</button>
          </div>
        </form>
      </div>

      <!-- 종료일 -->
      <div class="field pt-detail-field">
        <div class="pt-detail-head">
          <label>종료일</label>
          <button type="button" class="pt-mini-btn" data-action="edit">수정</button>
        </div>
        <div class="value pt-detail-value"><c:out value="${viewEnd}" /></div>
        <form method="post" action="${pageContext.request.contextPath}/plans/meta/update" class="pt-edit-form" hidden>
          <input type="hidden" name="pIdx" value="${param.pIdx}" />
          <input type="hidden" name="field" value="end" />
          <input type="text" name="value" class="pt-edit-input" placeholder="YYYY-MM-DD 또는 -" value="<c:out value='${viewEnd}'/>" />
          <div class="pt-edit-actions">
            <button type="submit" class="pt-mini-btn primary">저장</button>
            <button type="button" class="pt-mini-btn" data-action="cancel">취소</button>
          </div>
        </form>
      </div>

      <!-- 여행목적 -->
      <div class="field pt-detail-field">
        <div class="pt-detail-head">
          <label>여행 목적</label>
          <button type="button" class="pt-mini-btn" data-action="edit">수정</button>
        </div>
        <div class="value pt-detail-value">
          <c:choose>
            <c:when test="${empty mem || empty mem.goals}">-</c:when>
            <c:otherwise><c:out value="${mem.goals}" /></c:otherwise>
          </c:choose>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/plans/meta/update" class="pt-edit-form" hidden>
          <input type="hidden" name="pIdx" value="${param.pIdx}" />
          <input type="hidden" name="field" value="goals" />
          <input type="text" name="value" class="pt-edit-input" value="<c:out value='${mem.goals}'/>" />
          <div class="pt-edit-actions">
            <button type="submit" class="pt-mini-btn primary">저장</button>
            <button type="button" class="pt-mini-btn" data-action="cancel">취소</button>
          </div>
        </form>
      </div>

      <!-- 이동수단 -->
      <div class="field pt-detail-field">
        <div class="pt-detail-head">
          <label>이동 수단</label>
          <button type="button" class="pt-mini-btn" data-action="edit">수정</button>
        </div>
        <div class="value pt-detail-value">
          <c:choose>
            <c:when test="${empty mem || empty mem.transport}">-</c:when>
            <c:otherwise><c:out value="${mem.transport}" /></c:otherwise>
          </c:choose>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/plans/meta/update" class="pt-edit-form" hidden>
          <input type="hidden" name="pIdx" value="${param.pIdx}" />
          <input type="hidden" name="field" value="transport" />
          <input type="text" name="value" class="pt-edit-input" value="<c:out value='${mem.transport}'/>" />
          <div class="pt-edit-actions">
            <button type="submit" class="pt-mini-btn primary">저장</button>
            <button type="button" class="pt-mini-btn" data-action="cancel">취소</button>
          </div>
        </form>
      </div>
    </div>

    <!-- ✅ Day 상세 -->
    <c:forEach var="d" items="${details}">
      <div class="day-card">
        <div class="day-title"><c:out value="${d.dayTitle}" /></div>

        <!-- 코스(선택) -->
        <div class="field pt-detail-field">
          <div class="pt-detail-head">
            <label>Day 코스(선택)</label>
            <div class="pt-detail-actions">
              <button type="button" class="pt-mini-btn" data-action="edit">수정</button>
              <form method="post" action="${pageContext.request.contextPath}/plans/detail/delete" class="pt-inline">
                <input type="hidden" name="pIdx" value="${param.pIdx}" />
                <input type="hidden" name="dayNo" value="${d.dayNo}" />
                <input type="hidden" name="field" value="course" />
                <button type="submit" class="pt-mini-btn danger" onclick="return confirm('삭제하면 - 로 바뀝니다. 삭제할까요?');">삭제</button>
              </form>
            </div>
          </div>
          <div class="value pt-detail-value"><c:out value="${d.course}" /></div>

          <form method="post" action="${pageContext.request.contextPath}/plans/detail/update" class="pt-edit-form" hidden>
            <input type="hidden" name="pIdx" value="${param.pIdx}" />
            <input type="hidden" name="dayNo" value="${d.dayNo}" />
            <input type="hidden" name="field" value="course" />
            <input type="text" name="value" class="pt-edit-input" value="<c:out value='${d.course}'/>" />
            <div class="pt-edit-actions">
              <button type="submit" class="pt-mini-btn primary">저장</button>
              <button type="button" class="pt-mini-btn" data-action="cancel">취소</button>
            </div>
          </form>
        </div>

        <!-- 일정(필수) -->
        <div class="field pt-detail-field">
          <div class="pt-detail-head">
            <label>일정(필수)</label>
            <div class="pt-detail-actions">
              <button type="button" class="pt-mini-btn" data-action="edit">수정</button>
              <form method="post" action="${pageContext.request.contextPath}/plans/detail/delete" class="pt-inline">
                <input type="hidden" name="pIdx" value="${param.pIdx}" />
                <input type="hidden" name="dayNo" value="${d.dayNo}" />
                <input type="hidden" name="field" value="must1" />
                <button type="submit" class="pt-mini-btn danger" onclick="return confirm('삭제하면 - 로 바뀝니다. 삭제할까요?');">삭제</button>
              </form>
            </div>
          </div>
          <div class="value pt-detail-value"><c:out value="${d.must1}" /></div>

          <form method="post" action="${pageContext.request.contextPath}/plans/detail/update" class="pt-edit-form" hidden>
            <input type="hidden" name="pIdx" value="${param.pIdx}" />
            <input type="hidden" name="dayNo" value="${d.dayNo}" />
            <input type="hidden" name="field" value="must1" />
            <input type="text" name="value" class="pt-edit-input" value="<c:out value='${d.must1}'/>" />
            <div class="pt-edit-actions">
              <button type="submit" class="pt-mini-btn primary">저장</button>
              <button type="button" class="pt-mini-btn" data-action="cancel">취소</button>
            </div>
          </form>
        </div>

        <!-- 일정(선택) -->
        <div class="field pt-detail-field">
          <div class="pt-detail-head">
            <label>일정(선택)</label>
            <div class="pt-detail-actions">
              <button type="button" class="pt-mini-btn" data-action="edit">수정</button>
              <form method="post" action="${pageContext.request.contextPath}/plans/detail/delete" class="pt-inline">
                <input type="hidden" name="pIdx" value="${param.pIdx}" />
                <input type="hidden" name="dayNo" value="${d.dayNo}" />
                <input type="hidden" name="field" value="must2" />
                <button type="submit" class="pt-mini-btn danger" onclick="return confirm('삭제하면 - 로 바뀝니다. 삭제할까요?');">삭제</button>
              </form>
            </div>
          </div>
          <div class="value pt-detail-value"><c:out value="${d.must2}" /></div>

          <form method="post" action="${pageContext.request.contextPath}/plans/detail/update" class="pt-edit-form" hidden>
            <input type="hidden" name="pIdx" value="${param.pIdx}" />
            <input type="hidden" name="dayNo" value="${d.dayNo}" />
            <input type="hidden" name="field" value="must2" />
            <input type="text" name="value" class="pt-edit-input" value="<c:out value='${d.must2}'/>" />
            <div class="pt-edit-actions">
              <button type="submit" class="pt-mini-btn primary">저장</button>
              <button type="button" class="pt-mini-btn" data-action="cancel">취소</button>
            </div>
          </form>
        </div>

      </div>
    </c:forEach>

  </div>

  <script>
    // ✅ 인라인 수정 토글
    (function(){
      document.addEventListener('click', function(e){
        const btn = e.target.closest('[data-action]');
        if(!btn) return;

        const fieldEl = btn.closest('.pt-detail-field');
        if(!fieldEl) return;

        const action = btn.getAttribute('data-action');
        const val = fieldEl.querySelector('.pt-detail-value');
        const form = fieldEl.querySelector('.pt-edit-form');

        if(action === 'edit'){
          e.preventDefault();
          if(val) val.hidden = true;
          if(form) form.hidden = false;
          const input = form ? form.querySelector('input[name="value"]') : null;
          if(input){ input.focus(); input.select(); }
        }

        if(action === 'cancel'){
          e.preventDefault();
          if(form) form.hidden = true;
          if(val) val.hidden = false;
        }
      });
    })();
  </script>

</body>
</html>