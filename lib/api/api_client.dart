import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import '../models/api_error.dart';

/// HTTP API 클라이언트
/// 
/// 모든 HTTP 요청을 처리하고, 에러 응답을 파싱합니다.
class ApiClient {
  /// Authorization 헤더 생성
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': Config.authToken,
    };
  }

  /// GET 요청
  /// 
  /// [url]: 요청할 URL
  /// 반환: 파싱된 JSON 응답
  /// 예외: ApiException (에러 응답 시)
  Future<dynamic> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류가 발생했습니다: $e');
    }
  }

  /// POST 요청
  /// 
  /// [url]: 요청할 URL
  /// [body]: 요청 본문 (Map)
  /// 반환: 파싱된 JSON 응답
  /// 예외: ApiException (에러 응답 시)
  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류가 발생했습니다: $e');
    }
  }

  /// PUT 요청
  /// 
  /// [url]: 요청할 URL
  /// [body]: 요청 본문 (Map)
  /// 반환: 파싱된 JSON 응답
  /// 예외: ApiException (에러 응답 시)
  Future<dynamic> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류가 발생했습니다: $e');
    }
  }

  /// DELETE 요청
  /// 
  /// [url]: 요청할 URL
  /// 반환: 파싱된 JSON 응답
  /// 예외: ApiException (에러 응답 시)
  Future<dynamic> delete(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류가 발생했습니다: $e');
    }
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

    // JSON 파싱
    final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

    // 성공 응답 (200)
    if (response.statusCode == 200) {
      return jsonResponse;
    }

    // 에러 응답 - ApiError 모델로 파싱
    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse.containsKey('status') &&
        jsonResponse['status'] == 'error') {
      final apiError = ApiError.fromJson(jsonResponse);
      throw ApiException(apiError.message, apiError: apiError);
    }

    // 기타 에러
    throw ApiException(
        '서버 오류가 발생했습니다. (${response.statusCode}): ${response.body}');
  }
}

/// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final ApiError? apiError;

  ApiException(this.message, {this.apiError});

  @override
  String toString() => message;

  /// HTTP 상태 코드 반환
  int? get statusCode => apiError?.code;

  /// 에러 타입 반환
  String? get errorType => apiError?.error;

  /// 에러 상세 정보 반환
  Map<String, dynamic>? get detail => apiError?.detail;
}
