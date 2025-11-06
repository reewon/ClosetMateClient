import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/closet_item.dart';

/// 옷장 관련 서비스
/// 
/// 내 옷장의 아이템 조회, 추가, 삭제 기능을 제공합니다.
class ClosetService {
  final ApiClient _apiClient;

  ClosetService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// 카테고리별 아이템 조회
  /// 
  /// [category]: 카테고리 (top, bottom, shoes, outer)
  /// 반환: ClosetItem 리스트
  /// 예외: ApiException (에러 발생 시)
  Future<List<ClosetItem>> getItemsByCategory(String category) async {
    try {
      final url = Endpoints.closetByCategory(category);
      final response = await _apiClient.get(url);

      // 빈 배열 처리
      if (response is List && response.isEmpty) {
        return [];
      }

      // JSON 배열을 ClosetItem 리스트로 변환
      if (response is List) {
        return response
            .map((json) => ClosetItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('예상치 못한 응답 형식입니다.');
    } catch (e) {
      rethrow;
    }
  }

  /// 아이템 추가
  /// 
  /// [category]: 카테고리 (top, bottom, shoes, outer)
  /// [name]: 아이템 이름
  /// 반환: 성공 메시지
  /// 예외: ApiException (에러 발생 시)
  Future<String> addItem(String category, String name) async {
    try {
      final url = Endpoints.closetByCategory(category);
      final body = ClosetItem.createRequestJson(name);
      final response = await _apiClient.post(url, body: body);

      // 성공 메시지 반환
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return response['message'] as String;
      }

      return '추가 완료';
    } catch (e) {
      rethrow;
    }
  }

  /// 아이템 삭제
  /// 
  /// [itemId]: 삭제할 아이템 ID
  /// 반환: 성공 메시지
  /// 예외: ApiException (에러 발생 시)
  Future<String> deleteItem(int itemId) async {
    try {
      final url = Endpoints.closetItemDelete(itemId);
      final response = await _apiClient.delete(url);

      // 성공 메시지 반환
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return response['message'] as String;
      }

      return '삭제 완료';
    } catch (e) {
      rethrow;
    }
  }
}
