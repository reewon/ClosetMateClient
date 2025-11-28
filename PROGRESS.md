# ClosetMate 앱 개발 진행 상황

## ✅ 완료된 작업

### Phase 1: Firebase 인증 및 기본 화면
- [x] Firebase 초기화 (`main.dart`, `firebase_options.dart`)
- [x] Firebase Auth 패키지 설정 (`pubspec.yaml`)
- [x] AuthService 구현 (`lib/services/auth_service.dart`)
  - 회원가입 (Firebase + 서버 동기화)
  - 로그인
  - 로그아웃
  - ID 토큰 관리
- [x] ApiService 구현 (`lib/services/api_service.dart`)
  - 자동 토큰 첨부
  - 토큰 갱신 (401 에러 시)
- [x] Validation 유틸리티 (`lib/utils/validation.dart`)
  - 이메일, 비밀번호, 사용자명, 성별 검증
- [x] 로그인 화면 (`lib/screens/login_screen.dart`)
- [x] 회원가입 화면 (`lib/screens/signup_screen.dart`)
  - GmarketSans 폰트 적용
  - 성별 선택 (RadioButton)
  - 비밀번호 확인 검증
- [x] 패키지 버전 업데이트
  - `http: ^1.6.0`
  - `lints: ^6.0.0`
  - Firebase Auth API 변경사항 대응

---

## 🚧 현재 작업 중

### Phase 2: 메인 화면 구조
- [x] **하단 탭 바 구현** (`lib/screens/main_screen.dart`) ← 현재 단계
  - 4개 탭: 옷장, 오늘의 코디, 즐겨찾는 코디, 마이페이지
  - BottomNavigationBar 구현
  - 탭 전환 기능

---

## 📋 앞으로 해야 할 작업

### Phase 3: 옷장 기능
- [ ] 옷장 화면 구현
  - [ ] 카테고리 선택 화면
  - [ ] 아이템 목록 화면
  - [ ] 아이템 등록/수정 화면

### Phase 4: 오늘의 코디 기능
- [ ] 오늘의 코디 화면 구현
  - [ ] 코디 목록 화면
  - [ ] 코디 생성 화면
  - [ ] 코디 상세 화면

### Phase 5: 즐겨찾기 기능
- [ ] 즐겨찾는 코디 화면 구현
  - [ ] 즐겨찾기 목록 화면

### Phase 6: 마이페이지 기능
- [ ] 마이페이지 화면 구현
  - [ ] 사용자 정보 표시
  - [ ] 로그아웃 기능

### Phase 7: 인증 상태 관리
- [ ] 인증 상태 Provider/Notifier 구현
- [ ] main.dart 라우팅 수정 (로그인 여부에 따른 화면 분기)
- [ ] 자동 로그인 기능

### Phase 8: 최종 점검
- [ ] 전체 플로우 테스트
- [ ] UI/UX 개선
- [ ] 에러 처리 보완

---

## 📝 참고사항

### 메인 화면 구조
```
MainScreen (하단 탭 바)
├── 옷장 화면 (index 0)
├── 오늘의 코디 화면 (index 1)
├── 즐겨찾는 코디 화면 (index 2)
└── 마이페이지 화면 (index 3)
```

### 디자인 가이드
- 폰트: GmarketSans (Medium, weight: 500)
- 색상: 심플한 흰색/검은색 기반
- 스타일: Material Design 3

---

## 🔧 기술 스택
- Flutter SDK
- Firebase Core ^4.2.0
- Firebase Auth ^6.1.0
- HTTP ^1.6.0
- Google Fonts ^6.1.0

---

**마지막 업데이트:** 2025-11-28

