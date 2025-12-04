import '../models/closet_item.dart';
import '../models/outfit.dart';
import '../models/favorite.dart';
import '../utils/logger.dart';

/// 콘솔 출력 포맷팅
/// 
/// CLI에서 사용하는 다양한 화면 출력을 담당합니다.
class Views {
  /// 옷장 목록 표시
  /// 
  /// [category]: 카테고리 이름
  /// [items]: 아이템 리스트
  static void displayClosetItems(String category, List<ClosetItem> items) {
    Logger.blankLine();
    Logger.log('[$category 옷장]');

    if (items.isEmpty) {
      Logger.log('(아이템이 없습니다)');
    } else {
      for (final item in items) {
        final imageUrl = item.fullImageUrl;
        if (imageUrl != null) {
          Logger.log('- (id=${item.id}) $imageUrl');
        } else {
          Logger.log('- (id=${item.id}) (이미지 없음)');
        }
      }
    }
  }

  /// 옷장 아이템 선택 후 옵션 메뉴 표시
  static void displayItemOptions() {
    Logger.blankLine();
    Logger.log('- [1] 삭제');
    Logger.log('- [2] 코디에 추가');
    Logger.log('- [3] 뒤로가기');
  }

  /// 옷장 하단 옵션 메뉴 표시
  static void displayClosetOptions() {
    Logger.blankLine();
    Logger.log('[옵션]');
    Logger.log('1. 아이템 선택');
    Logger.log('2. 아이템 추가하기');
    Logger.log('3. 내 옷장 보기로 돌아가기');
    Logger.log('4. 메뉴로 돌아가기');
  }

  /// 오늘의 코디 표시
  /// 
  /// [outfit]: Outfit 객체
  static void displayTodayOutfit(Outfit outfit) {
    Logger.title('오늘의 코디 보기');
    Logger.log('top: ${_formatOutfitItem(outfit.top)}');
    Logger.log('bottom: ${_formatOutfitItem(outfit.bottom)}');
    Logger.log('shoes: ${_formatOutfitItem(outfit.shoes)}');
    Logger.log('outer: ${_formatOutfitItem(outfit.outer)}');
  }

  /// 오늘의 코디 옵션 메뉴 표시
  static void displayOutfitOptions() {
    Logger.blankLine();
    Logger.log('[옵션]');
    Logger.log('1. 아이템 직접 선택 / 변경');
    Logger.log('2. AI 추천');
    Logger.log('3. 즐겨찾는 코디로 저장');
    Logger.log('4. 메뉴로 돌아가기');
  }

  /// 카테고리별 아이템 선택 화면 (오늘의 코디용)
  /// 
  /// [category]: 카테고리 이름
  /// [items]: 아이템 리스트
  static void displayOutfitItemSelection(
      String category, List<ClosetItem> items) {
    Logger.blankLine();
    Logger.log('[$category 옷장]');

    if (items.isEmpty) {
      Logger.log('(아이템이 없습니다)');
    } else {
      for (final item in items) {
        final imageUrl = item.fullImageUrl;
        if (imageUrl != null) {
          Logger.log('- (id=${item.id}) $imageUrl');
        } else {
          Logger.log('- (id=${item.id}) (이미지 없음)');
        }
      }
      Logger.log('- (id=0) ❌ 비워놓기');
    }
  }

  /// 즐겨찾는 코디 목록 표시
  /// 
  /// [favorites]: FavoriteOutfit 리스트
  static void displayFavoritesList(List<FavoriteOutfit> favorites) {
    Logger.title('즐겨찾는 코디 목록');

    if (favorites.isEmpty) {
      Logger.log('(즐겨찾는 코디가 없습니다)');
    } else {
      for (final favorite in favorites) {
        Logger.log('- (id=${favorite.id}) ${favorite.name}');
      }
    }
  }

  /// 즐겨찾는 코디 상세 표시
  /// 
  /// [favorite]: FavoriteOutfit 객체
  static void displayFavoriteDetail(FavoriteOutfit favorite) {
    Logger.blankLine();
    Logger.log('[${favorite.name}]');
    Logger.log('- top: ${_formatOutfitItem(favorite.top)}');
    Logger.log('- bottom: ${_formatOutfitItem(favorite.bottom)}');
    Logger.log('- shoes: ${_formatOutfitItem(favorite.shoes)}');
    Logger.log('- outer: ${_formatOutfitItem(favorite.outer)}');
  }

  /// 즐겨찾는 코디 옵션 메뉴 표시
  static void displayFavoriteOptions() {
    Logger.blankLine();
    Logger.log('[옵션]');
    Logger.log('1. 이름 변경하기');
    Logger.log('2. 삭제하기');
    Logger.log('3. 뒤로가기');
  }

  /// 메인 메뉴 표시
  static void displayMainMenu() {
    Logger.blankLine();
    Logger.menuTitle('메뉴');
    Logger.log('1. 내 옷장 보기');
    Logger.log('2. 오늘의 코디');
    Logger.log('3. 즐겨찾는 코디');
    Logger.log('4. 종료');
    Logger.separator();
  }

  /// 아이템을 포맷팅 (있으면 ID와 이미지 URL, 없으면 "(없음)")
  static String _formatOutfitItem(ClosetItem? item) {
    if (item == null) return '(없음)';
    final imageUrl = item.fullImageUrl;
    return imageUrl != null ? 'id=${item.id} ($imageUrl)' : 'id=${item.id} (이미지 없음)';
  }
}