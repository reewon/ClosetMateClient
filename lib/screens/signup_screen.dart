import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validation.dart';

/// 회원가입 화면
/// 
/// 사용자가 이메일, 비밀번호, 사용자명, 성별을 입력하여 회원가입을 진행합니다.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  
  // 텍스트 입력 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  
  // 비밀번호 가시성 상태
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // 로딩 상태
  bool _isLoading = false;
  
  // 에러 메시지
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _usernameError;
  String? _genderError;
  
  // 성별 선택
  String? _selectedGender;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 20),
              _buildConfirmPasswordField(),
              const SizedBox(height: 20),
              _buildUsernameField(),
              const SizedBox(height: 20),
              _buildGenderSelection(),
              const SizedBox(height: 40),
              _buildSignupButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 (타이틀 & 서브타이틀)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ClosetMate',
          style: TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '내 옷장을 저장하고, 간편하게 코디하세요',
          style: TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 이메일 입력 필드
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: '이메일',
            labelStyle: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        if (_emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _emailError!,
              style: const TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  /// 비밀번호 입력 필드
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: '비밀번호',
            labelStyle: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _passwordError!,
              style: const TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  /// 비밀번호 확인 입력 필드
  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: const TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: '비밀번호 확인',
            labelStyle: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
        ),
        if (_confirmPasswordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _confirmPasswordError!,
              style: const TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  /// 사용자명 입력 필드
  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _usernameController,
          style: const TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: '닉네임',
            labelStyle: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        if (_usernameError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _usernameError!,
              style: const TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  /// 성별 선택
  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별',
          style: TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text(
                  '남성',
                  style: TextStyle(
                    fontFamily: 'GmarketSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: '남성',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                    _genderError = null;
                  });
                },
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.black,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text(
                  '여성',
                  style: TextStyle(
                    fontFamily: 'GmarketSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: '여성',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                    _genderError = null;
                  });
                },
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.black,
              ),
            ),
          ],
        ),
        if (_genderError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _genderError!,
              style: const TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  /// 회원가입 버튼
  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '가입하기',
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  /// 회원가입 처리
  Future<void> _handleSignup() async {
    // 입력값 가져오기
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final username = _usernameController.text.trim();
    final gender = _selectedGender ?? '';

    // 유효성 검증
    final emailError = Validation.getEmailError(email);
    final passwordError = Validation.getPasswordError(password);
    final confirmPasswordError = Validation.getPasswordConfirmError(password, confirmPassword);
    final usernameError = Validation.getUsernameError(username);
    final genderError = Validation.getGenderError(gender);

    // 에러가 있으면 표시
    if (emailError != null || passwordError != null || 
        confirmPasswordError != null || usernameError != null || 
        genderError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
        _usernameError = usernameError;
        _genderError = genderError;
      });
      return;
    }

    // 에러 초기화
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _usernameError = null;
      _genderError = null;
      _isLoading = true;
    });

    try {
      // AuthService를 통해 회원가입 (Firebase Auth + 서버 동기화)
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        gender: gender,
      );

      if (mounted) {
        // 회원가입 성공
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '회원가입 성공! 환영합니다.',
              style: TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // 이전 화면으로 돌아가기 (또는 메인 화면으로 이동)
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // 회원가입 실패
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: const TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}