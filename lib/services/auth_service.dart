import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../api/endpoints.dart';
import '../api/api_client.dart';
import '../models/api_error.dart';

/// 인증 서비스 레이어
/// 
/// Firebase Auth와 서버 API를 연동하여 인증 기능을 제공합니다.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firebase Auth 인스턴스
  FirebaseAuth get auth => _auth;

  /// 현재 로그인한 사용자
  User? get currentUser => _auth.currentUser;

  /// 회원가입
  /// 
  /// [email]: 이메일 주소
  /// [password]: 비밀번호 (최소 6자)
  /// [username]: 사용자명
  /// [gender]: 성별 ("남성" 또는 "여성")
  /// 
  /// 반환: UserCredential
  /// 예외: FirebaseAuthException 또는 ApiException
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String gender,
  }) async {
    try {
      // 1. Firebase 회원가입
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Firebase 회원가입 성공 후 서버 API 호출 필수
      try {
        // ID 토큰 획득
        final idToken = await userCredential.user?.getIdToken(false);
        if (idToken == null) {
          throw Exception('ID 토큰을 가져올 수 없습니다.');
        }

        // 서버에 사용자 정보 동기화
        await _syncUserInfo(
          idToken: idToken,
          username: username,
          gender: gender,
        );
      } catch (e) {
        // 서버 동기화 실패 시 Firebase 사용자는 이미 생성됨
        // 사용자에게 재시도 안내 필요
        throw Exception(
          '회원가입은 완료되었지만 서버 동기화에 실패했습니다. 나중에 다시 시도해주세요: $e',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그인
  /// 
  /// [email]: 이메일 주소
  /// [password]: 비밀번호
  /// 
  /// 반환: UserCredential
  /// 예외: FirebaseAuthException
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  /// 
  /// 예외: FirebaseAuthException
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  /// ID 토큰 획득
  /// 
  /// [forceRefresh]: true로 설정하면 토큰을 강제로 갱신
  /// 
  /// 반환: ID 토큰 문자열
  /// 예외: FirebaseAuthException
  Future<String> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다.');
      }
      final idToken = await user.getIdToken(forceRefresh);
      if (idToken == null) {
        throw Exception('ID 토큰을 가져올 수 없습니다.');
      }
      return idToken;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('토큰을 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 현재 사용자 정보 조회 (서버에서)
  /// 
  /// 반환: 사용자 정보 Map (id, firebase_uid, email, username, gender)
  /// 예외: ApiException
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // ID 토큰 획득
      final idToken = await getIdToken();

      // 서버 API 호출
      final response = await http.get(
        Uri.parse(Endpoints.authMe),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      // 응답 처리
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        // 에러 응답 처리
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        if (errorData is Map<String, dynamic> && errorData['status'] == 'error') {
          final apiError = ApiError.fromJson(errorData);
          throw ApiException(apiError.message, apiError: apiError);
        }
        throw ApiException('서버 오류가 발생했습니다. (${response.statusCode})');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('사용자 정보를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 인증 상태 변경 스트림
  /// 
  /// 로그인/로그아웃 상태 변경을 감지할 수 있는 Stream
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// 사용자 정보 동기화 (서버에)
  /// 
  /// [idToken]: Firebase ID 토큰
  /// [username]: 사용자명
  /// [gender]: 성별 ("남성" 또는 "여성")
  /// 
  /// 반환: 동기화된 사용자 정보
  /// 예외: ApiException
  Future<Map<String, dynamic>> _syncUserInfo({
    required String idToken,
    required String username,
    required String gender,
  }) async {
    try {
      final url = Endpoints.authSync;
      final requestBody = jsonEncode({
        'username': username,
        'gender': gender,
      });
      
      // 디버깅: 요청 정보 로깅
      debugPrint('서버 동기화 요청: $url');
      debugPrint('요청 본문: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: requestBody,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw ApiException('서버 연결 시간이 초과되었습니다. 서버가 실행 중인지 확인해주세요.');
        },
      );

      // 디버깅: 응답 정보 로깅
      debugPrint('서버 응답 상태 코드: ${response.statusCode}');
      debugPrint('서버 응답 본문: ${response.body}');

      // 응답 처리
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        // 에러 응답 처리
        String errorMessage = '서버 오류가 발생했습니다. (${response.statusCode})';
        
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          if (errorData is Map<String, dynamic>) {
            if (errorData['status'] == 'error') {
              final apiError = ApiError.fromJson(errorData);
              errorMessage = apiError.message;
              throw ApiException(errorMessage, apiError: apiError);
            } else if (errorData.containsKey('detail')) {
              // FastAPI 스타일 에러 응답
              final detail = errorData['detail'];
              if (detail is String) {
                errorMessage = detail;
              } else if (detail is Map<String, dynamic> && detail.containsKey('msg')) {
                errorMessage = detail['msg'].toString();
              }
            }
          }
        } catch (e) {
          // JSON 파싱 실패 시 원본 응답 본문 사용
          if (response.body.isNotEmpty) {
            errorMessage = '서버 오류 (${response.statusCode}): ${response.body}';
          }
        }
        
        throw ApiException(errorMessage);
      }
    } on SocketException catch (e) {
      throw ApiException('서버에 연결할 수 없습니다. 서버가 실행 중인지 확인해주세요: ${e.message}');
    } on HttpException catch (e) {
      throw ApiException('HTTP 오류가 발생했습니다: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('사용자 정보 동기화 중 오류가 발생했습니다: $e');
    }
  }

  /// 프로필 정보 수정 (username, gender)
  /// 
  /// [username]: 사용자명 (null이면 변경하지 않음)
  /// [gender]: 성별 ("남성" 또는 "여성", null이면 변경하지 않음)
  /// 
  /// 반환: 업데이트된 사용자 정보
  /// 예외: ApiException
  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? gender,
  }) async {
    try {
      // ID 토큰 획득
      final idToken = await getIdToken();

      // 요청 본문 구성 (null이 아닌 값만 포함)
      final Map<String, dynamic> requestBody = {};
      if (username != null) {
        requestBody['username'] = username;
      }
      if (gender != null) {
        requestBody['gender'] = gender;
      }

      // 요청 본문이 비어있으면 예외 발생
      if (requestBody.isEmpty) {
        throw ApiException('변경할 정보가 없습니다.');
      }

      final url = Endpoints.authSync;
      final requestBodyJson = jsonEncode(requestBody);

      // 디버깅: 요청 정보 로깅
      debugPrint('프로필 수정 요청: $url');
      debugPrint('요청 본문: $requestBodyJson');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: requestBodyJson,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw ApiException('서버 연결 시간이 초과되었습니다. 서버가 실행 중인지 확인해주세요.');
        },
      );

      // 디버깅: 응답 정보 로깅
      debugPrint('서버 응답 상태 코드: ${response.statusCode}');
      debugPrint('서버 응답 본문: ${response.body}');

      // 응답 처리
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        // 에러 응답 처리
        String errorMessage = '서버 오류가 발생했습니다. (${response.statusCode})';

        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          if (errorData is Map<String, dynamic>) {
            if (errorData['status'] == 'error') {
              final apiError = ApiError.fromJson(errorData);
              errorMessage = apiError.message;
              throw ApiException(errorMessage, apiError: apiError);
            } else if (errorData.containsKey('detail')) {
              // FastAPI 스타일 에러 응답
              final detail = errorData['detail'];
              if (detail is String) {
                errorMessage = detail;
              } else if (detail is Map<String, dynamic> && detail.containsKey('msg')) {
                errorMessage = detail['msg'].toString();
              }
            }
          }
        } catch (e) {
          // JSON 파싱 실패 시 원본 응답 본문 사용
          if (response.body.isNotEmpty) {
            errorMessage = '서버 오류 (${response.statusCode}): ${response.body}';
          }
        }

        throw ApiException(errorMessage);
      }
    } on SocketException catch (e) {
      throw ApiException('서버에 연결할 수 없습니다. 서버가 실행 중인지 확인해주세요: ${e.message}');
    } on HttpException catch (e) {
      throw ApiException('HTTP 오류가 발생했습니다: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('프로필 수정 중 오류가 발생했습니다: $e');
    }
  }

  /// Firebase 재인증 헬퍼 메서드
  /// 
  /// [email]: 사용자 이메일
  /// [password]: 현재 비밀번호
  /// 
  /// 반환: UserCredential
  /// 예외: FirebaseAuthException
  Future<UserCredential> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다.');
      }

      // 이메일/비밀번호로 인증 정보 생성
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // 재인증 수행
      return await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('재인증 중 오류가 발생했습니다: $e');
    }
  }

  /// 이메일 변경
  /// 
  /// [newEmail]: 새로운 이메일 주소
  /// [password]: 현재 비밀번호 (재인증용)
  /// 
  /// 예외: FirebaseAuthException 또는 ApiException
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다.');
      }

      // 현재 이메일로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // 이메일 변경 (Firebase Auth 6.x에서는 verifyBeforeUpdateEmail 사용)
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('이메일 변경 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 변경
  /// 
  /// [currentPassword]: 현재 비밀번호 (재인증용)
  /// [newPassword]: 새로운 비밀번호
  /// 
  /// 예외: FirebaseAuthException
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다.');
      }

      // 현재 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 비밀번호 변경 (재인증 후 원래 user 객체에서 직접 호출)
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('비밀번호 변경 중 오류가 발생했습니다: $e');
    }
  }

  /// Firebase Auth 예외를 사용자 친화적 메시지로 변환
  /// 
  /// [e]: FirebaseAuthException
  /// 반환: 사용자 친화적 예외 메시지
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('이미 사용 중인 이메일입니다.');
      case 'weak-password':
        return Exception('비밀번호는 6자 이상이어야 합니다.');
      case 'invalid-email':
        return Exception('올바른 이메일 형식이 아닙니다.');
      case 'user-not-found':
        return Exception('등록되지 않은 사용자입니다.');
      case 'wrong-password':
        return Exception('비밀번호가 올바르지 않습니다.');
      case 'network-request-failed':
        return Exception('네트워크 오류가 발생했습니다.');
      case 'too-many-requests':
        return Exception('너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.');
      case 'user-disabled':
        return Exception('이 계정은 비활성화되었습니다.');
      case 'operation-not-allowed':
        return Exception('이 작업은 허용되지 않습니다.');
      case 'invalid-credential':
        return Exception('인증 정보가 올바르지 않습니다.');
      default:
        return Exception('인증 중 오류가 발생했습니다: ${e.message ?? e.code}');
    }
  }
}

