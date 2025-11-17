# Firebase Authentication 통합 가이드

이 문서는 Python FastAPI 서버와 Flutter 클라이언트에 Firebase Authentication을 통합하는 방법을 설명합니다.

## 개요

Firebase Authentication을 사용하면:
- **서버 측**: Firebase Admin SDK로 클라이언트에서 받은 ID 토큰을 검증
- **클라이언트 측**: Firebase Auth SDK로 사용자 인증 및 ID 토큰 획득

## 1. Firebase 프로젝트 설정

### 1.1 Firebase Console 설정
1. [Firebase Console](https://console.firebase.google.com/)에서 프로젝트 생성
2. Authentication 활성화
3. 원하는 로그인 방법 활성화 (이메일/비밀번호, Google, 등)
4. 서비스 계정 키 다운로드:
   - 프로젝트 설정 → 서비스 계정 → 새 비공개 키 생성
   - JSON 파일을 서버 프로젝트에 저장 (예: `firebase-service-account.json`)

## 2. Python FastAPI 서버 구현

### 2.1 필요한 패키지 설치

```bash
pip install firebase-admin
```

`requirements.txt`에 추가:
```
firebase-admin>=6.0.0
```

### 2.2 Firebase Admin SDK 초기화

`app/core/firebase.py` 파일 생성:

```python
import firebase_admin
from firebase_admin import credentials, auth
from pathlib import Path
from typing import Optional
import os

# Firebase Admin SDK 초기화 (싱글톤 패턴)
_firebase_app: Optional[firebase_admin.App] = None


def initialize_firebase():
    """Firebase Admin SDK 초기화"""
    global _firebase_app
    
    if _firebase_app is not None:
        return _firebase_app
    
    # 서비스 계정 키 파일 경로
    service_account_path = Path(__file__).parent.parent.parent / "firebase-service-account.json"
    
    # 환경 변수로도 설정 가능
    if not service_account_path.exists():
        service_account_path = os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH")
        if service_account_path:
            service_account_path = Path(service_account_path)
    
    if not service_account_path or not service_account_path.exists():
        raise FileNotFoundError(
            f"Firebase 서비스 계정 키 파일을 찾을 수 없습니다: {service_account_path}"
        )
    
    cred = credentials.Certificate(str(service_account_path))
    _firebase_app = firebase_admin.initialize_app(cred)
    
    return _firebase_app


def get_firebase_app() -> firebase_admin.App:
    """Firebase App 인스턴스 반환"""
    if _firebase_app is None:
        initialize_firebase()
    return _firebase_app


def verify_firebase_token(id_token: str) -> dict:
    """
    Firebase ID 토큰 검증
    
    Args:
        id_token: Firebase에서 발급한 ID 토큰
        
    Returns:
        dict: 검증된 토큰의 디코딩된 정보 (uid, email 등)
        
    Raises:
        UnauthorizedException: 토큰이 유효하지 않은 경우
    """
    from ..core.exceptions import UnauthorizedException
    
    try:
        # Firebase Admin SDK로 토큰 검증
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token
    except auth.InvalidIdTokenError:
        raise UnauthorizedException(
            message="유효하지 않은 인증 토큰입니다.",
            detail={"error": "Invalid ID token"}
        )
    except auth.ExpiredIdTokenError:
        raise UnauthorizedException(
            message="만료된 인증 토큰입니다.",
            detail={"error": "Expired ID token"}
        )
    except Exception as e:
        raise UnauthorizedException(
            message="토큰 검증 중 오류가 발생했습니다.",
            detail={"error": str(e)}
        )
```

### 2.3 Firebase 인증 미들웨어 생성

`app/utils/auth_firebase.py` 파일 생성:

```python
"""
Firebase Authentication 미들웨어
"""

from fastapi import Depends, Header
from typing import Optional
from ..core.firebase import verify_firebase_token
from ..core.exceptions import UnauthorizedException


def verify_firebase_auth(
    authorization: Optional[str] = Header(None)
) -> dict:
    """
    Firebase ID 토큰을 검증하고 사용자 정보를 반환
    
    Args:
        authorization: Authorization 헤더 값 (형식: "Bearer <firebase_id_token>")
    
    Returns:
        dict: Firebase 사용자 정보 {
            "uid": str,           # Firebase UID
            "email": str,         # 사용자 이메일
            "email_verified": bool,
            "name": str,          # 사용자 이름 (있는 경우)
            "firebase_user": dict # 전체 Firebase 사용자 정보
        }
    
    Raises:
        UnauthorizedException: 토큰이 유효하지 않은 경우
    """
    if not authorization:
        raise UnauthorizedException(
            message="인증 토큰이 제공되지 않았습니다.",
            detail={"header": "Authorization"}
        )
    
    # "Bearer <token>" 형식에서 토큰 추출
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise UnauthorizedException(
            message="인증 헤더 형식이 올바르지 않습니다. 'Bearer <token>' 형식을 사용하세요.",
            detail={"format": "Bearer <token>"}
        )
    
    id_token = parts[1]
    
    # Firebase 토큰 검증
    decoded_token = verify_firebase_token(id_token)
    
    # 사용자 정보 추출
    return {
        "uid": decoded_token.get("uid"),
        "email": decoded_token.get("email"),
        "email_verified": decoded_token.get("email_verified", False),
        "name": decoded_token.get("name"),
        "firebase_user": decoded_token
    }
```

### 2.4 User 모델 수정

`app/models/user.py` 수정:

```python
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from ..core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    firebase_uid = Column(String, unique=True, index=True)  # Firebase UID 추가
    username = Column(String, unique=True, index=True, nullable=True)  # 선택적
    email = Column(String, unique=True, index=True)  # 이메일 추가
    name = Column(String, nullable=True)  # 이름 추가
    
    # 관계 정의
    closet_items = relationship("ClosetItem", back_populates="user", cascade="all, delete-orphan")
    today_outfit = relationship("TodayOutfit", back_populates="user", uselist=False, cascade="all, delete-orphan")
    favorite_outfits = relationship("FavoriteOutfit", back_populates="user", cascade="all, delete-orphan")
```

### 2.5 Dependencies 수정

`app/utils/dependencies.py` 수정:

```python
from fastapi import Depends
from sqlalchemy.orm import Session
from typing import Dict
from ..core.database import get_db
from ..utils.auth_firebase import verify_firebase_auth
from ..models.user import User
from ..core.exceptions import NotFoundException


def get_current_user(
    firebase_user: Dict = Depends(verify_firebase_auth),
    db: Session = Depends(get_db)
) -> User:
    """
    Firebase 인증을 통해 현재 사용자 정보를 가져오는 의존성 함수
    
    Args:
        firebase_user: verify_firebase_auth에서 반환한 Firebase 사용자 정보
        db: DB 세션
    
    Returns:
        User: 현재 사용자 객체 (없으면 생성)
    
    Raises:
        NotFoundException: 사용자를 찾을 수 없고 생성도 실패한 경우
    """
    # Firebase UID로 사용자 조회
    user = db.query(User).filter(User.firebase_uid == firebase_user["uid"]).first()
    
    if not user:
        # 사용자가 없으면 새로 생성 (첫 로그인)
        user = User(
            firebase_uid=firebase_user["uid"],
            email=firebase_user["email"],
            username=firebase_user["email"].split("@")[0],  # 이메일에서 username 추출
            name=firebase_user.get("name")
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        # 사용자 정보 업데이트 (이메일, 이름 등)
        if user.email != firebase_user["email"]:
            user.email = firebase_user["email"]
        if firebase_user.get("name") and user.name != firebase_user["name"]:
            user.name = firebase_user["name"]
        db.commit()
        db.refresh(user)
    
    return user
```

### 2.6 Config 수정

`app/core/config.py`에 Firebase 설정 추가:

```python
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # 데이터베이스 설정
    DATABASE_URL: str = "sqlite:///./closet.db"
    
    # Firebase 설정
    FIREBASE_SERVICE_ACCOUNT_PATH: Optional[str] = None
    
    # 프로젝트 설정
    PROJECT_NAME: str = "ClosetMate API"
    API_V1_PREFIX: str = ""
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
```

### 2.7 Main.py에서 Firebase 초기화

`app/main.py` 수정:

```python
from fastapi import FastAPI
from .core.config import settings
from .core.firebase import initialize_firebase  # 추가
# ... 기타 imports ...

app = FastAPI(
    title=settings.PROJECT_NAME,
    # ...
)

@app.on_event("startup")
async def on_startup():
    # Firebase 초기화
    try:
        initialize_firebase()
    except Exception as e:
        print(f"Firebase 초기화 실패: {e}")
    # ... 기타 초기화 코드 ...
```

### 2.8 Auth Router 수정 (선택사항)

Firebase를 사용하면 서버에서 로그인 엔드포인트가 필요 없지만, 사용자 정보 확인용 엔드포인트를 추가할 수 있습니다:

`app/routers/auth_router.py`:

```python
from fastapi import APIRouter, Depends
from ..schemas.user_schema import UserResponse
from ..utils.dependencies import get_current_user
from ..models.user import User

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.get("/me", response_model=UserResponse)
def get_current_user_info(current_user: User = Depends(get_current_user)):
    """
    현재 로그인한 사용자 정보 조회
    """
    return current_user
```

## 3. Flutter 클라이언트 구현

### 3.1 필요한 패키지 추가

`pubspec.yaml`에 추가:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  # HTTP 요청용
  http: ^1.1.0
  # 또는 dio 사용
  dio: ^5.3.0
```

### 3.2 Firebase 초기화

`lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // flutterfire CLI로 생성

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

Firebase 옵션 파일 생성:
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

### 3.3 인증 서비스 생성

`lib/services/auth_service.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자
  User? get currentUser => _auth.currentUser;

  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/비밀번호로 회원가입
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 이름 설정
      if (displayName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // 이메일/비밀번호로 로그인
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google 로그인 (google_sign_in 패키지 필요)
  // Future<UserCredential> signInWithGoogle() async { ... }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ID 토큰 가져오기 (서버 API 호출 시 사용)
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      print('토큰 가져오기 실패: $e');
      return null;
    }
  }

  // Firebase 예외 처리
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'user-not-found':
        return '사용자를 찾을 수 없습니다.';
      case 'wrong-password':
        return '비밀번호가 잘못되었습니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일입니다.';
      default:
        return '인증 오류: ${e.message}';
    }
  }
}
```

### 3.4 API 서비스 생성

`lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class ApiService {
  final String baseUrl;
  final AuthService _authService = AuthService();

  ApiService({required this.baseUrl});

  // 인증 헤더가 포함된 요청
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      String? idToken = await _authService.getIdToken();
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }
    }

    return headers;
  }

  // GET 요청
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  // POST 요청
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // PUT 요청
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // DELETE 요청
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }
}
```

### 3.5 사용 예시

`lib/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 로그인 성공 - 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력하세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

API 호출 예시:

```dart
import '../services/api_service.dart';

class ClosetService {
  final ApiService _api = ApiService(baseUrl: 'http://your-api-url.com');

  Future<List<dynamic>> getClosetItems() async {
    final response = await _api.get('/closet/items');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load closet items');
    }
  }
}
```

## 4. 환경 변수 설정

`.env` 파일:

```env
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

