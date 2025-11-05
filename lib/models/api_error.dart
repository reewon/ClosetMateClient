/// API 에러 응답 모델
/// 
/// 서버에서 반환하는 에러 응답을 나타내는 모델입니다.
class ApiError {
  final String status;
  final int code;
  final String error;
  final String message;
  final Map<String, dynamic>? detail;

  ApiError({
    required this.status,
    required this.code,
    required this.error,
    required this.message,
    this.detail,
  });

  /// JSON에서 ApiError 객체 생성
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      status: json['status'] as String,
      code: json['code'] as int,
      error: json['error'] as String,
      message: json['message'] as String,
      detail: json['detail'] as Map<String, dynamic>?,
    );
  }

  /// ApiError 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'error': error,
      'message': message,
      if (detail != null) 'detail': detail,
    };
  }

  @override
  String toString() {
    return message;
  }
}

