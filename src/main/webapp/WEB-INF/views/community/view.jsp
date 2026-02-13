<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/common/theme.jspf" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.springframework.context.ApplicationContext" %>
<%@ page import="com.exam.literaryplanner.repository.LiteraryRepository" %>
<%@ page import="com.exam.literaryplanner.domain.Member" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>후기 상세</title>
  
  <link rel="stylesheet" href="/css/theme-sky.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/community.css">
    <link rel="stylesheet" href="/css/auth-modal.css" />
    <link rel="stylesheet" href="/css/ui-toast.css" />

    <script defer src="/js/ui-toast.js"></script>
    <script defer src="/js/theme.js"></script>
    <script defer src="/js/auth-modal.js"></script>
    <script defer src="/js/auth-guard.js"></script>
</head>

<!-- ✅ 사진 UI용 CSS (임의 추가) -->
<style>
  :root{
    --gap-5cm: 12px;
  }

  .rp-wrap { margin-top: 14px; white-space: normal; }
  .rp-title { margin:0 0 8px; font-weight:700; }

  .rp-uploader-row{
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:12px;
    padding:10px 12px;
    border:1px solid rgba(255,255,255,.12);
    border-radius:12px;
    background:rgba(255,255,255,.04);
    width: min(720px, 100%);
    margin: 0;
  }
  .rp-uploader-row input[type="file"]{
    width: min(460px, 100%);
    font-size:12px;
  }
  .rp-upload-btn{
    padding:8px 12px;
    font-size:13px;
    border-radius:12px;
    border:1px solid rgba(255,255,255,.16);
    background:rgba(255,255,255,.06);
    cursor:pointer;
    white-space:nowrap;
  }

  .rp-list-wrap{ margin-top: 12px; }

  .rp-post{
    display:flex;
    gap:18px;
    align-items:flex-start;
    padding:14px;
    border:1px solid rgba(255,255,255,.10);
    border-radius:16px;
    background:rgba(255,255,255,.03);
    margin-bottom:14px;
    max-width: 980px;
  }

  /* ✅ 사진 크기 통일(공백 줄이기): 고정 height 대신 aspect-ratio */
  .rp-photo-box{
    width:360px;
    aspect-ratio: 16 / 9;
    height:auto;
    border-radius:14px;
    overflow:hidden;
    background:rgba(255,255,255,.02);
    border:1px solid rgba(255,255,255,.10);
    flex: 0 0 auto;
    display:flex;
    align-items:center;
    justify-content:center;
  }
  .rp-photo-box img{
    width:100%;
    height:100%;
    object-fit:cover; /* ✅ 공백 최소화 */
    display:block;
  }

  .rp-text{
    flex: 1 1 auto;
    min-width: 220px;
    display: flex;
    flex-direction: column;
  }

  .rp-text .rp-caption-label{
    font-size:12px;
    color:rgba(255,255,255,.55);
    margin-bottom:8px;
  }
  .rp-text textarea{
    width:100%;
    min-height: 240px;
    resize: vertical;
    border-radius:12px;
    padding:10px 12px;
    border:1px solid rgba(255,255,255,.14);
    background:rgba(0,0,0,.12);
    color:rgba(255,255,255,.85);
    font-size:13px;
    line-height:1.5;
  }

  .rp-actions{
    display:flex;
    justify-content:flex-end;
    gap:8px;
    margin-top:10px;
  }
  .rp-delbtn{
    padding:6px 10px;
    font-size:12px;
    border-radius:10px;
    border:1px solid rgba(255,255,255,.14);
    background:rgba(255,0,0,.08);
    cursor:pointer;
  }

  /* ✅ 업로드 확인 모달: 사진 많아져도 항상 "화면 정중앙" */
  .rp-modal-overlay{
    position:fixed !important;
    inset:0;
    top:0;
    left:0;
    width:100vw;
    height:100vh;
    background:rgba(0,0,0,.55);
    display:none;
    align-items:center;
    justify-content:center;
    z-index:999999;
    transform:none !important; /* 부모 transform 영향 차단 */
  }
  .rp-modal{
    width:min(420px, 92vw);
    border-radius:16px;
    border:1px solid rgba(255,255,255,.14);
    background:rgba(20,23,32,.98);
    padding:16px;
  }
  .rp-modal h4{ margin:0 0 8px; font-size:16px; }
  .rp-modal p{ margin:0 0 14px; font-size:13px; color:rgba(255,255,255,.65); }
  .rp-modal-actions{
    display:flex;
    justify-content:flex-end;
    gap:8px;
  }
  .rp-btn{
    padding:8px 12px;
    font-size:13px;
    border-radius:12px;
    border:1px solid rgba(255,255,255,.16);
    background:rgba(255,255,255,.06);
    cursor:pointer;
  }
  .rp-btn-primary{
    background:rgba(0,170,255,.18);
    border-color:rgba(0,170,255,.28);
  }

  @media (max-width: 920px){
    .rp-post{ flex-direction:column; }
    .rp-photo-box{ width:100%; }
  }
  
  .focus-img{
    display: block;
    margin-bottom: 3cm;
  }
  </style>
