# PlanTrip — 여행 일정 플래너 웹서비스

여행지를 찾고, 일정과 이동 경로를 짜고, 교통편을 확인하고, 다녀온 뒤 후기까지 남길 수 있는 여행 플래너 웹서비스입니다.

## 프로젝트 정보

| 구분 | 내용 |
|---|---|
| 과정 | K-Digital Training 장기 과정 「클라우드 기반 빅데이터 융합 자바(JAVA) 풀스택개발자 양성과정」 |
| 기간 | 2025.08 ~ 2026.03 |
| 팀 | 4명 |
| 수상 | K-디지털 트레이닝 경진대회 동상 (2026.03) |

## 주요 기능

| 영역 | 기능 |
|---|---|
| 여행지 | 여행지 탐색·상세, 지도 보기 |
| 일정·경로 | 여행 일정 작성·수정, Kakao Mobility 기반 이동 경로 |
| 교통 | 고속버스·시외버스·기차·항공 운행 정보 조회 (공공데이터포털 API) |
| 찜 | 여행지 찜하기, 마이페이지 찜 목록 |
| 후기 커뮤니티 | 후기 작성·수정·삭제, 사진 첨부, 내 후기 |
| 회원 | 회원가입, 로그인·회원가입 모달, Google 로그인(OAuth2), 이메일 비밀번호 재설정 |
| 마이페이지 | 회원정보 확인·수정, 내 일정, 찜 목록, 내 후기 |
| 고객센터 | 공지사항, FAQ, 1:1 문의 |
| 관리자 | 회원·블랙리스트 관리, 공지·FAQ 관리, 문의 답변 |

비회원은 찜하기, 일정 저장, 후기 작성처럼 회원 전용 기능에 접근하면 로그인 화면으로 안내됩니다(HttpSession 기반).

## 기술 스택

| 구분 | 내용 |
|---|---|
| Backend | Java 17, Spring Boot 3.5.9, Spring MVC, Spring Data JPA, Spring Security(OAuth2 Client), Spring Mail |
| Frontend | JSP, JSTL, JavaScript, CSS |
| Database | MySQL |
| 외부 API | Kakao Mobility(경로), 공공데이터포털 국토교통부 TAGO(고속·시외버스, 열차, 항공) |
| 도구 | Eclipse, Maven, Git, GitHub, Tailscale |

## 폴더 구조

```text
src/main/java/com/exam/literaryplanner/
  config/        Security, OAuth2 로그인 처리
  controller/    여행지, 지도, 일정·경로, 교통, 찜, 후기, 회원, 마이페이지, 고객센터, 관리자
  service/       비즈니스 로직, 외부 API 호출(RestClient)
  repository/    JPA 리포지토리
  domain/        엔티티 (Member, Spot, TravelPlan, PlanDetail, WishList, Review, Qna 등)
  dto/           요청·응답 객체
src/main/webapp/WEB-INF/views/   JSP 화면 (spot, plans, transport, community, members, support, admin)
src/main/resources/static/       CSS, JavaScript, 이미지
```

## 실행 방법

1. MySQL에 `plantripdb` 데이터베이스와 사용자 계정을 만듭니다.
2. `src/main/resources/application.properties`에 DB 접속 정보, 메일 계정, Google OAuth 클라이언트, Kakao Mobility REST 키, 공공데이터포털 서비스 키를 설정합니다. 비밀번호와 키는 환경 변수나 별도 설정 파일로 분리하고 저장소에 올리지 않습니다.
3. `./mvnw spring-boot:run`으로 실행한 뒤 http://localhost:8700 에 접속합니다.

## 팀 구성

| 이름 | GitHub | 역할 |
|---|---|---|
| 이은아 | [euna0428](https://github.com/euna0428) | 팀장(PM, 개발 중반부터), UI/UX 총괄, 메인 페이지, 로그인, 회원 가입(풀스택 개발), 추천 여행지 목록, 상세 보기, 지도, 교통, My page(프론트 UI 담당), 전체 기능 통합 |
| [이름] | [hoyoung6604](https://github.com/hoyoung6604) | DB담당자, 추천 여행지 목록, 찜 기능, My page(찜, 여행지 목록)연결, 풀스택 개발 |
| [이름] | [GitHub] | [담당 기능] |
| [이름] | [GitHub] | [담당 기능] |

