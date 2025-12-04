import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

/// ClosetMate Flutter 앱 진입점
/// 
/// Flutter GUI 애플리케이션의 시작점입니다.
/// CLI 버전은 bin/closet_cli.dart를 참조하세요.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase 초기화 성공');
  } catch (e) {
    // Firebase 초기화 실패 시 에러 처리 및 로깅
    debugPrint('Firebase 초기화 실패: $e');
    // 앱은 계속 실행되지만 Firebase 기능은 사용할 수 없음
  }
  
  runApp(const ClosetMateApp());
}

/// ClosetMate 메인 앱 위젯
class ClosetMateApp extends StatelessWidget {
  const ClosetMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClosetMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}