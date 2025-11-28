/// 입력 유효성 검증 유틸리티
/// 
/// 이메일, 비밀번호, 사용자명, 성별 등의 입력값을 검증하는 함수들을 제공합니다.

class Validation {
  /// 이메일 형식 검증
  /// 
  /// [email]: 검증할 이메일 주소
  /// 반환: 유효한 이메일 형식이면 true, 아니면 false
  static bool isValidEmail(String email) {
    if (email.isEmpty) {
      return false;
    }
    
    // 기본적인 이메일 형식 검증 (정규식)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    return emailRegex.hasMatch(email);
  }

  /// 비밀번호 강도 검증
  /// 
  /// [password]: 검증할 비밀번호
  /// 반환: 유효한 비밀번호면 true, 아니면 false
  /// 
  /// Firebase Auth 요구사항: 최소 6자 이상
  static bool isValidPassword(String password) {
    if (password.isEmpty) {
      return false;
    }
    
    // Firebase Auth 최소 요구사항: 6자 이상
    if (password.length < 6) {
      return false;
    }
    
    return true;
  }

  /// 사용자명 검증
  /// 
  /// [username]: 검증할 사용자명
  /// 반환: 유효한 사용자명이면 true, 아니면 false
  /// 
  /// 규칙:
  /// - 공백만으로 구성될 수 없음
  /// - 최소 1자 이상
  /// - 최대 50자 이하 (서버 제한)
  static bool isValidUsername(String username) {
    if (username.isEmpty) {
      return false;
    }
    
    // 공백만으로 구성된 경우 (trim 후 빈 문자열)
    if (username.trim().isEmpty) {
      return false;
    }
    
    final trimmedUsername = username.trim();
    
    // 최소 길이 검증 (1자 이상)
    if (trimmedUsername.length < 1) {
      return false;
    }
    
    // 최대 길이 검증 (50자 이하)
    if (trimmedUsername.length > 50) {
      return false;
    }
    
    return true;
  }

  /// 성별 검증
  /// 
  /// [gender]: 검증할 성별
  /// 반환: 유효한 성별이면 true, 아니면 false
  /// 
  /// 유효한 값: "남성" 또는 "여성"
  static bool isValidGender(String gender) {
    if (gender.isEmpty) {
      return false;
    }
    
    // "남성" 또는 "여성"만 허용
    return gender == '남성' || gender == '여성';
  }

  /// 이메일 검증 에러 메시지
  /// 
  /// [email]: 검증할 이메일
  /// 반환: 에러 메시지 (유효하면 null)
  static String? getEmailError(String email) {
    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    if (!isValidEmail(email)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }

  /// 비밀번호 검증 에러 메시지
  /// 
  /// [password]: 검증할 비밀번호
  /// 반환: 에러 메시지 (유효하면 null)
  static String? getPasswordError(String password) {
    if (password.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (password.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    return null;
  }

  /// 사용자명 검증 에러 메시지
  /// 
  /// [username]: 검증할 사용자명
  /// 반환: 에러 메시지 (유효하면 null)
  static String? getUsernameError(String username) {
    if (username.isEmpty) {
      return '사용자명을 입력해주세요.';
    }
    if (username.trim().isEmpty) {
      return '사용자명은 공백만으로 구성될 수 없습니다.';
    }
    return null;
  }

  /// 성별 검증 에러 메시지
  /// 
  /// [gender]: 검증할 성별
  /// 반환: 에러 메시지 (유효하면 null)
  static String? getGenderError(String gender) {
    if (gender.isEmpty) {
      return '성별을 선택해주세요.';
    }
    if (!isValidGender(gender)) {
      return '성별은 "남성" 또는 "여성"만 선택 가능합니다.';
    }
    return null;
  }

  /// 비밀번호 확인 검증 에러 메시지
  /// 
  /// [password]: 원본 비밀번호
  /// [confirmPassword]: 확인용 비밀번호
  /// 반환: 에러 메시지 (일치하면 null)
  static String? getPasswordConfirmError(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return '비밀번호 확인을 입력해주세요.';
    }
    if (password != confirmPassword) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return null;
  }
}

