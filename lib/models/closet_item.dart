import '../utils/config.dart';

/// ClosetItem 모델
/// 
/// 옷장 아이템을 나타내는 모델입니다.
class ClosetItem {
  final int id;
  final String? imageUrl;

  ClosetItem({
    required this.id,
    this.imageUrl,
  });

  /// JSON에서 ClosetItem 객체 생성
  factory ClosetItem.fromJson(Map<String, dynamic> json) {
    return ClosetItem(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// ClosetItem 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  /// 이미지 전체 URL 반환 (Flutter GUI에서 사용)
  /// 
  /// 서버에서 받은 상대 경로를 전체 URL로 변환하여 반환합니다.
  /// imageUrl이 null이면 null을 반환합니다.
  String? get fullImageUrl => Config.getImageUrl(imageUrl);
}