<body>

<div class="cm-shell">

  <!-- 좌측 사이드바 유지 -->
  <aside class="mp-side">
    <div class="mp-brand">
      <div class="mp-logo"></div>
      <div class="mp-brand-name">Community</div>
    </div>

    <div class="sec">
      <div class="sec-title">MENU</div>
      <nav class="mp-nav">
        <a class="active" href="${pageContext.request.contextPath}/community">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 6h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 18h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          여행 후기 목록
        </a>

        <a href="${pageContext.request.contextPath}/community/write">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M12 5v14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M5 12h14" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          후기 작성
        </a>

        <a href="${pageContext.request.contextPath}/community/my-reviews">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 7h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 12h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <path d="M4 17h16" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </span>
          내 여행 후기
        </a>
      </nav>
    </div>

    <div class="sec sec-bottom">
      <div class="sec-title">SETTINGS</div>
      <nav class="mp-nav">
        <a href="${pageContext.request.contextPath}/members/mypage">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M4 13h7V4H4v9Zm9 7h7V11h-7v9ZM4 20h7v-5H4v5Zm9-16v5h7V4h-7Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          마이페이지로
        </a>

        <button class="menu-btn" type="button"
                onclick="location.href='${pageContext.request.contextPath}/'">
          <span class="mp-ico" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none">
              <path d="M3 10.5 12 3l9 7.5V21a2 2 0 0 1-2 2h-4v-7H9v7H5a2 2 0 0 1-2-2V10.5Z"
                    stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
            </svg>
          </span>
          메인으로
        </button>
      </nav>
    </div>
  </aside>

  <main class="cm-main">
    <section class="mp-card">
      <div class="mp-card-head">
        <div>
          <div class="mp-card-title"><c:out value="${review.rvTitle}"/></div>

          <div class="mp-card-sub">
            별점:
            <c:forEach begin="1" end="${review.rvStar}">⭐</c:forEach>

            <%
              ApplicationContext ctx = WebApplicationContextUtils.getWebApplicationContext(application);
              LiteraryRepository memberRepo = ctx.getBean(LiteraryRepository.class);

              com.exam.literaryplanner.domain.Review rv =
                  (com.exam.literaryplanner.domain.Review) request.getAttribute("review");

              Integer mIdx = (rv != null ? rv.getMIdx() : null);

              String authorName = "알 수 없음";
              if (mIdx != null) {
                  Member m = memberRepo.findById(mIdx).orElse(null);
                  if (m != null) authorName = m.getMName();
                  else authorName = "탈퇴한 사용자";
              }
              request.setAttribute("authorName", authorName);
            %>

            작성자: <c:out value="${authorName}"/>

            &nbsp;|&nbsp; 장소:
            <c:choose>
              <c:when test="${review.SIdx == 1}">제주도</c:when>
              <c:when test="${review.SIdx == 2}">부산</c:when>
              <c:when test="${review.SIdx == 3}">수원</c:when>
              <c:when test="${review.SIdx == 4}">경주</c:when>
              <c:otherwise>알 수 없음</c:otherwise>
            </c:choose>
          </div>
        </div>

        <button class="mp-btn" type="button"
                onclick="location.href='${pageContext.request.contextPath}/community'">
          목록
        </button>
      </div>

      <div class="mp-card-body">
        <div style="white-space:pre-wrap; line-height:1.7;">
          <c:out value="${review.rvCont}"/>

		 
		  
		  <!-- ✅ 후기 사진 섹션 (pre-wrap 밖으로 빼서 공백 제거) -->
		         <%
		           boolean isAuthor = false;
		           try{
		             Member lm = (Member) session.getAttribute("loginMember");
		             com.exam.literaryplanner.domain.Review rv2 =
		                 (com.exam.literaryplanner.domain.Review) request.getAttribute("review");

		             if(lm != null && rv2 != null && rv2.getMIdx() != null && lm.getMIdx() != null){
		               isAuthor = rv2.getMIdx().equals(lm.getMIdx());
		             }
		           } catch(Exception e){
		             isAuthor = false;
		           }
		           request.setAttribute("isAuthor", isAuthor);
		         %>


		  <!-- <추가> 후기 상세 페이지(view.jsp)에 사진 표시 + 업로드 폼 붙이기 -->
		  <div class="rp-wrap">
		    <h3 class="rp-title">사진</h3>



			 <!-- ✅ 업로드: 작성자만 보이게 -->
			          <c:if test="${isAuthor}">
			            <form id="rpUploadForm"
			                  action="${pageContext.request.contextPath}/review-photos/upload-multi"
			                  method="post"
			                  enctype="multipart/form-data"
			                  style="margin:0;">
			              <input type="hidden" name="rvIdx" value="${review.rvIdx}">

			              <div class="rp-uploader-row">
			                <input id="rpFileInput" type="file" name="photos" accept="image/*" multiple required>
			                <button type="button" class="rp-upload-btn" id="rpOpenUploadModalBtn">업로드</button>
			              </div>
			            </form>
			          </c:if>

			          <!-- ✅ 사진 리스트 -->
			          <div class="rp-list-wrap">
						

			            <c:if test="${empty photos}">
			              <div style="color:#6b7280; font-size:12px;">등록된 사진이 없습니다.</div>
			            </c:if>

			            <c:if test="${not empty photos}">
			              <c:forEach var="p" items="${photos}">
			                <div class="rp-post">
			                  <div class="rp-photo-box">
			                    <img src="${pageContext.request.contextPath}/review-photos/${p.rpIdx}" alt="review photo">
			                  </div>

			                  <div class="rp-text">
			                    <div class="rp-caption-label">사진 설명(선택)</div>
			                    <textarea placeholder="이 사진에 대한 설명을 적어주세요 (예: 분위기, 장소, 팁 등)"></textarea>

			                    <!-- ✅ 사진 삭제 버튼: 작성자만 보이게 -->
			                    <c:if test="${isAuthor}">
			                      <div class="rp-actions">
			                        <form action="${pageContext.request.contextPath}/review-photos/delete"
			                              method="post" style="margin:0;">
			                          <input type="hidden" name="rpIdx" value="${p.rpIdx}">
			                          <input type="hidden" name="rvIdx" value="${review.rvIdx}">
			                          <button type="submit" class="rp-delbtn"
			                                  onclick="return confirm('정말 삭제하시겠습니까?');">삭제</button>
			                        </form>
			                      </div>
			                    </c:if>
			                  </div>
			                </div>
			              </c:forEach>
			            </c:if>

			          </div>
			        </div>

			        <!-- ✅ 글 수정/삭제: 원래 위치 유지 + 팝업 문구 지정 -->
			        <div style="margin-top:14px;">
			          <c:if test="${not empty sessionScope.loginMember and sessionScope.loginMember.MIdx == review.MIdx}">
			            <button class="cm-linkbtn" type="button"
			                    onclick="if(confirm('이대로 저장하시겠습니까?')) location.href='${pageContext.request.contextPath}/community/edit?rvIdx=${review.rvIdx}';">
			              수정
			            </button>
			            <span style="opacity:.5;"> | </span>
			            <form action="${pageContext.request.contextPath}/community/delete"
			                  method="post"
			                  style="display:inline;"
			                  onsubmit="return confirm('정말 삭제하시겠습니까?');">
			              <input type="hidden" name="rvIdx" value="${review.rvIdx}">
			              <button type="submit" class="cm-linkbtn">삭제</button>
			            </form>
			          </c:if>
			        </div>

			      </div>
			    </section>
			  </main>
			</div>

			<!-- ✅ 업로드 확인 모달 (반드시 body 맨 끝 / cm-shell 밖) -->
			<div id="rpModalOverlay" class="rp-modal-overlay" aria-hidden="true">
			  <div class="rp-modal" role="dialog" aria-modal="true" aria-labelledby="rpModalTitle">
			    <h4 id="rpModalTitle">업로드 하시겠습니까?</h4>
			    <p>선택한 사진을 이 후기 글에 등록합니다.</p>
			    <div class="rp-modal-actions">
			      <button type="button" class="rp-btn" id="rpNoBtn">아니오</button>
			      <button type="button" class="rp-btn rp-btn-primary" id="rpYesBtn">예</button>
			    </div>
			  </div>
			</div>
					  
			<script>
			(function(){
			  const form = document.getElementById('rpUploadForm');
			  const fileInput = document.getElementById('rpFileInput');
			  const openBtn = document.getElementById('rpOpenUploadModalBtn');

			  const overlay = document.getElementById('rpModalOverlay');
			  const yesBtn = document.getElementById('rpYesBtn');
			  const noBtn  = document.getElementById('rpNoBtn');

			  if(!form || !fileInput || !openBtn || !overlay || !yesBtn || !noBtn) return;

			  function hasFiles(){
			    return fileInput.files && fileInput.files.length > 0;
			  }
			  function openModal(){
			    overlay.style.display = 'flex';
			    overlay.setAttribute('aria-hidden', 'false');
			    document.body.style.overflow = 'hidden'; // 스크롤 잠금(모달 중앙 유지)
			  }
			  function closeModal(){
			    overlay.style.display = 'none';
			    overlay.setAttribute('aria-hidden', 'true');
			    document.body.style.overflow = ''; // 스크롤 복구
			  }

			  openBtn.addEventListener('click', function(){
			    if(!hasFiles()){
			      alert('먼저 사진을 선택해주세요.');
			      return;
			    }
			    openModal();
			  });

			  yesBtn.addEventListener('click', function(){
			    closeModal();
			    form.submit();
			  });

			  noBtn.addEventListener('click', function(){
			    closeModal();
			  });

			  overlay.addEventListener('click', function(e){
			    if(e.target === overlay) closeModal();
			  });
			})();
			</script>x
		  <!-- 끝 -->



        <!-- ✅ 글 수정/삭제: 원래 위치 유지 + 팝업 문구 지정 -
        <div style="margin-top:14px;">
          <c:if test="${not empty sessionScope.loginMember and sessionScope.loginMember.MIdx == review.MIdx}">
            <button class="cm-linkbtn" type="button"
                    onclick="if(confirm('이대로 저장하시겠습니까?')) location.href='${pageContext.request.contextPath}/community/edit?rvIdx=${review.rvIdx}';">
              수정
            </button>
            <span style="opacity:.5;"> | </span>
            <form action="${pageContext.request.contextPath}/community/delete"
                  method="post"
                  style="display:inline;"
                  onsubmit="return confirm('정말 삭제하시겠습니까?');">
              <input type="hidden" name="rvIdx" value="${review.rvIdx}">
              <button type="submit" class="cm-linkbtn">삭제</button>
            </form>
          </c:if>
        </div>
-->
<!-- 본인 글일 때만 수정/삭제 -->
        <div style="margin-top:14px;">
          <c:if test="${not empty sessionScope.loginMember and sessionScope.loginMember.MIdx == review.MIdx}">
            <button class="cm-linkbtn" type="button"
                    onclick="location.href='${pageContext.request.contextPath}/community/edit?rvIdx=${review.rvIdx}'">
              수정
            </button>
            <span style="opacity:.5;"> | </span>
            <form action="${pageContext.request.contextPath}/community/delete" method="post" style="display:inline;">
              <input type="hidden" name="rvIdx" value="${review.rvIdx}">
              <button type="submit" class="cm-linkbtn">삭제</button>
            </form>
          </c:if>
        </div>

      </div>
    </section>
  </main>
</div>
<%@ include file="/WEB-INF/views/common/authModal.jspf" %>
</body>
</html>
