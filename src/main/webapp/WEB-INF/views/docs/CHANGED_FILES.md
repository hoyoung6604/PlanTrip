# PlanTrip_02_06_new_start 변경 파일 목록

이번 작업은 기존 Java Controller 로직을 유지하면서, 화면(JSP)과 정적 리소스(CSS/JS) 쪽만 수정했어요.

## 새로 추가된 파일

- `src/main/resources/static/css/admin-theme.css`
- `target/classes/static/css/admin-theme.css` (빌드 폴더에도 동일 파일 복사)

- `src/main/webapp/WEB-INF/views/common/findPasswordModal.jspf` (비밀번호 찾기 모달)

## 수정된 파일

### 다크/라이트 토글 UI + 네비 파도 효과

- `src/main/resources/static/js/theme.js`
- `src/main/resources/static/css/home.css`

### 로그인/회원가입/비밀번호 찾기 모달 애니메이션

- `src/main/resources/static/css/auth-modal.css`
- `src/main/resources/static/js/auth-modal.js`
- `src/main/webapp/WEB-INF/views/common/loginModal.jspf`
- `src/main/webapp/WEB-INF/views/common/signupModal.jspf`
- `src/main/webapp/WEB-INF/views/common/authModal.jspf`

### 비밀번호 찾기 AJAX 응답(기존 페이지 흐름 유지)

- `src/main/java/com/exam/literaryplanner/controller/MembersController.java`

### 지도 페이지

- `src/main/webapp/WEB-INF/views/maps.jsp`

### 고객센터(문의하기 흐름)

- `src/main/webapp/WEB-INF/views/support/support.jsp`

### 로그인 모달 문구

- `src/main/resources/static/js/auth-modal.js`
- `target/classes/static/js/auth-modal.js`

### 관리자 페이지 테마 적용

- `src/main/webapp/WEB-INF/views/admin/admin_index.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin_members.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin_notices.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin_noticeDetail.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin_noticeEdit.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin_notice.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin_faqs.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin_faqDetail.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin_faqEdit.jsp`
- `src/main/webapp/WEB-INF/views/admin/admin_faq.jsp`
- `src/main/webapp/WEB-INF/views/admin/inquiries.jsp`
- `src/main/webapp/WEB-INF/views/admin/inquiry_detail.jsp`
