import 'closet_item.dart';

/// FavoriteOutfit 모델
/// 
/// 즐겨찾는 코디를 나타내는 모델입니다.
class FavoriteOutfit {
  final int id;
  final String name;
  final ClosetItem? 상의;
  final ClosetItem? 하의;
  final ClosetItem? 신발;
  final ClosetItem? 아우터;

  FavoriteOutfit({
    required this.id,
    required this.name,
    this.상의,
    this.하의,
    this.신발,
    this.아우터,
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
      상의: json['상의'] != null
          ? ClosetItem.fromJson(json['상의'] as Map<String, dynamic>)
          : null,
      하의: json['하의'] != null
          ? ClosetItem.fromJson(json['하의'] as Map<String, dynamic>)
          : null,
      신발: json['신발'] != null
          ? ClosetItem.fromJson(json['신발'] as Map<String, dynamic>)
          : null,
      아우터: json['아우터'] != null
          ? ClosetItem.fromJson(json['아우터'] as Map<String, dynamic>)
          : null,
    );
  }

  /// FavoriteOutfit 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      '상의': 상의?.toJson(),
      '하의': 하의?.toJson(),
      '신발': 신발?.toJson(),
      '아우터': 아우터?.toJson(),
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