## 5. 데이터베이스 마이그레이션

기존 User 테이블에 Firebase 관련 컬럼을 추가해야 합니다:

```python
# 마이그레이션 스크립트 또는 직접 수정
# firebase_uid, email, name 컬럼 추가
```

## 6. 보안 고려사항

1. **서비스 계정 키 보안**: 
   - 절대 Git에 커밋하지 않음
   - `.gitignore`에 추가
   - 환경 변수나 시크릿 관리 서비스 사용

2. **토큰 만료 처리**:
   - Flutter에서 토큰 자동 갱신
   - 서버에서 만료된 토큰 처리

3. **HTTPS 사용**:
   - 프로덕션에서는 반드시 HTTPS 사용

## 7. 테스트

### 서버 테스트
```python
# Firebase ID 토큰으로 API 호출 테스트
headers = {"Authorization": "Bearer <firebase_id_token>"}
response = client.get("/closet/items", headers=headers)
```

### Flutter 테스트
- Firebase Emulator 사용 가능
- 실제 Firebase 프로젝트에서 테스트

## 요약

1. **서버**: Firebase Admin SDK로 ID 토큰 검증
2. **클라이언트**: Firebase Auth SDK로 인증 후 ID 토큰을 API 요청 헤더에 포함
3. **플로우**: 
   - 클라이언트: Firebase 로그인 → ID 토큰 획득
   - 클라이언트: API 요청 시 `Authorization: Bearer <id_token>` 헤더 포함
   - 서버: 토큰 검증 → 사용자 정보 추출 → DB에서 사용자 조회/생성



