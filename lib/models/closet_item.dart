/// ClosetItem 모델
/// 
/// 옷장 아이템을 나타내는 모델입니다.
class ClosetItem {
  final int id;
  final String name;
  final String? imageUrl;

  ClosetItem({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  /// JSON에서 ClosetItem 객체 생성
  factory ClosetItem.fromJson(Map<String, dynamic> json) {
    return ClosetItem(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// ClosetItem 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  /// 옷 추가 요청 시 사용하는 JSON 생성
  /// (name만 필요)
  static Map<String, dynamic> createRequestJson(String name) {
    return {
      'name': name,
    };
  }
}
