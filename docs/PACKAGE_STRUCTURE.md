src/main/java/com/exam/literaryplanner
│
├──  📄 LiteraryplannerApplication.java   (스프링 부트 실행 파일)
│
├── 📂 config (설정)
│   ├── 📄 WebConfig.java             (인터셉터 등록 및 시스템 환경 설정)
│	└── 📄 LoginInterceptor.java      (로그인 체크 및 보안 필터링 로직)
│
├── 📂 controller (창구/안내소)
│   ├── 📄 MembersController.java     (로그인/회원가입 요청 처리)
│   ├── 📄 MyPageController.java      (마이페이지 조회 및 정보 수정 제어)
│   ├── 📄 MapController.java         (지도 API 연동 및 장소 데이터 매핑)
│   ├── 📄 CommunityController.java   (여행 후기 목록, 작성, 수정, 삭제 처리)
│   ├── 📄 HomeController.java        (메인 홈페이지(/) 진입 처리)
│   └── 📄 PageController.java        (고객센터 등 정적 페이지 연결)
│
│
├── 📂 service (작업실)
│   ├── 📄 LiteraryService.java       (회원 인증 및 중복 체크 비즈니스 로직)
│   └── 📄 PlanService.java           (여행 일정 생성 및 저장 핵심 로직)
│   
│
├── 📂 repository (창고 관리자)
│   ├── 📄 LiteraryRepository.java    (회원(Member) DB 접근 인터페이스)
│   ├── 📄 SpotRepository.java        (장소 데이터(Spot) 조회 인터페이스)
│   ├── 📄 ReviewRepository.java      (후기(Review) DB 접근 인터페이스)
│   └── 📄 PlanRepository.java        (일정 저장/조회 인터페이스)
│  
│
└── 📂 domain (설계도/데이터 바구니)
    │    1. 회원 및 장소 정보 엔티티
    ├── 📄 Member.java                   
    ├── 📄 Spot.java 
    │
    │    2. 후기 및 일정 메인 엔티티
    ├── 📄 Review.java              
    ├── 📄 TravelPlan.java 
    │
    └── 📄 PlanDetail.java         (일정 내 일자별 상세 리스트 엔티티)

