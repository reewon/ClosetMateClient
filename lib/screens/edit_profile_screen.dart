import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../api/api_client.dart';
import '../utils/validation.dart';

/// 프로필 수정 화면
///
/// 사용자 정보(사용자명, 성별, 이메일, 비밀번호)를 수정할 수 있는 화면입니다.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  
  // 텍스트 입력 컨트롤러
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // 비밀번호 가시성 상태
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  // 성별 선택
  String? _selectedGender;
  
  // 원본 사용자 정보 (변경사항 감지용)
  String? _originalUsername;
  String? _originalEmail;
  String? _originalGender;
  
  // 로딩 상태
  bool _isLoading = false;
  bool _isLoadingUserInfo = true;
  
  // 에러 메시지
  String? _usernameError;
  String? _emailError;
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }
  
  /// 사용자 정보 로드
  Future<void> _loadUserInfo() async {
    setState(() => _isLoadingUserInfo = true);
    
    try {
      final userInfo = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _originalUsername = userInfo['username'] as String?;
          _originalEmail = userInfo['email'] as String?;
          _originalGender = userInfo['gender'] as String?;
          
          _usernameController.text = _originalUsername ?? '';
          _emailController.text = _originalEmail ?? '';
          _selectedGender = _originalGender;
          
          _isLoadingUserInfo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUserInfo = false);
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
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
          onPressed: () => _handleBackButton(),
        ),
        centerTitle: true,
        title: const Text(
          '프로필 수정',
          style: TextStyle(
            fontFamily: 'GmarketSans',
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      fontFamily: 'GmarketSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoadingUserInfo
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  // 기본 정보 섹션
                  _buildBasicInfoSection(),
                  // 구분선
                  const Divider(
                    height: 1.0,
                    color: Colors.grey,
                    thickness: 1.0,
                  ),
                  const SizedBox(height: 24.0),
                  // 보안 정보 섹션
                  _buildSecurityInfoSection(),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
    );
  }

  /// 기본 정보 섹션
  Widget _buildBasicInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자명 입력 필드
          _buildUsernameField(),
          const SizedBox(height: 20.0),
          // 성별 선택
          _buildGenderSelection(),
        ],
      ),
    );
  }

  /// 보안 정보 섹션
  Widget _buildSecurityInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이메일 입력 필드
          _buildEmailField(),
          const SizedBox(height: 20.0),
          // 비밀번호 변경 섹션
          _buildPasswordChangeSection(),
        ],
      ),
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
            labelText: '사용자명',
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
            errorText: _usernameError,
          ),
          onChanged: (_) {
            setState(() => _usernameError = null);
          },
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
                  });
                },
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.black,
              ),
            ),
          ],
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
            errorText: _emailError,
          ),
          onChanged: (_) {
            setState(() => _emailError = null);
          },
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

  /// 비밀번호 변경 섹션
  Widget _buildPasswordChangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '비밀번호 변경',
          style: TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20.0),
        // 현재 비밀번호 입력 필드
        _buildPasswordField(
          controller: _currentPasswordController,
          label: '현재 비밀번호',
          obscureText: _obscureCurrentPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
          errorText: _currentPasswordError,
          onChanged: () {
            setState(() => _currentPasswordError = null);
          },
        ),
        const SizedBox(height: 20.0),
        // 새 비밀번호 입력 필드
        _buildPasswordField(
          controller: _newPasswordController,
          label: '새 비밀번호',
          obscureText: _obscureNewPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
          errorText: _newPasswordError,
          onChanged: () {
            setState(() => _newPasswordError = null);
          },
        ),
        const SizedBox(height: 20.0),
        // 새 비밀번호 확인 입력 필드
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: '새 비밀번호 확인',
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          errorText: _confirmPasswordError,
          onChanged: () {
            setState(() => _confirmPasswordError = null);
          },
        ),
      ],
    );
  }

  /// 비밀번호 입력 필드 (재사용 가능)
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? errorText,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
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
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onToggleVisibility,
            ),
            errorText: errorText,
          ),
          onChanged: (_) => onChanged?.call(),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText,
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
  
  /// 뒤로가기 버튼 처리
  Future<void> _handleBackButton() async {
    if (_hasChanges()) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '변경사항 저장',
              style: TextStyle(
                fontFamily: 'GmarketSans',
                fontWeight: FontWeight.w500,
              ),
            ),
            content: const Text(
              '저장하지 않고 나가시겠습니까?',
              style: TextStyle(
                fontFamily: 'GmarketSans',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    fontFamily: 'GmarketSans',
                    color: Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  '나가기',
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
      
      if (shouldPop == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
  
  /// 변경사항이 있는지 확인
  bool _hasChanges() {
    final usernameChanged = _usernameController.text.trim() != (_originalUsername ?? '');
    final emailChanged = _emailController.text.trim() != (_originalEmail ?? '');
    final genderChanged = _selectedGender != _originalGender;
    final passwordChanged = _newPasswordController.text.isNotEmpty;
    
    return usernameChanged || emailChanged || genderChanged || passwordChanged;
  }
  
  /// 저장 처리
  Future<void> _handleSave() async {
    // 모든 에러 초기화
    setState(() {
      _usernameError = null;
      _emailError = null;
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });
    
    // 입력값 가져오기
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    // 검증
    bool hasError = false;
    
    // 사용자명 검증
    final usernameError = Validation.getUsernameError(username);
    if (usernameError != null) {
      setState(() => _usernameError = usernameError);
      hasError = true;
    }
    
    // 이메일 검증
    final emailError = Validation.getEmailError(email);
    if (emailError != null) {
      setState(() => _emailError = emailError);
      hasError = true;
    }
    
    // 비밀번호 변경 검증 (새 비밀번호가 입력된 경우)
    if (newPassword.isNotEmpty) {
      // 현재 비밀번호 검증
      if (currentPassword.isEmpty) {
        setState(() => _currentPasswordError = '현재 비밀번호를 입력해주세요.');
        hasError = true;
      }
      
      // 새 비밀번호 검증
      final newPasswordError = Validation.getPasswordError(newPassword);
      if (newPasswordError != null) {
        setState(() => _newPasswordError = newPasswordError);
        hasError = true;
      }
      
      // 비밀번호 확인 검증
      final confirmPasswordError = Validation.getPasswordConfirmError(newPassword, confirmPassword);
      if (confirmPasswordError != null) {
        setState(() => _confirmPasswordError = confirmPasswordError);
        hasError = true;
      }
    }
    
    // 이메일 변경 검증 (이메일이 변경된 경우)
    if (email != (_originalEmail ?? '') && currentPassword.isEmpty) {
      setState(() => _currentPasswordError = '이메일 변경을 위해 현재 비밀번호를 입력해주세요.');
      hasError = true;
    }
    
    if (hasError) {
      return;
    }
    
    // 로딩 시작
    setState(() => _isLoading = true);
    
    try {
      // 변경사항 확인 및 업데이트
      final usernameChanged = username != (_originalUsername ?? '');
      final genderChanged = _selectedGender != _originalGender;
      final emailChanged = email != (_originalEmail ?? '');
      final passwordChanged = newPassword.isNotEmpty;
      
      // 기본 정보 변경 (username, gender)
      if (usernameChanged || genderChanged) {
        await _authService.updateProfile(
          username: usernameChanged ? username : null,
          gender: _selectedGender, // 항상 현재 선택된 gender 값을 보냅니다
        );
      }
      
      // 이메일 변경
      if (emailChanged) {
        await _authService.updateEmail(
          newEmail: email,
          password: currentPassword,
        );
      }
      
      // 비밀번호 변경
      if (passwordChanged) {
        await _authService.updatePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
      }
      
      // 모든 업데이트 성공
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 수정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // true를 반환하여 마이페이지에서 새로고침
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        String errorMessage = '프로필 수정 중 오류가 발생했습니다.';
        if (e is ApiException) {
          errorMessage = e.message;
        } else if (e.toString().contains('wrong-password') || 
                   e.toString().contains('비밀번호가 올바르지 않습니다')) {
          errorMessage = '현재 비밀번호가 올바르지 않습니다.';
          setState(() => _currentPasswordError = errorMessage);
        } else {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}