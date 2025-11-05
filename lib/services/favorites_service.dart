import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/favorite.dart';

/// 즐겨찾기 관련 서비스
/// 
/// 즐겨찾는 코디 목록 조회, 상세 조회, 저장, 이름 변경, 삭제 기능을 제공합니다.
class FavoritesService {
  final ApiClient _apiClient;

  FavoritesService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// 즐겨찾기 목록 조회
  /// 
  /// 반환: FavoriteOutfit 리스트 (id, name만 포함)
  /// 예외: ApiException (에러 발생 시)
  Future<List<FavoriteOutfit>> getFavoritesList() async {
    try {
      final response = await _apiClient.get(Endpoints.favorites);

      // 빈 배열 처리
      if (response is List && response.isEmpty) {
        return [];
      }

      // JSON 배열을 FavoriteOutfit 리스트로 변환
      if (response is List) {
        return response
            .map((json) =>
                FavoriteOutfit.fromListJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('예상치 못한 응답 형식입니다.');
    } catch (e) {
      rethrow;
    }
  }

  /// 특정 코디 조회
  /// 
  /// [id]: 조회할 코디 ID
  /// 반환: FavoriteOutfit 객체 (모든 필드 포함)
  /// 예외: ApiException (에러 발생 시)
  Future<FavoriteOutfit> getFavoriteById(int id) async {
    try {
      final url = Endpoints.favoriteById(id);
      final response = await _apiClient.get(url);

      // JSON을 FavoriteOutfit 객체로 변환
      if (response is Map<String, dynamic>) {
        // 상세 조회 시 응답에 id가 없으므로, id를 수동으로 추가
        final responseWithId = Map<String, dynamic>.from(response);
        responseWithId['id'] = id;
        return FavoriteOutfit.fromDetailJson(responseWithId);
      }

      throw Exception('예상치 못한 응답 형식입니다.');
    } catch (e) {
      rethrow;
    }
  }

  /// 즐겨찾기 저장
  /// 
  /// 현재 오늘의 코디를 즐겨찾기로 저장합니다.
  /// 
  /// [name]: 저장할 코디 이름
  /// 반환: 성공 메시지
  /// 예외: ApiException (에러 발생 시)
  /// 
  /// 참고: 오늘의 코디가 완성되지 않은 경우 (4개의 카테고리 중 하나라도 미선택 시) 400 에러 발생
  Future<String> saveFavorite(String name) async {
    try {
      final body = FavoriteOutfit.createSaveRequestJson(name);
      final response = await _apiClient.post(Endpoints.favorites, body: body);

      // 성공 메시지 반환
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return response['message'] as String;
      }

      return '저장 완료';
    } catch (e) {
      rethrow;
    }
  }

  /// 코디 이름 변경
  /// 
  /// [id]: 변경할 코디 ID
  /// [newName]: 새로운 이름
  /// 반환: 성공 메시지
  /// 예외: ApiException (에러 발생 시)
  Future<String> renameFavorite(int id, String newName) async {
    try {
      final url = Endpoints.favoriteById(id);
      final body = FavoriteOutfit.createRenameRequestJson(newName);
      final response = await _apiClient.put(url, body: body);

      // 성공 메시지 반환
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return response['message'] as String;
      }

      return '이름이 변경되었습니다.';
    } catch (e) {
      rethrow;
    }
  }

  /// 코디 삭제
  /// 
  /// [id]: 삭제할 코디 ID
  /// 반환: 성공 메시지
  /// 예외: ApiException (에러 발생 시)
  Future<String> deleteFavorite(int id) async {
    try {
      final url = Endpoints.favoriteById(id);
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
