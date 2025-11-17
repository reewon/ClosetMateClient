# 📱 클라이언트 구현 가이드 (Flutter/Dart)

> 이 가이드는 **Flutter/Dart** 기반 클라이언트 구현을 위한 가이드입니다.

## 📋 참고할 API 명세서 부분

### README.md 주요 섹션
1. Closet API 상세 응답 구조
   - `GET /api/v1/closet/{category}`: 응답 형식 (id, image_url)
   - `POST /api/v1/closet/{category}`: 이미지 업로드 요청 형식

2. Today Outfit API
   - `GET /api/v1/outfit/today`: image_url 반환
   - `POST /api/v1/outfit/recommend`: image_url 반환

3. Favorites API
   - `GET /api/v1/favorites/{id}`: image_url 반환

---

## 🔄 주요 변경사항

### 1. 옷 아이템 추가 (POST /api/v1/closet/{category})

#### 변경 전 (기존)
```javascript
// JSON으로 name 전송
POST /api/v1/closet/top
Content-Type: application/json
Body: { "name": "white t-shirt" }
```

#### 변경 후 (현재)
```
// multipart/form-data로 이미지 파일 업로드
POST /api/v1/closet/top
Content-Type: multipart/form-data
Body: FormData with 'image' field
```

#### 구현 예시
```dart
// Dart/Flutter 예시
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<Map<String, dynamic>> addClothingItem(
  String category,
  File imageFile,
  String token,
) async {
  final uri = Uri.parse('http://localhost:8000/api/v1/closet/$category');
  
  var request = http.MultipartRequest('POST', uri);
  
  // Authorization 헤더 추가
  request.headers['Authorization'] = 'Bearer $token';
  
  // 이미지 파일 추가
  request.files.add(
    await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'), // 또는 적절한 타입
    ),
  );
  
  final response = await request.send();
  final responseBody = await response.stream.bytesToString();
  
  if (response.statusCode == 200) {
    return jsonDecode(responseBody) as Map<String, dynamic>;
  } else {
    throw Exception('업로드 실패: ${response.statusCode}');
  }
}
```

---

### 2. 옷 아이템 조회 (GET /api/v1/closet/{category})

#### 변경 전 (기존)
```json
[
  {
    "id": 1,
    "name": "white t-shirt"
  }
]
```

#### 변경 후 (현재)
```json
[
  {
    "id": 1,
    "image_url": "uploads/user_1/item_1_abc123.jpg"
  }
]
```

#### 구현 예시
```dart
// Dart/Flutter 예시
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> getClothingItems(
  String category,
  String token,
) async {
  final uri = Uri.parse('http://localhost:8000/api/v1/closet/$category');
  
  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final List<dynamic> items = jsonDecode(response.body);
    
    // image_url을 전체 URL로 변환
    return items.map((item) {
      final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
      if (itemMap['image_url'] != null) {
        itemMap['imageUrl'] = 'http://localhost:8000/${itemMap['image_url']}';
      }
      return itemMap;
    }).toList();
  } else {
    throw Exception('조회 실패: ${response.statusCode}');
  }
}
```

---

### 3. 오늘의 코디 / 즐겨찾기 조회

#### 변경 전 (기존)
```json
{
  "top": {
    "id": 1,
    "feature": "상의_white_cotton_..."
  }
}
```

#### 변경 후 (현재)
```json
{
  "top": {
    "id": 1,
    "image_url": "uploads/user_1/item_1_abc123.jpg"
  }
}
```

---

## 🛠️ 클라이언트에서 수정/추가해야 할 것들

### 1. 이미지 업로드 기능 추가

#### 필요한 패키지
```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
  image_picker: ^1.0.4
  flutter_image_compress: ^2.0.0  # 선택사항: 이미지 압축
```

#### 필요한 컴포넌트/함수
- [ ] 이미지 파일 선택 UI (image_picker 사용)
- [ ] MultipartRequest를 사용한 이미지 업로드 함수
- [ ] 업로드 진행 상태 표시 (CircularProgressIndicator)
- [ ] 업로드 성공/실패 처리 (SnackBar 또는 Dialog)

