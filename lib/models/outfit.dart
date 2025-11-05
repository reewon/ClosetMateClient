import 'closet_item.dart';

/// Outfit 모델 (TodayOutfit)
/// 
/// 오늘의 코디를 나타내는 모델입니다.
/// 각 카테고리별로 ClosetItem을 포함할 수 있습니다.
class Outfit {
  final ClosetItem? 상의;
  final ClosetItem? 하의;
  final ClosetItem? 신발;
  final ClosetItem? 아우터;

  Outfit({
    this.상의,
    this.하의,
    this.신발,
    this.아우터,
  });

  /// JSON에서 Outfit 객체 생성
  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
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

  /// Outfit 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      '상의': 상의?.toJson(),
      '하의': 하의?.toJson(),
      '신발': 신발?.toJson(),
      '아우터': 아우터?.toJson(),
    };
  }

  /// 코디가 완성되었는지 확인 (모든 카테고리가 선택되었는지)
  bool get isComplete {
    return 상의 != null && 하의 != null && 신발 != null && 아우터 != null;
  }

  /// 특정 카테고리의 아이템 반환
  ClosetItem? getItemByCategory(String category) {
    switch (category) {
      case '상의':
        return 상의;
      case '하의':
        return 하의;
      case '신발':
        return 신발;
      case '아우터':
        return 아우터;
      default:
        return null;
    }
  }
}
