import 'closet_item.dart';

/// FavoriteOutfit 모델
/// 
/// 즐겨찾는 코디를 나타내는 모델입니다.
class FavoriteOutfit {
  final int id;
  final String name;
  final ClosetItem? top;
  final ClosetItem? bottom;
  final ClosetItem? shoes;
  final ClosetItem? outer;

  FavoriteOutfit({
    required this.id,
    required this.name,
    this.top,
    this.bottom,
    this.shoes,
    this.outer,
  });

  /// JSON에서 FavoriteOutfit 객체 생성 (목록 조회용 - id와 name만)
  factory FavoriteOutfit.fromListJson(Map<String, dynamic> json) {
    return FavoriteOutfit(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  /// JSON에서 FavoriteOutfit 객체 생성 (상세 조회용 - 모든 필드)
  factory FavoriteOutfit.fromDetailJson(Map<String, dynamic> json) {
    return FavoriteOutfit(
      id: json['id'] as int? ?? 0, // 상세 조회에는 id가 없을 수 있음
      name: json['name'] as String,
      top: json['top'] != null
          ? ClosetItem.fromJson(json['top'] as Map<String, dynamic>)
          : null,
      bottom: json['bottom'] != null
          ? ClosetItem.fromJson(json['bottom'] as Map<String, dynamic>)
          : null,
      shoes: json['shoes'] != null
          ? ClosetItem.fromJson(json['shoes'] as Map<String, dynamic>)
          : null,
      outer: json['outer'] != null
          ? ClosetItem.fromJson(json['outer'] as Map<String, dynamic>)
          : null,
    );
  }

  /// FavoriteOutfit 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'top': top?.toJson(),
      'bottom': bottom?.toJson(),
      'shoes': shoes?.toJson(),
      'outer': outer?.toJson(),
    };
  }

  /// 이름 변경 요청 시 사용하는 JSON 생성
  static Map<String, dynamic> createRenameRequestJson(String newName) {
    return {
      'new_name': newName,
    };
  }

  /// 즐겨찾기 저장 요청 시 사용하는 JSON 생성
  static Map<String, dynamic> createSaveRequestJson(String name) {
    return {
      'name': name,
    };
  }
}
