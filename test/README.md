# 테스트 디렉터리

이 디렉터리는 ClosetMate CLI 애플리케이션의 테스트 파일들을 포함합니다.

## 디렉터리 구조

```
test/
├── api/          # API 관련 테스트
├── cli/          # CLI 관련 테스트
├── models/       # 모델 관련 테스트
├── services/     # 서비스 관련 테스트
└── utils/        # 유틸리티 관련 테스트
```

## 테스트 실행 방법

### API 에러 파싱 테스트
```bash
dart test/api/api_client_test.dart
```

## 테스트 가이드

자세한 테스트 가이드는 `test_error_handling.md` 파일을 참고하세요.