#### 구현 포인트
```dart
// Flutter 예시
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AddClothingItemScreen extends StatefulWidget {
  final String category;
  final String token;
  
  const AddClothingItemScreen({
    Key? key,
    required this.category,
    required this.token,
  }) : super(key: key);

  @override
  State<AddClothingItemScreen> createState() => _AddClothingItemScreenState();
}

class _AddClothingItemScreenState extends State<AddClothingItemScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  // 이미지 선택
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,  // 선택사항: 이미지 크기 제한
        maxHeight: 1920,
        imageQuality: 85,  // 선택사항: 이미지 품질
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('이미지 선택 중 오류가 발생했습니다.');
    }
  }

  // 이미지 업로드
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      _showError('이미지를 선택해주세요.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final uri = Uri.parse('http://localhost:8000/api/v1/closet/${widget.category}');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      
      // 이미지 파일 추가
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ),
      );
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        _showSuccess('업로드 완료');
        // 성공 처리 (목록 새로고침 등)
        Navigator.pop(context, true);
      } else {
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['message'] ?? '업로드 실패');
      }
    } catch (e) {
      _showError('업로드 실패: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('옷 추가')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 이미지 미리보기
            if (_selectedImage != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('이미지를 선택해주세요')),
              ),
            
            SizedBox(height: 16),
            
            // 이미지 선택 버튼
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: Icon(Icons.image),
              label: Text('이미지 선택'),
            ),
            
            SizedBox(height: 16),
            
            // 업로드 버튼
            ElevatedButton(
              onPressed: _isUploading || _selectedImage == null
                  ? null
                  : _uploadImage,
              child: _isUploading
                  ? CircularProgressIndicator()
                  : Text('업로드'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 2. 이미지 표시 기능

#### 필요한 수정
- [ ] `image_url`을 서버 URL과 결합하여 표시
- [ ] 이미지 로딩 실패 처리 (placeholder)
- [ ] 이미지 최적화 (lazy loading, 크기 조정 등)

#### 구현 포인트
```dart
// 이미지 URL 변환 유틸리티
String? getImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return null;
  // 상대 경로를 전체 URL로 변환
  return 'http://localhost:8000/$imageUrl';
}

// Flutter 위젯 예시
class ClothingItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  
  const ClothingItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = getImageUrl(item['image_url']);
    
    return Card(
      child: Column(
        children: [
          // 이미지 표시
          if (imageUrl != null)
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // 이미지 로딩 실패 시 placeholder 표시
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: Center(child: Text('이미지 없음')),
            ),
          
          Padding(
            padding: EdgeInsets.all(8),
            child: Text('ID: ${item['id']}'),
          ),
        ],
      ),
    );
  }
}
```

---

### 3. API 호출 함수 수정

#### 수정해야 할 함수들
- [ ] `addClothingItem()`: JSON → FormData로 변경
- [ ] `getClothingItems()`: 응답에서 `name` → `image_url` 처리
- [ ] `getTodayOutfit()`: 응답에서 `feature` → `image_url` 처리
- [ ] `getFavoriteOutfit()`: 응답에서 `feature` → `image_url` 처리

#### 예시
```dart
// 기존
Future<List<Map<String, dynamic>>> getClothingItems(String category) async {
  final response = await http.get(
    Uri.parse('http://localhost:8000/api/v1/closet/$category'),
  );
  final items = jsonDecode(response.body) as List;
  return items.cast<Map<String, dynamic>>(); // { id, name }
}

