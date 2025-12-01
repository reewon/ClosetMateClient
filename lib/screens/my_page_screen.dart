import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../api/api_client.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

/// 마이페이지 메인 화면
///
/// 사용자 정보를 표시하고, 프로필 수정 및 로그아웃 기능을 제공합니다.
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final AuthService _authService = AuthService();
  
  // 사용자 정보
  String? _username;
  String? _email;
  
  // 로딩 상태
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }
  
  /// 사용자 정보 로드
  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    
    try {
      final userInfo = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _username = userInfo['username'] as String?;
          _email = userInfo['email'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException 
                ? e.message 
                : '사용자 정보를 불러오는데 실패했습니다: $e'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            fontFamily: 'GmarketSans',
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 사용자 정보 카드
                  _buildUserInfoCard(),
                  const SizedBox(height: 24.0),
                  // 프로필 수정 버튼
                  _buildEditProfileButton(),
                  const SizedBox(height: 24.0),
                  // 로그아웃 버튼
                  _buildLogoutButton(),
                ],
              ),
            ),
    );
  }

  /// 사용자 정보 카드 위젯
  Widget _buildUserInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        child: Column(
          children: [
            Row(
              children: [
                // 프로필 아이콘 (원형, 연한 보라색 배경)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_circle_outlined,
                    size: 48,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 16.0),
                // 사용자 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      Text(
                        _username ?? '사용자명',
                        style: const TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      // Email
                      Text(
                        _email ?? '이메일',
                        style: TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // 구분선
            Divider(
              height: 1.0,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 수정 버튼 위젯
  Widget _buildEditProfileButton() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 2,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfileScreen(),
            ),
          );
          
          // 프로필 수정 화면에서 저장 후 돌아오면 사용자 정보 새로고침
          if (result == true) {
            _loadUserInfo();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          child: Row(
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 24,
                color: Colors.black,
              ),
              const SizedBox(width: 12.0),
              const Text(
                '프로필 수정',
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 로그아웃 버튼 위젯
  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () => _showLogoutDialog(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
      ),
      child: const Text(
        '로그아웃',
        style: TextStyle(
          fontFamily: 'GmarketSans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  /// 로그아웃 확인 다이얼로그 표시
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '로그아웃',
            style: TextStyle(
              fontFamily: 'GmarketSans',
              fontWeight: FontWeight.w500,
            ),
          ),
          content: const Text(
            '로그아웃 하시겠습니까?',
            style: TextStyle(
              fontFamily: 'GmarketSans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLogout();
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      
      if (mounted) {
        // 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

