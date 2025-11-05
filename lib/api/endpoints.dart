import '../utils/config.dart';

/// API 엔드포인트 상수 정의
class Endpoints {
  // Base URL
  static const String baseUrl = Config.baseUrl;

  // Auth
  static const String testLogin = '$baseUrl/auth/test-login';

  // Closet
  static String closetByCategory(String category) => '$baseUrl/closet/$category';
  static String closetItemDelete(int itemId) => '$baseUrl/closet/$itemId';

  // Today Outfit
  static const String outfitToday = '$baseUrl/outfit/today';
  static const String outfitClear = '$baseUrl/outfit/clear';
  static const String outfitRecommend = '$baseUrl/outfit/recommend';

  // Favorites
  static const String favorites = '$baseUrl/favorites';
  static String favoriteById(int id) => '$baseUrl/favorites/$id';
}
