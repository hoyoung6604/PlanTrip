# PlanTrip 02_11 (admin1) 변경 로그
- 기준: `docs(1).zip` 안의 **FRONTEND.md / PACKAGE_STRUCTURE.md / Static Resources.md**
- 대상: `PlanTrip_02_11_admin1.zip` 실제 파일 구조(`src/main/**`) 기준
- 분류: Front(JSP), Back(Java), UI/UX(static css/js/img)

---
## 1) Front (JSP/JSPF)
### 1-1. 경로(폴더) 구조 정리/이동
- `support.jsp` → `support/support.jsp`
- `theme.jspf` → `common/theme.jspf`
- `community.jsp` → `community/community.jsp`
- `write.jsp` → `community/write.jsp`
- `myReview.jsp` → `community/myReview.jsp`
- `editReview.jsp` → `community/editReview.jsp`
- `mypage/mypage.jsp` → `members/mypage/mypage.jsp`
- `mypage/check.jsp` → `members/mypage/check.jsp`
- `mypage/edit.jsp` → `members/mypage/edit.jsp`
- `mypage/plans.jsp` → `members/mypage/plans.jsp`
- `mypage/reviews.jsp` → `members/mypage/reviews.jsp`
- `mypage/login.jsp` → `members/login.jsp`
- `mypage/register.jsp` → `members/register.jsp`

### 1-2. 새로 추가된 화면(02_11에 새로 등장)
- `admin/admin_faq.jsp`
- `admin/admin_faqDetail.jsp`
- `admin/admin_faqEdit.jsp`
- `admin/admin_faqs.jsp`
- `admin/admin_index.jsp`
- `admin/admin_members.jsp`
- `admin/admin_notice.jsp`
- `admin/admin_noticeDetail.jsp`
- `admin/admin_noticeEdit.jsp`
- `admin/admin_notices.jsp`
- `admin/admin_sidebar.jspf`
- `admin/inquiries.jsp`
- `admin/inquiry_detail.jsp`
- `common/authModal.jspf`
- `common/findPasswordModal.jspf`
- `common/loginModal.jspf`
- `common/loginRequiredModal.jspf`
- `common/signupModal.jspf`
- `community/view.jsp`
- `members/find-password.jsp`
- `members/reset-password-invalid.jsp`
- `members/reset-password.jsp`
- `support/_sidebar.jspf`
- `support/faq.jsp`
- `support/faqDetail.jsp`
- `support/notice.jsp`
- `support/noticeDetail.jsp`
- `support/qna.jsp`
- `support/qnaDetail.jsp`
- `support/qnaEdit.jsp`
- `support/qnaForm.jsp`

### 1-3. 삭제된 화면
- (기준 docs 대비 파일명 기준 삭제된 JSP/JSPF는 확인되지 않음)

### 1-4. 이번 버전에서 핵심적으로 눈에 띄는 변화 요약
- `admin/` 전용 JSP가 대량으로 추가되어 **관리자 화면 분리**가 진행됨
- `members/`, `support/`, `community/` 폴더로 화면이 나뉘어 **기능별 라우팅/관리 구조**가 더 명확해짐
- `common/`에 모달(JSPF)들이 추가되어 로그인/회원가입/비번찾기 UI를 **공통 컴포넌트화**한 형태로 보임

---
## 2) Back (Java)
### 2-1. 추가된 Java 파일
- `AdminController.java`
- `AdminInterceptor.java`
- `AdminQnaService.java`
- `AuthApiController.java`
- `Board.java`
- `BoardRepository.java`
- `BoardService.java`
- `MailService.java`
- `PasswordHasher.java`
- `PasswordResetService.java`
- `PasswordResetToken.java`
- `PasswordResetTokenRepository.java`
- `Qna.java`
- `QnaRepository.java`
- `SupportController.java`
- `SupportService.java`

