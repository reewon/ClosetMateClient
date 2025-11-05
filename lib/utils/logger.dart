import 'dart:io';

/// 콘솔 출력 스타일링 유틸리티
class Logger {
  /// 성공 메시지 출력 (✅)
  static void success(String message) {
    print('✅ $message');
  }

  /// 경고 메시지 출력 (⚠️)
  static void warning(String message) {
    print('⚠️ $message');
  }

  /// 에러 메시지 출력 (❌)
  static void error(String message) {
    print('❌ $message');
  }

  /// 정보 메시지 출력 (ℹ️)
  static void info(String message) {
    print('ℹ️ $message');
  }

  /// AI 관련 메시지 출력 (🤖)
  static void ai(String message) {
    print('🤖 $message');
  }

  /// 일반 메시지 출력
  static void log(String message) {
    print(message);
  }

  /// 빈 줄 출력
  static void blankLine() {
    print('');
  }

  /// 구분선 출력
  static void separator() {
    print('=' * 16);
  }

  /// 제목 출력
  static void title(String title) {
    print('\n> $title');
  }

  /// 메뉴 제목 출력
  static void menuTitle(String title) {
    print('\n===== $title =====');
  }
}

