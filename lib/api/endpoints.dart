import '../utils/config.dart';

/// API 엔드포인트 정의
class Endpoints {
  // Base URL
  static String get baseUrl => Config.baseUrl;

  // Auth
  static String get testLogin => '$baseUrl/auth/test-login';
  static String get authMe => '$baseUrl/auth/me';
  static String get authSync => '$baseUrl/auth/sync';

  // Closet
  static String closetByCategory(String category) => '$baseUrl/closet/$category';
  static String closetItemDelete(int itemId) => '$baseUrl/closet/$itemId';

  // Today Outfit
  static String get outfitToday => '$baseUrl/outfit/today';
  static String get outfitClear => '$baseUrl/outfit/clear';
  static String get outfitRecommend => '$baseUrl/outfit/recommend';

  // Favorites
  static String get favorites => '$baseUrl/favorites';
  static String favoriteById(int id) => '$baseUrl/favorites/$id';
}