### 2-2. 삭제된 Java 파일(기준 docs에는 있었는데 02_11 src/main/java에는 없음)
- `LoginInterceptor.java`
- `PlanDetail.java`
- `PlanRepository.java`
- `PlanService.java`
- `Spot.java`
- `SpotRepository.java`
- `TravelPlan.java`

### 2-3. 유지된 핵심 파일
- `CommunityController.java`
- `HomeController.java`
- `LiteraryRepository.java`
- `LiteraryService.java`
- `LiteraryplannerApplication.java`
- `MapController.java`
- `Member.java`
- `MembersController.java`
- `MyPageController.java`
- `PageController.java`
- `Review.java`
- `ReviewRepository.java`
- `WebConfig.java`

### 2-4. 변화 요약
- 관리자 기능 관련: `AdminController`, `AdminInterceptor`, `AdminQnaService` 등 **Admin 라인**이 추가됨
- 고객센터/문의 관련: `SupportController`, `SupportService`, `Qna*` 등이 추가되어 **FAQ/QnA/문의 흐름**이 백엔드로도 확장된 형태
- 비밀번호 재설정: `PasswordResetToken`, `PasswordResetService`, `MailService` 등 **메일/토큰 기반 재설정 구조**가 들어옴
- 반대로, 기준 docs에 있던 여행 플래너 도메인(Plan/Spot/TravelPlan 계열)은 이번 src/main/java 기준으로는 빠져 있음

---
## 3) UI/UX (resources/static)
### 3-1. 추가된 정적 리소스(css/js/img)
- `img/PlanTriplog.png`
- `css/admin-components.css`
- `css/admin-console.css`
- `css/admin-theme.css`
- `js/auth-guard.js`
- `css/auth-modal.css`
- `js/auth-modal.js`
- `img/theme/day-sky.png`
- `img/hero.jpg`
- `js/pages/index.js`
- `js/pages/login-page.js`
- `img/main.jpg`
- `img/main_light.jpg`
- `css/maps.css`
- `js/pages/maps.js`
- `img/mountain.jpg`
- `js/nav-wave.js`
- `img/theme/night-sky.png`
- `img/pp.jpg`
- `js/pages/register-page.js`
- `js/scrollbar-auto.js`
- `img/sea.jpg`
- `css/support-console.css`
- `css/support-hub.css`
- `js/theme-init.js`
- `css/theme-sky.css`
- `js/theme.js`
- `css/ui-toast.css`
- `js/ui-toast.js`

### 3-2. 삭제된 정적 리소스(기준 docs에는 있었는데 02_11에는 없음)
- `map.js`
- `planner.css`
- `planner.js`
- `support.css`
- `support.js`

### 3-3. 유지된 정적 리소스
- `alert.js`
- `community.css`
- `home.css`
- `list.js`
- `login.css`
- `mypage.css`
- `signup.css`

### 3-4. 변화 요약
- 관리자 전용 스타일: `admin-*.css` 추가
- 모달/인증 UI: `auth-modal.css`, `auth-modal.js`, `auth-guard.js` 등 추가
- 페이지 단위 스크립트 분리: `js/pages/*` 구조 추가(index/login/register/maps)
- 테마 관련: `theme-init.js`, `theme.js`, `theme-sky.css`, 테마 이미지(day/night) 추가
- 기존 `support.css/support.js` 대신 `support-console.css`, `support-hub.css` 형태로 재구성된 상태

---
## 4) 정리 내용 검증(근거)
이 변경 로그는 **두 소스**를 비교해서 만들었음.
1) 기준 문서: `docs(1).zip` 내부 MD(파일 목록)
2) 실제 프로젝트: `PlanTrip_02_11_admin1.zip` 내부 `src/main/**`에 존재하는 파일 목록

- ‘추가/삭제’는 **파일명 기준(set 비교)** 으로 계산함
- ‘이동’은 기준 MD에 존재하는 파일명이 02_11에도 존재하지만 **상대경로가 달라진 경우**로 정리함
- 기준 문서에는 없고 02_11에만 있는 파일은 ‘추가’로 분류함

