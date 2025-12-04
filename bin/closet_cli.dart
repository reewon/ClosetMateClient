import '../lib/cli/menu.dart';
import '../lib/cli/prompt.dart';
import '../lib/utils/logger.dart';

/// ClosetMate CLI 진입점
/// 
/// 애플리케이션의 시작점입니다.
void main() async {
  // 초기화
  _initialize();

  // 로그인 (현재는 테스트 토큰 사용)
  _login();

  // 메인 메뉴 시작
  final menu = Menu();
  await menu.start();
}

/// 초기화
void _initialize() {
  Logger.blankLine();
  Logger.log('< ClosetMate >');
  Logger.blankLine();
}

/// 로그인
/// 
/// 현재는 테스트 토큰을 사용하므로 입력받은 아이디/비밀번호는
/// 환영 메시지에만 사용되고 실제 인증에는 사용되지 않습니다.
/// 
/// TODO: JWT 로그인 기능 구현 시 실제 로그인 로직 추가
void _login() {
  Logger.title('로그인');
  Logger.blankLine();
  
  // 아이디 입력 (환영 메시지용)
  final username = Prompt.input('아이디');
  
  // 비밀번호 입력 (테스트용 - 실제로는 test-token 사용)
  Prompt.input('비밀번호');
  
  // 환영 메시지
  Logger.success('${username}님 환영합니다!');
}