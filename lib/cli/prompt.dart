import 'dart:io';
import '../utils/config.dart';
import '../utils/logger.dart';

/// 사용자 입력 처리
/// 
/// CLI에서 사용자 입력을 받고 유효성을 검사합니다.
class Prompt {
  /// 기본 입력 받기
  /// 
  /// [message]: 입력 프롬프트 메시지
  /// 반환: 사용자가 입력한 문자열
  static String input(String message) {
    stdout.write('$message: ');
    return stdin.readLineSync() ?? '';
  }

  /// 선택 입력 받기 (번호)
  /// 
  /// [message]: 입력 프롬프트 메시지
  /// 반환: 사용자가 입력한 문자열
  static String select(String message) {
    stdout.write('$message: ');
    return stdin.readLineSync() ?? '';
  }

  /// 카테고리 선택
  /// 
  /// [allowBack]: 뒤로가기(B) 허용 여부
  /// 반환: 선택한 카테고리 또는 'B' (뒤로가기), null (잘못된 입력)
  static String? selectCategory({bool allowBack = true}) {
    final backOption = allowBack ? '/B:뒤로가기' : '';
    stdout.write('카테고리를 선택하세요 (상의/하의/신발/아우터$backOption): ');
    final input = stdin.readLineSync()?.trim() ?? '';

    // 뒤로가기
    if (allowBack && input.toUpperCase() == 'B') {
      return 'B';
    }

    // 유효한 카테고리인지 확인
    if (Config.isValidCategory(input)) {
      return input;
    }

    Logger.error('잘못된 카테고리입니다.');
    return null;
  }

  /// 숫자 입력 받기
  /// 
  /// [message]: 입력 프롬프트 메시지
  /// [allowBack]: 뒤로가기(B) 허용 여부
  /// 반환: 입력한 숫자, -1 (뒤로가기), null (잘못된 입력)
  static int? inputNumber(String message, {bool allowBack = true}) {
    final backOption = allowBack ? ' / B:뒤로가기' : '';
    stdout.write('$message$backOption: ');
    final input = stdin.readLineSync()?.trim() ?? '';

    // 뒤로가기
    if (allowBack && input.toUpperCase() == 'B') {
      return -1;
    }

    // 숫자로 변환 시도
    final number = int.tryParse(input);
    if (number == null) {
      Logger.error('올바른 숫자를 입력해주세요.');
      return null;
    }

    return number;
  }

  /// 아이템 ID 입력 받기
  /// 
  /// 반환: 입력한 ID, -1 (뒤로가기), null (잘못된 입력)
  static int? selectItemId() {
    stdout.write('> 아이템 선택 (id 입력 / B:뒤로가기): ');
    final input = stdin.readLineSync()?.trim() ?? '';

    // 뒤로가기
    if (input.toUpperCase() == 'B') {
      return -1;
    }

    // 숫자로 변환 시도
    final id = int.tryParse(input);
    if (id == null) {
      Logger.error('올바른 ID를 입력해주세요.');
      return null;
    }

    return id;
  }

  /// 텍스트 입력 받기 (뒤로가기 지원)
  /// 
  /// [message]: 입력 프롬프트 메시지
  /// 반환: 입력한 텍스트, null (뒤로가기 또는 빈 입력)
  static String? inputText(String message) {
    Logger.blankLine();
    Logger.log('> $message (뒤로가려면 B 입력):');
    stdout.write('입력: ');
    final input = stdin.readLineSync()?.trim() ?? '';

    // 뒤로가기
    if (input.toUpperCase() == 'B') {
      return null;
    }

    // 빈 입력
    if (input.isEmpty) {
      Logger.error('입력값이 비어있습니다.');
      return null;
    }

    return input;
  }

  /// 확인 (Y/N)
  /// 
  /// [message]: 확인 메시지
  /// 반환: true (Y), false (N 또는 기타)
  static bool confirm(String message) {
    Logger.warning('$message (Y/N): ');
    stdout.write('');
    final input = stdin.readLineSync()?.trim().toUpperCase() ?? '';
    return input == 'Y';
  }

  /// 메뉴 선택
  /// 
  /// [min]: 최소 선택 번호
  /// [max]: 최대 선택 번호
  /// 반환: 선택한 번호, null (잘못된 입력)
  static int? selectMenu(int min, int max) {
    stdout.write('선택: ');
    final input = stdin.readLineSync()?.trim() ?? '';

    final number = int.tryParse(input);
    if (number == null || number < min || number > max) {
      Logger.error('올바른 번호를 선택해주세요. ($min~$max)');
      return null;
    }

    return number;
  }
}
