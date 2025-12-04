import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/api_error.dart';
import '../services/auth_service.dart';

/// HTTP API 클라이언트
/// 
/// 모든 HTTP 요청을 처리하고, 에러 응답을 파싱합니다.
/// Firebase ID 토큰을 사용합니다.
class ApiClient {
  final AuthService _authService;

  ApiClient({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Authorization 헤더 생성 (Firebase ID 토큰 사용)
  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await _authService.getIdToken();
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

  /// POST 요청 (multipart/form-data)
  /// 
  /// 이미지 파일을 multipart/form-data 형식으로 업로드합니다.
  /// 
  /// [url]: 요청할 URL
  /// [imageFile]: 업로드할 이미지 파일
  /// 반환: 파싱된 JSON 응답
  /// 예외: ApiException (에러 응답 시)
  Future<dynamic> postMultipart(String url, File imageFile) async {
    return await _requestWithRetry(() async {
      // MultipartRequest 생성
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Authorization 헤더 추가 (Content-Type은 자동 설정되므로 제외)
      final token = await _authService.getIdToken();
      request.headers['Authorization'] = 'Bearer $token';
      
      // 이미지 파일 추가
      // 파일 확장자에 따라 적절한 MediaType 설정
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      MediaType? contentType;
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'gif':
          contentType = MediaType('image', 'gif');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        default:
          contentType = MediaType('image', 'jpeg'); // 기본값
      }
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: contentType,
        ),
      );
      
      // 요청 전송
      final streamedResponse = await request.send();
      
      // StreamedResponse를 Response로 변환
      final response = await http.Response.fromStream(streamedResponse);

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
          await _authService.getIdToken(forceRefresh: true);
          return await request();
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
      // JSON 파싱 실패 시 (일반 텍스트 에러 응답 등)
      if (response.statusCode == 200) {
        throw ApiException('서버 응답을 파싱할 수 없습니다: ${response.body}');
      } else {
        // 에러 응답이 JSON이 아닌 경우 (예: 500 Internal Server Error)
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

    // 기타 에러 (JSON 형식이지만 에러 구조가 아닌 경우)
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