// 수정 후
Future<List<Map<String, dynamic>>> getClothingItems(
  String category,
  String token,
) async {
  final response = await http.get(
    Uri.parse('http://localhost:8000/api/v1/closet/$category'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final items = jsonDecode(response.body) as List;
    // image_url을 전체 URL로 변환
    return items.map((item) {
      final itemMap = item as Map<String, dynamic>;
      if (itemMap['image_url'] != null) {
        itemMap['imageUrl'] = 'http://localhost:8000/${itemMap['image_url']}';
      }
      return itemMap;
    }).toList();
  } else {
    throw Exception('조회 실패: ${response.statusCode}');
  }
}
```

---

### 4. 에러 처리 개선

#### 추가해야 할 에러 케이스
- [ ] 이미지 파일이 아닌 경우 (400)
- [ ] Gemini API 오류 (400)
- [ ] API 사용량 한도 초과 (429)
- [ ] 이미지 업로드 실패

#### 구현 예시
```dart
void handleUploadError(BuildContext context, String errorMessage) {
  String message;
  
  if (errorMessage.contains('이미지 파일만')) {
    message = '이미지 파일만 업로드 가능합니다.';
  } else if (errorMessage.contains('API 사용량') || 
             errorMessage.contains('quota') ||
             errorMessage.contains('429')) {
    message = 'API 사용량 한도를 초과했습니다. 잠시 후 다시 시도해주세요.';
  } else if (errorMessage.contains('이미지 분석')) {
    message = '이미지 분석 중 오류가 발생했습니다. 다른 이미지를 시도해주세요.';
  } else {
    message = '업로드 실패: $errorMessage';
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}

// 사용 예시
try {
  await _uploadImage();
} catch (e) {
  handleUploadError(context, e.toString());
}
```

---

### 5. UI/UX 개선 사항

#### 추가하면 좋은 기능
- [ ] 이미지 미리보기 (업로드 전)
- [ ] 이미지 크기 제한 안내
- [ ] 업로드 진행률 표시
- [ ] 이미지 로딩 스켈레톤 UI
- [ ] 이미지 최적화 (압축, 리사이징)

#### 구현 예시
```dart
// 이미지 미리보기 (이미 위의 예시에 포함됨)
// _selectedImage를 File로 저장하고 Image.file()로 표시

// 이미지 압축 (선택사항)
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

Future<File?> compressImage(File imageFile) async {
  try {
    // 압축된 이미지 경로
    final targetPath = imageFile.path.replaceAll('.jpg', '_compressed.jpg');
    
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 85,  // 품질 (0-100)
      minWidth: 1920,  // 최대 너비
      minHeight: 1920,  // 최대 높이
    );
    
    return compressedFile;
  } catch (e) {
    print('이미지 압축 실패: $e');
    return imageFile; // 압축 실패 시 원본 반환
  }
}

// 사용 예시
Future<void> _uploadImage() async {
  if (_selectedImage == null) return;
  
  // 이미지 압축 (선택사항)
  final imageToUpload = await compressImage(_selectedImage!);
  
  // 압축된 이미지로 업로드
  // ... 업로드 로직
}
```

---

## 📝 체크리스트

### 필수 구현
- [ ] 이미지 파일 선택 UI
- [ ] FormData를 사용한 이미지 업로드
- [ ] `image_url`을 서버 URL과 결합하여 표시
- [ ] 옷 아이템 조회 시 이미지 표시
- [ ] 오늘의 코디 조회 시 이미지 표시
- [ ] 즐겨찾기 조회 시 이미지 표시
- [ ] 에러 처리 (이미지 파일 검증, API 오류 등)

### 선택 구현
- [ ] 이미지 미리보기
- [ ] 업로드 진행률 표시
- [ ] 이미지 로딩 스켈레톤
- [ ] 이미지 압축/최적화
- [ ] 이미지 크기 제한 안내

---

## 🔗 참고 링크

### API 명세서 위치
- **README.md**:
  - 라인 226-300: Closet API
  - 라인 329-477: Today Outfit API
  - 라인 482-542: Favorites API

### 주요 변경사항 요약
1. ✅ 옷 추가: JSON → multipart/form-data (이미지 파일)
2. ✅ 옷 조회: `name` → `image_url` 반환
3. ✅ 코디 조회: `feature` → `image_url` 반환
4. ✅ 이미지 URL: 상대 경로 → 전체 URL 변환 필요

---

## 💡 팁

### 서버 URL 관리
```dart
// config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api/v1';
  
  static String getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    return '$baseUrl/$imageUrl';
  }
  
  static Uri getApiUri(String endpoint) {
    return Uri.parse('$baseUrl$apiPrefix$endpoint');
  }
}

// 사용 예시
final imageUrl = ApiConfig.getImageUrl(item['image_url']);
final uri = ApiConfig.getApiUri('/closet/top');
```

### 필요한 패키지
```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
  image_picker: ^1.0.4
  flutter_image_compress: ^2.0.0  # 선택사항: 이미지 압축
  cached_network_image: ^3.3.0  # 선택사항: 이미지 캐싱
```

### 이미지 최적화
- 큰 이미지는 서버에서 리사이징하는 것이 좋지만, 클라이언트에서도 압축 가능
- `flutter_image_compress` 패키지 사용 권장
- `cached_network_image` 패키지로 이미지 캐싱 및 최적화 가능

### 에러 처리
- 네트워크 오류와 API 오류를 구분하여 처리
- `try-catch`로 예외 처리
- `SnackBar` 또는 `Dialog`로 사용자에게 명확한 에러 메시지 제공

