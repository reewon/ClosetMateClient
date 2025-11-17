/// API 설정 및 상수 정의
class Config {
  /// API Base URL
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  /// 서버 Base URL (이미지 URL 변환용)
  static const String serverBaseUrl = 'http://127.0.0.1:8000';

  /// 인증 토큰 (현재는 테스트 토큰 사용)
  static const String authToken = 'test-token';

  /// 유효한 카테고리 목록
  static const List<String> validCategories = ['top', 'bottom', 'shoes', 'outer'];

  /// 카테고리가 유효한지 확인
  static bool isValidCategory(String category) {
    return validCategories.contains(category);
  }

  /// 이미지 URL을 전체 URL로 변환
  /// 
  /// [imageUrl]: 서버에서 받은 상대 경로 (예: "uploads/user_1/item_1.jpg")
  /// 반환: 전체 URL (예: "http://127.0.0.1:8000/uploads/user_1/item_1.jpg")
  /// imageUrl이 null이거나 비어있으면 null 반환
  static String? getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }
    // 이미 전체 URL인 경우 그대로 반환
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    // 상대 경로를 전체 URL로 변환
    return '$serverBaseUrl/$imageUrl';
  }
}

