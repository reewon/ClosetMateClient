import '../../lib/models/api_error.dart';

/// API 에러 응답 파싱 테스트 스크립트
/// 
/// 실행 방법: dart test/api/api_client_test.dart
void main() {
  print('=== API 에러 응답 파싱 테스트 ===\n');

  // 테스트 케이스 1: FastAPI의 detail 키로 감싸진 에러 응답
  print('테스트 1: FastAPI detail 형식');
  final testCase1 = {
    'detail': {
      'status': 'error',
      'code': 400,
      'error': 'Bad Request',
      'message': '잘못된 카테고리입니다. 가능한 값: top, bottom, shoes, outer',
      'detail': {'category': 'top'}
    }
  };

  try {
    final apiError1 = _parseErrorResponse(testCase1);
    if (apiError1 != null) {
      print('✅ 성공: ${apiError1.message}');
      print('   코드: ${apiError1.code}');
      print('   에러 타입: ${apiError1.error}\n');
    } else {
      print('❌ 실패: 에러 응답을 파싱하지 못함\n');
    }
  } catch (e) {
    print('❌ 실패: $e\n');
  }

  // 테스트 케이스 2: 직접 에러 응답 형식
  print('테스트 2: 직접 에러 응답 형식');
  final testCase2 = {
    'status': 'error',
    'code': 404,
    'error': 'Not Found',
    'message': '요청하신 리소스를 찾을 수 없습니다.',
    'detail': {'resource': 'closet_item', 'id': 123}
  };

  try {
    final apiError2 = _parseErrorResponse(testCase2);
    if (apiError2 != null) {
      print('✅ 성공: ${apiError2.message}');
      print('   코드: ${apiError2.code}');
      print('   에러 타입: ${apiError2.error}\n');
    } else {
      print('❌ 실패: 에러 응답을 파싱하지 못함\n');
    }
  } catch (e) {
    print('❌ 실패: $e\n');
  }

  // 테스트 케이스 3: 잘못된 형식 (에러가 아님)
  print('테스트 3: 에러가 아닌 응답');
  final testCase3 = {
    'status': 'success',
    'data': {'id': 1, 'name': 'test'}
  };

  try {
    final apiError3 = _parseErrorResponse(testCase3);
    if (apiError3 != null) {
      print('❌ 실패: 에러가 아닌데 파싱됨: ${apiError3.message}\n');
    } else {
      print('✅ 성공: 에러가 아니므로 파싱되지 않음\n');
    }
  } catch (e) {
    print('✅ 성공: 에러가 아니므로 파싱되지 않음\n');
  }

  print('=== 테스트 완료 ===');
}

/// 에러 응답 파싱 로직 (api_client.dart의 _handleResponse 로직과 동일)
ApiError? _parseErrorResponse(Map<String, dynamic> jsonResponse) {
  Map<String, dynamic>? errorData;

  // FastAPI의 detail 키로 감싸진 에러 응답 처리
  if (jsonResponse.containsKey('detail')) {
    final detail = jsonResponse['detail'];
    if (detail is Map<String, dynamic> &&
        detail.containsKey('status') &&
        detail['status'] == 'error') {
      errorData = detail as Map<String, dynamic>;
    }
  }

  // 직접 에러 응답 형식
  if (errorData == null &&
      jsonResponse.containsKey('status') &&
      jsonResponse['status'] == 'error') {
    errorData = jsonResponse;
  }

  // ApiError 모델로 파싱
  if (errorData != null) {
    return ApiError.fromJson(errorData);
  }

  return null;
}