import 'config_local.dart' as local;

/// API 설정 및 상수 정의
class Config {
  /// 개발 서버 IP 주소
  /// 
  /// 실제 디바이스에서 테스트할 때는 컴퓨터의 실제 IP 주소로 변경하세요.
  /// 
  /// Windows에서 확인 방법:
  /// 1. cmd에서 'ipconfig' 실행
  /// 2. "무선 LAN 어댑터 Wi-Fi" 또는 "무선 LAN 어댑터 WLAN" 섹션 찾기
  /// 3. IPv4 주소 확인
  /// 
  /// 중요:
  /// - 무선 LAN 어댑터의 IP 주소를 사용하세요 (이더넷 X)
  /// - 사설 IP 주소 사용
  /// - 127.0.0.1이나 169.254.x.x는 사용하지 마세요
  /// - 컴퓨터와 디바이스가 같은 Wi-Fi 네트워크에 연결되어 있어야 합니다
  /// 
  /// config_local.dart에서 가져오거나, 파일이 없으면 기본값 사용
  /// config_local.dart는 .gitignore에 포함
  static String get _devServerIp {
    try {
      // config_local.dart가 있으면 사용
      return local.ConfigLocal.devServerIp;
    } catch (e) {
      // config_local.dart가 없으면 기본값 사용 (에뮬레이터용)
      return '10.0.2.2';
    }
  }
  
  
  /// API Base URL
  /// 
  /// 개발 서버 사용 (에뮬레이터: 10.0.2.2, 실제 디바이스: 컴퓨터 IP)
  /// 실제 디바이스 테스트 시 아래 주석을 해제하고 에뮬레이터용 라인을 주석 처리하세요
  static String get baseUrl {
    // 에뮬레이터용
    // return 'http://10.0.2.2:8000/api/v1';
    
    // 실제 디바이스용 (USB 디버깅으로 APK 설치 시 주석 해제)
    return 'http://$_devServerIp:8000/api/v1';
  }

  /// 서버 Base URL (이미지 URL 변환용)
  static String get serverBaseUrl {
    // 에뮬레이터용
    // return 'http://10.0.2.2:8000';
    
    // 실제 디바이스용
    return 'http://$_devServerIp:8000';
  }

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

