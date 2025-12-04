import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/outfit.dart';

/// 오늘의 코디 관련 서비스
/// 
/// 오늘의 코디 조회, 아이템 선택/변경, 카테고리 비우기, AI 추천 기능을 제공합니다.
class OutfitService {
  final ApiClient _apiClient;

  OutfitService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// 오늘의 코디 조회
  /// 
  /// 반환: Outfit 객체 (각 카테고리별 아이템 포함, nullable)
  /// 예외: ApiException (에러 발생 시)
  Future<Outfit> getTodayOutfit() async {
    try {
      final response = await _apiClient.get(Endpoints.outfitToday);

      // JSON을 Outfit 객체로 변환
      if (response is Map<String, dynamic>) {
        return Outfit.fromJson(response);
      }

      throw Exception('예상치 못한 응답 형식입니다.');
    } catch (e) {
      rethrow;
    }
  }

  /// 코디 아이템 선택/변경
  /// 
  /// [category]: 카테고리 (top, bottom, shoes, outer)
  /// [itemId]: 선택할 아이템 ID
  /// 반환: 성공 메시지
  /// 예외: ApiException (에러 발생 시)
  Future<String> updateOutfitItem(String category, int itemId) async {
    try {
      final body = {
        'category': category,
        'item_id': itemId,
      };
      final response = await _apiClient.put(Endpoints.outfitToday, body: body);

      // 성공 메시지 반환
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return response['message'] as String;
      }

      return '${category}가 변경되었습니다.';
    } catch (e) {
      rethrow;
    }
  }

  /// 특정 카테고리 비우기
  /// 
  /// [category]: 비울 카테고리 (top, bottom, shoes, outer)
  /// 반환: 성공 메시지
  /// 예외: ApiException (에러 발생 시)
  Future<String> clearCategory(String category) async {
    try {
      final body = {
        'category': category,
      };
      final response = await _apiClient.put(Endpoints.outfitClear, body: body);

      // 성공 메시지 반환
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return response['message'] as String;
      }

      return '${category}가 비워졌습니다.';
    } catch (e) {
      rethrow;
    }
  }

  /// AI 추천 실행
  /// 
  /// 반환: AI가 추천한 Outfit 객체
  /// 예외: ApiException (에러 발생 시)
  Future<Outfit> recommendOutfit() async {
    try {
      final response = await _apiClient.post(Endpoints.outfitRecommend);

      // JSON을 Outfit 객체로 변환
      if (response is Map<String, dynamic>) {
        return Outfit.fromJson(response);
      }

      throw Exception('예상치 못한 응답 형식입니다.');
    } catch (e) {
      rethrow;
    }
  }
}