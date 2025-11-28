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

### Phase 2: 메인 화면 구조
- [x] **하단 탭 바 구현** (`lib/screens/main_screen.dart`)
  - 4개 탭: 옷장, 오늘의 코디, 즐겨찾는 코디, 마이페이지
  - BottomNavigationBar 구현
  - 탭 전환 기능

### Phase 3: 옷장 기능

#### 디자인 가이드
- **폰트**: 
  - GmarketSans (Medium, weight: 500) - 일반 텍스트
  - Google Fonts - Aboreto - "MY CLOSET" 타이틀
- **색상**: 심플한 흰색/검은색 기반
- **스타일**: Material Design 3

#### 1. 옷장 메인 화면 (`lib/screens/closet_screen.dart`) ✅

**화면 구성:**
- [x] **AppBar**: 
  - 타이틀: "MY CLOSET" (Google Fonts - Aboreto)
  - 배경: 흰색
  - 높이: 기본 AppBar 높이
- [x] **Body**: 
  - 2x2 Grid 레이아웃 (상의, 하의, 신발, 아우터)
  - 각 카테고리 카드는 Card로 구성

**카테고리 카드 UI:**
- [x] **상단 영역**:
  - 카테고리 제목 (한글: 상의, 하의, 신발, 아우터) - GmarketSans
  - 오른쪽 화살표 아이콘 (Icons.arrow_forward_ios)
  - Row 레이아웃으로 배치
- [x] **하단 영역**:
  - 아이템이 있을 때: 최근 등록된 아이템 이미지 표시 (최대 4개)
    - `GET /api/v1/closet/{category}`로 전체 목록 가져와서 최신 4개만 표시
    - GridView로 2x2 배치
    - `cached_network_image` 패키지 사용
    - 이미지 URL: `{baseUrl}/{image_url}`
  - 아이템이 없을 때 (빈 카테고리):
    - 회색 배경 + "+" 아이콘 + "옷을 추가해보세요" 텍스트
    - 중앙 정렬

**기능:**
- [x] 카테고리 카드 탭 시 `ClosetItemsScreen`으로 네비게이션
  - 전달할 데이터: 카테고리 이름 (한글) 및 카테고리 코드 (영문: top, bottom, shoes, outer)
- [x] 로딩 상태: CircularProgressIndicator (전체 화면)
- [x] 에러 처리: 네트워크 오류 시 SnackBar 또는 에러 메시지 표시
- [x] Pull-to-refresh 기능 (RefreshIndicator)

**API 연동:**
- [x] 각 카테고리별로 `GET /api/v1/closet/{category}` 호출
- [x] 카테고리 코드 매핑: 상의(top), 하의(bottom), 신발(shoes), 아우터(outer)
- [x] 응답에서 최신 4개 아이템만 추출하여 표시

#### 2. 카테고리별 아이템 목록 화면 (`lib/screens/closet_items_screen.dart`) ✅

**화면 구성:**
- [x] **AppBar**: 
  - 왼쪽: 뒤로가기 버튼 (Icons.arrow_back)
  - 중앙: 선택한 카테고리 이름 (예: "하의") - GmarketSans
  - 오른쪽: 
    - "+" 버튼 (Icons.add) - 아이템 추가
    - 편집 버튼 (Icons.edit_square) - 편집 모드 토글
- [x] **Body**: 
  - GridView로 아이템 이미지 카드 형태로 표시 (3열)
  - 각 아이템 카드:
    - 이미지 표시 (`cached_network_image` 패키지 사용)
    - 편집 모드일 때: 선택된 아이템에 파란색 테두리 표시
    - 이미지 URL: `{baseUrl}/{image_url}`
- [x] **편집 모드 하단 버튼** (편집 모드 활성화 시에만 표시):
  - "삭제" 버튼 (왼쪽, 회색 배경)
  - "코디에 추가" 버튼 (오른쪽, 회색 배경)
  - 선택된 아이템이 없을 때는 버튼 비활성화

**기능:**
- [x] **일반 모드**:
  - 특정 카테고리의 모든 아이템 목록 표시
  - "+" 버튼 클릭: 이미지 추가 (`image_picker` 패키지 사용)
    - 갤러리에서 이미지 선택
    - 선택한 이미지를 `ClosetService.addItem()`으로 서버에 업로드
    - 성공 시 편집 모드 종료 및 목록 새로고침
- [x] **편집 모드** (편집 버튼 클릭 시):
  - 각 아이템 카드 탭 시 선택/해제 (파란색 테두리로 표시)
  - 여러 아이템 선택 가능
  - 하단에 "삭제"와 "코디에 추가" 버튼 표시
  - "삭제" 버튼:
    - 선택한 아이템들을 `ClosetService.deleteItem(itemId)`로 삭제
    - 여러 아이템 선택 시 순차적으로 삭제 처리
    - 확인 다이얼로그 표시
    - 성공 시 편집 모드 종료 및 목록 새로고침
  - "코디에 추가" 버튼:
    - 선택한 아이템을 오늘의 코디에 추가
    - `OutfitService.updateOutfitItem(category, itemId)` 호출
    - 카테고리별로 하나의 아이템만 선택 가능 (마지막 선택된 아이템이 적용)
    - 성공 시 편집 모드 종료 및 목록 새로고침
- [x] 편집 모드 종료: 편집 버튼 다시 클릭 또는 아이템 추가 후 자동 종료

**API 연동:**
- [x] `GET /api/v1/closet/{category}` - 아이템 목록 조회
- [x] `POST /api/v1/closet/{category}` - 아이템 추가 (multipart/form-data)
- [x] `DELETE /api/v1/closet/{item_id}` - 아이템 삭제
- [x] `PUT /api/v1/outfit/today` - 코디에 아이템 추가
- [x] 카테고리 코드는 이전 화면에서 전달받은 값 사용

**필요한 패키지:**
- [x] `cached_network_image` - 이미지 캐싱 및 표시
- [x] `image_picker` - 갤러리/카메라에서 이미지 선택

---

## 📋 앞으로 해야 할 작업

### Phase 4: 오늘의 코디 기능

> 구성 가이드 추후 작성 예정

---

### Phase 5: 즐겨찾기 기능

> 구성 가이드 추후 작성 예정

---

### Phase 6: 마이페이지 기능

> 구성 가이드 추후 작성 예정

---

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
---

## 🔧 기술 스택
- Flutter SDK
- Firebase Core ^4.2.0
- Firebase Auth ^6.1.0
- HTTP ^1.6.0
- Google Fonts ^6.1.0

---

**마지막 업데이트:** 2025-11-28

