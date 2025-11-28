import 'package:flutter/material.dart';

/// 메인 화면 - 하단 탭 네비게이션
/// 
/// 4개의 메인 화면을 탭으로 전환합니다:
/// - 옷장
/// - 오늘의 코디
/// - 즐겨찾는 코디
/// - 마이페이지
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 각 탭에 해당하는 화면들 (임시 placeholder)
  final List<Widget> _screens = [
    _PlaceholderScreen(title: '옷장'),
    _PlaceholderScreen(title: '오늘의 코디'),
    _PlaceholderScreen(title: '즐겨찾는 코디'),
    _PlaceholderScreen(title: '마이페이지'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'GmarketSans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'GmarketSans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: '옷장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: '오늘의 코디',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '즐겨찾는 코디',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}

/// 임시 Placeholder 화면
/// 
/// 실제 화면이 구현되기 전까지 사용되는 임시 화면입니다.
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'GmarketSans',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '$title 화면',
          style: const TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

