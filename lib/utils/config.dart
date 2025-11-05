/// API 설정 및 상수 정의
class Config {
  /// API Base URL
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  /// 인증 토큰 (현재는 테스트 토큰 사용)
  static const String authToken = 'test-token';

  /// 유효한 카테고리 목록
  static const List<String> validCategories = ['상의', '하의', '신발', '아우터'];

  /// 카테고리가 유효한지 확인
  static bool isValidCategory(String category) {
    return validCategories.contains(category);
  }
}

