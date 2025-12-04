import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validation.dart';
import 'signup_screen.dart';
import 'main_screen.dart';

/// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Closet Mate 로고
              _buildLogo(),
              const SizedBox(height: 60),
              // 아이디 입력 필드
              _buildIdField(),
              const SizedBox(height: 24),
              // 비밀번호 입력 필드
              _buildPasswordField(),
              // 에러 메시지 표시
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(),
              ],
              const SizedBox(height: 32),
              // 로그인 버튼
              _buildLoginButton(),
              const SizedBox(height: 24),
              // 하단 링크들
              _buildBottomLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/closet_mate_logo.png',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 이미지 로드 실패 시 텍스트로 대체
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Closet',
                    style: TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontSize: 20,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'Mate',
                    style: TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontSize: 20,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '아이디',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _idController,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
          onChanged: (_) {
            // 입력 시 에러 메시지 제거
            if (_errorMessage != null) {
              setState(() {
                _errorMessage = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: '이메일을 입력하세요',
            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Color(0xFF9E9E9E),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF6C7A89),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '비밀번호',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          enabled: !_isLoading,
          onChanged: (_) {
            // 입력 시 에러 메시지 제거
            if (_errorMessage != null) {
              setState(() {
                _errorMessage = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: '비밀번호를 입력하세요',
            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.lock_outlined,
              color: Color(0xFF9E9E9E),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF9E9E9E),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF6C7A89),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    // 입력값 가져오기
    final email = _idController.text.trim();
    final password = _passwordController.text;

    // 유효성 검증
    final emailError = Validation.getEmailError(email);
    
    // 로그인 시 비밀번호 길이 검증은 불필요 (빈 값만 체크)
    String? passwordError;
    if (password.isEmpty) {
      passwordError = '비밀번호를 입력해주세요.';
    }

    if (emailError != null || passwordError != null) {
      setState(() {
        _errorMessage = emailError ?? passwordError;
      });
      return;
    }

    // 로딩 시작
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 로그인 시도
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      // 로그인 성공
      if (mounted) {
        // 메인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 성공!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 로그인 실패
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C7A89),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF9E9E9E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLink('아이디 찾기', () {
          // TODO: 아이디 찾기 화면으로 이동
        }),
        const Text(
          ' | ',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 14,
          ),
        ),
        _buildLink('비밀번호 찾기', () {
          // TODO: 비밀번호 찾기 화면으로 이동
        }),
        const Text(
          ' | ',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 14,
          ),
        ),
        _buildLink('회원가입', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2C2C2C),
          fontSize: 14,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}