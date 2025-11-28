import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'closet_screen.dart';
import 'today_outfit_screen.dart';
import 'favorites_screen.dart';

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

  // 각 탭에 해당하는 화면들
  final List<Widget> _screens = [
    const ClosetScreen(),
    const TodayOutfitScreen(),
    const FavoritesScreen(),
    const _PlaceholderScreen(title: '마이페이지'),
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
        selectedLabelStyle: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: '옷장',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconData(
                0xef7b, // Material Symbols apparel 아이콘 코드 포인트
                fontFamily: 'MaterialSymbolsRounded',
              ),
            ),
            label: '오늘의 코디',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
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

