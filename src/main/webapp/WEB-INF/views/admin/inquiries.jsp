<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8"/>
<title>문의 관리 | 관리자</title>
<link rel="stylesheet" href="/css/home.css"/>
</head>
<body>

<div class="container" style="padding:24px 0;">
  <div style="display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:14px;">
    <div>
      <h1 style="margin:0;font-size:22px;">문의 관리</h1>
      <p style="margin:6px 0 0;color:#6b7280;">대기 먼저, 최신순 정렬</p>
    </div>
    <a class="btn" href="/admin">관리자 홈</a>
  </div>

  <div style="background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:16px;">
    <table style="width:100%;border-collapse:collapse;">
      <thead>
      <tr style="text-align:left;color:#6b7280;font-size:12px;">
        <th style="padding:10px 6px;width:120px;">상태</th>
        <th style="padding:10px 6px;">제목</th>
        <th style="padding:10px 6px;width:160px;">작성자</th>
        <th style="padding:10px 6px;width:200px;">등록일</th>
      </tr>
      </thead>
      <tbody>
      <c:if test="${empty qnaList}">
        <tr>
          <td colspan="4" style="padding:14px 6px;color:#6b7280;border-top:1px solid #f1f5f9;">
            문의가 없습니다.
          </td>
        </tr>
      </c:if>

      <c:forEach var="q" items="${qnaList}">
        <tr style="border-top:1px solid #f1f5f9;">
          <td style="padding:10px 6px;">
            <c:choose>
              <c:when test="${q['qStatus'] == 0}">
                <span style="display:inline-block;padding:4px 10px;border-radius:999px;border:1px dashed #e5e7eb;font-size:12px;color:#6b7280;">대기</span>
              </c:when>
              <c:otherwise>
                <span style="display:inline-block;padding:4px 10px;border-radius:999px;border:1px solid #e5e7eb;font-size:12px;">완료</span>
              </c:otherwise>
            </c:choose>
          </td>

          <td style="padding:10px 6px;max-width:0;">
            <a href="${pageContext.request.contextPath}/admin/inquiries/${q['qIdx']}"
               style="display:inline-block;max-width:100%;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:inherit;text-decoration:none;">
              ${q['qTitle']}
            </a>
          </td>

          <td style="padding:10px 6px;">
            ${q['mName']}
          </td>

          <td style="padding:10px 6px;color:#6b7280;">
            ${q['qRegDate']}
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</div>

</body>
</html>
