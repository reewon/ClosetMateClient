import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_client.dart';
import '../models/api_error.dart';
import 'auth_service.dart';

/// API 서비스
/// 
/// Firebase Auth 토큰을 자동으로 사용하여 서버 API를 호출합니다.
/// 토큰 자동 갱신 및 에러 처리를 포함합니다.
class ApiService {
  final AuthService _authService = AuthService();

  /// Authorization 헤더 생성 (Firebase 토큰 사용)
  /// 
  /// [forceRefresh]: 토큰 강제 갱신 여부
  /// 반환: 헤더 Map
  Future<Map<String, String>> _getHeaders({bool forceRefresh = false}) async {
    try {
      final token = await _authService.getIdToken(forceRefresh: forceRefresh);
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      throw ApiException('인증 토큰을 가져올 수 없습니다. 다시 로그인해주세요.');
    }
  }

  /// GET 요청
  /// 
  /// [url]: 요청할 URL
  /// 반환: 파싱된 JSON 응답
  /// 예외: ApiException (에러 응답 시)
  Future<dynamic> get(String url) async {
    return await _requestWithRetry(() async {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      return _handleResponse(response);
    });
  }

  /// POST 요청
  /// 
  /// [url]: 요청할 URL
  /// [body]: 요청 본문 (Map)
  /// 반환: 파싱된 JSON 응답
  /// 예외: ApiException (에러 응답 시)
  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    return await _requestWithRetry(() async {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    });
  }

  /// PUT 요청
  /// 
  /// [url]: 요청할 URL
  /// [body]: 요청 본문 (Map)
  /// 반환: 파싱된 JSON 응답
  /// 예외: ApiException (에러 응답 시)
  Future<dynamic> put(String url, {Map<String, dynamic>? body}) async {
    return await _requestWithRetry(() async {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    });
  }

  /// DELETE 요청
  /// 
  /// [url]: 요청할 URL
  /// 반환: 파싱된 JSON 응답
  /// 예외: ApiException (에러 응답 시)
  Future<dynamic> delete(String url) async {
    return await _requestWithRetry(() async {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      return _handleResponse(response);
    });
  }

  /// 토큰 갱신 후 재시도가 포함된 요청 처리
  /// 
  /// [request]: 실행할 요청 함수
  /// 반환: 요청 결과
  /// 예외: ApiException
  Future<dynamic> _requestWithRetry(Future<dynamic> Function() request) async {
    try {
      // 첫 번째 시도
      return await request();
    } on ApiException catch (e) {
      // 401 에러인 경우 토큰 갱신 후 재시도
      if (e.statusCode == 401) {
        try {
          // 토큰 강제 갱신 후 재시도
          return await _requestWithRefreshedToken(request);
        } catch (retryError) {
          // 재시도 실패 시 재로그인 유도 메시지
          throw ApiException(
            '인증이 만료되었습니다. 다시 로그인해주세요.',
            apiError: e.apiError,
          );
        }
      }
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('네트워크 오류가 발생했습니다: $e');
    }
  }

  /// 토큰 갱신 후 재시도
  /// 
  /// [request]: 실행할 요청 함수
  /// 반환: 요청 결과
  Future<dynamic> _requestWithRefreshedToken(
    Future<dynamic> Function() request,
  ) async {
    // 토큰 강제 갱신
    await _authService.getIdToken(forceRefresh: true);
    
    // 재시도
    return await request();
  }

  /// HTTP 응답 처리
  /// 
  /// 성공 응답(200)이면 JSON을 파싱하여 반환
  /// 에러 응답이면 ApiException 예외 발생
  dynamic _handleResponse(http.Response response) {
    // 응답 본문이 비어있으면 null 반환
    if (response.body.isEmpty) {
      if (response.statusCode == 200) {
        return null;
      } else {
        throw ApiException('서버 오류가 발생했습니다. (${response.statusCode})');
      }
    }

    // JSON 파싱 시도
    dynamic jsonResponse;
    try {
      jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      // JSON 파싱 실패 시
      if (response.statusCode == 200) {
        throw ApiException('서버 응답을 파싱할 수 없습니다: ${response.body}');
      } else {
        throw ApiException(
          '서버 오류가 발생했습니다. (${response.statusCode}): ${response.body}',
        );
      }
    }

    // 성공 응답 (200)
    if (response.statusCode == 200) {
      return jsonResponse;
    }

    // 에러 응답 처리
    Map<String, dynamic>? errorData;

    // FastAPI의 detail 키로 감싸진 에러 응답 처리
    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse.containsKey('detail')) {
      final detail = jsonResponse['detail'];
      if (detail is Map<String, dynamic> &&
          detail.containsKey('status') &&
          detail['status'] == 'error') {
        errorData = detail as Map<String, dynamic>;
      }
    }

    // 직접 에러 응답 형식
    if (errorData == null &&
        jsonResponse is Map<String, dynamic> &&
        jsonResponse.containsKey('status') &&
        jsonResponse['status'] == 'error') {
      errorData = jsonResponse;
    }

    // ApiError 모델로 파싱하여 예외 발생
    if (errorData != null) {
      final apiError = ApiError.fromJson(errorData);
      throw ApiException(apiError.message, apiError: apiError);
    }

    // 기타 에러
    throw ApiException(
      '서버 오류가 발생했습니다. (${response.statusCode}): ${response.body}',
    );
  }
}


