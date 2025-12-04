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

  /// Outfit 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'top': top?.toJson(),
      'bottom': bottom?.toJson(),
      'shoes': shoes?.toJson(),
      'outer': outer?.toJson(),
    };
  }

  /// 코디가 완성되었는지 확인 (모든 카테고리가 선택되었는지)
  bool get isComplete {
    return top != null && bottom != null && shoes != null && outer != null;
  }

  /// 즐겨찾기 저장을 위한 코디 완성 여부 확인 (outer 제외)
  /// top, bottom, shoes만 선택되어 있으면 저장 가능
  bool get isCompleteForFavorite {
    return top != null && bottom != null && shoes != null;
  }

  /// 특정 카테고리의 아이템 반환
  ClosetItem? getItemByCategory(String category) {
    switch (category) {
      case 'top':
        return top;
      case 'bottom':
        return bottom;
      case 'shoes':
        return shoes;
      case 'outer':
        return outer;
      default:
        return null;
    }
  }
}