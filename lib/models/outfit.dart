import 'closet_item.dart';

/// Outfit 모델 (TodayOutfit)
/// 
/// 오늘의 코디를 나타내는 모델입니다.
/// 각 카테고리별로 ClosetItem을 포함할 수 있습니다.
class Outfit {
  final ClosetItem? top;
  final ClosetItem? bottom;
  final ClosetItem? shoes;
  final ClosetItem? outer;

  Outfit({
    this.top,
    this.bottom,
    this.shoes,
    this.outer,
  });

  /// JSON에서 Outfit 객체 생성
  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      top: json['상의'] != null
          ? ClosetItem.fromJson(json['상의'] as Map<String, dynamic>)
          : null,
      bottom: json['하의'] != null
          ? ClosetItem.fromJson(json['하의'] as Map<String, dynamic>)
          : null,
      shoes: json['신발'] != null
          ? ClosetItem.fromJson(json['신발'] as Map<String, dynamic>)
          : null,
      outer: json['아우터'] != null
          ? ClosetItem.fromJson(json['아우터'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Outfit 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      '상의': top?.toJson(),
      '하의': bottom?.toJson(),
      '신발': shoes?.toJson(),
      '아우터': outer?.toJson(),
    };
  }

  /// 코디가 완성되었는지 확인 (모든 카테고리가 선택되었는지)
  bool get isComplete {
    return top != null && bottom != null && shoes != null && outer != null;
  }

  /// 특정 카테고리의 아이템 반환
  ClosetItem? getItemByCategory(String category) {
    switch (category) {
      case '상의':
        return top;
      case '하의':
        return bottom;
      case '신발':
        return shoes;
      case '아우터':
        return outer;
      default:
        return null;
    }
  }
}
