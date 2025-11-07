import '../services/closet_service.dart';
import '../services/outfit_service.dart';
import '../services/favorites_service.dart';
import '../models/closet_item.dart';
import '../api/api_client.dart';
import '../utils/logger.dart';
import 'views.dart';
import 'prompt.dart';

/// CLI 메뉴 시스템
/// 
/// 메인 메뉴, 옷장, 오늘의 코디, 즐겨찾기 등 모든 메뉴를 관리합니다.
class Menu {
  final ClosetService _closetService;
  final OutfitService _outfitService;
  final FavoritesService _favoritesService;

  Menu()
      : _closetService = ClosetService(),
        _outfitService = OutfitService(),
        _favoritesService = FavoritesService();

  /// 메인 메뉴 시작
  Future<void> start() async {
    while (true) {
      Views.displayMainMenu();
      final choice = Prompt.select('번호를 입력하세요');

      switch (choice) {
        case '1':
          await _myClosetMenu();
          break;
        case '2':
          await _todayOutfitMenu();
          break;
        case '3':
          await _favoritesMenu();
          break;
        case '4':
          Logger.blankLine();
          Logger.log('> 프로그램을 종료합니다.');
          return;
        default:
          Logger.error('올바른 번호를 선택해주세요. (1~4)');
      }
    }
  }

  /// 1. 내 옷장 보기 메뉴
  Future<void> _myClosetMenu() async {
    while (true) {
      Logger.title('내 옷장 보기');
      final category = Prompt.selectCategory();

      if (category == null) {
        continue; // 잘못된 입력
      }

      if (category == 'B') {
        return; // 뒤로가기
      }

      // 카테고리 선택 완료 → 옷장 아이템 화면
      final shouldReturnToMain = await _closetItemsMenu(category);
      if (shouldReturnToMain) {
        return; // 메인 메뉴로 돌아가기
      }
    }
  }

  /// 옷장 아이템 화면 (특정 카테고리)
  /// 
  /// 반환: true면 메인 메뉴로 돌아가기, false면 내 옷장 보기로 돌아가기
  Future<bool> _closetItemsMenu(String category) async {
    while (true) {
      try {
        // 아이템 목록 조회
        final items = await _closetService.getItemsByCategory(category);
        Views.displayClosetItems(category, items);
        Views.displayClosetOptions();

        final choice = Prompt.selectMenu(1, 4);
        if (choice == null) continue;

        switch (choice) {
          case 1: // 아이템 선택
            await _selectClosetItem(category, items);
            break;
          case 2: // 아이템 추가하기
            await _addClosetItem(category);
            break;
          case 3: // 내 옷장 보기로 돌아가기
            return false;
          case 4: // 메뉴로 돌아가기
            Logger.blankLine();
            Logger.log('→ 메인 메뉴로 돌아갑니다...');
            return true;
        }
      } catch (e) {
        _handleError(e);
        // 에러 발생 시 상위 메뉴로 돌아가기 (무한 루프 방지)
        return false;
      }
    }
  }

  /// 옷장 아이템 선택
  Future<void> _selectClosetItem(
      String category, List<ClosetItem> items) async {
    if (items.isEmpty) {
      Logger.warning('아이템이 없습니다.');
      return;
    }

    final itemId = Prompt.selectItemId();
    if (itemId == null) return; // 잘못된 입력
    if (itemId == -1) return; // 뒤로가기

    // 선택한 아이템이 목록에 있는지 확인
    final selectedItem = items.where((item) => item.id == itemId).firstOrNull;
    if (selectedItem == null) {
      Logger.error('존재하지 않는 아이템 ID입니다.');
      return;
    }

    // 아이템 옵션 메뉴
    Views.displayItemOptions();
    final choice = Prompt.selectMenu(1, 3);
    if (choice == null) return;

    try {
      switch (choice) {
        case 1: // 삭제
          if (Prompt.confirm('"${selectedItem.name}"를 삭제하시겠습니까?')) {
            await _closetService.deleteItem(itemId);
            Logger.success('"${selectedItem.name}"가 옷장에서 삭제되었습니다!');
          }
          break;
        case 2: // 코디에 추가
          await _outfitService.updateOutfitItem(category, itemId);
          Logger.success('"${selectedItem.name}"가 오늘의 코디에 추가되었습니다!');
          break;
        case 3: // 뒤로가기
          return;
      }
    } catch (e) {
      _handleError(e);
    }
  }

  /// 옷장 아이템 추가
  Future<void> _addClosetItem(String category) async {
    final name = Prompt.inputText('새 아이템 이름을 입력하세요');
    if (name == null) return; // 뒤로가기 또는 빈 입력

    try {
      await _closetService.addItem(category, name);
      Logger.success('"$name"가 $category 옷장에 추가되었습니다!');
    } catch (e) {
      _handleError(e);
    }
  }

  /// 2. 오늘의 코디 메뉴
  Future<void> _todayOutfitMenu() async {
    while (true) {
      try {
        // 오늘의 코디 조회
        final outfit = await _outfitService.getTodayOutfit();
        Views.displayTodayOutfit(outfit);
        Views.displayOutfitOptions();

        final choice = Prompt.selectMenu(1, 4);
        if (choice == null) continue;

        switch (choice) {
          case 1: // 아이템 직접 선택 / 변경
            await _selectOutfitItem();
            break;
          case 2: // AI 추천
            await _aiRecommend();
            break;
          case 3: // 즐겨찾는 코디로 저장
            await _saveFavorite();
            break;
          case 4: // 메뉴로 돌아가기
            Logger.blankLine();
            Logger.log('→ 메인 메뉴로 돌아갑니다...');
            return;
        }
      } catch (e) {
        _handleError(e);
        // 에러 발생 시 메인 메뉴로 돌아가기 (무한 루프 방지)
        return;
      }
    }
  }

  /// 오늘의 코디 - 아이템 직접 선택/변경
  Future<void> _selectOutfitItem() async {
    Logger.blankLine();
    final category = Prompt.selectCategory();
    if (category == null) return; // 잘못된 입력
    if (category == 'B') return; // 뒤로가기

    try {
      // 해당 카테고리의 옷장 아이템 조회
      final items = await _closetService.getItemsByCategory(category);
      Views.displayOutfitItemSelection(category, items);

      final itemId = Prompt.selectItemId();
      if (itemId == null) return; // 잘못된 입력
      if (itemId == -1) return; // 뒤로가기

      // id=0이면 비워놓기
      if (itemId == 0) {
        await _outfitService.clearCategory(category);
        Logger.success('${category}가 비워졌습니다!');
        return;
      }

      // 선택한 아이템이 목록에 있는지 확인
      final selectedItem = items.where((item) => item.id == itemId).firstOrNull;
      if (selectedItem == null) {
        Logger.error('존재하지 않는 아이템 ID입니다.');
        return;
      }

      // 코디에 아이템 설정
      await _outfitService.updateOutfitItem(category, itemId);
      Logger.success('${category}가 "${selectedItem.name}"로 설정되었습니다!');
    } catch (e) {
      _handleError(e);
    }
  }

  /// 오늘의 코디 - AI 추천
  Future<void> _aiRecommend() async {
    try {
      Logger.ai('AI가 아이템을 추천합니다...');
      await _outfitService.recommendOutfit();
      Logger.success('AI 추천이 반영되었습니다!');
    } catch (e) {
      _handleError(e);
    }
  }

  /// 오늘의 코디 - 즐겨찾기로 저장
  Future<void> _saveFavorite() async {
    try {
      // 코디 완성 여부 확인
      final outfit = await _outfitService.getTodayOutfit();
      if (!outfit.isComplete) {
        Logger.warning('코디를 완성해주세요!');
        Logger.log('(top, bottom, shoes, outer가 모두 선택되어야 합니다)');
        return;
      }

      // 코디가 완성되었으면 이름 입력 받기
      final name = Prompt.inputText('코디 이름을 입력하세요');
      if (name == null) return; // 뒤로가기 또는 빈 입력

      await _favoritesService.saveFavorite(name);
      Logger.success('"$name" 코디가 즐겨찾기에 저장되었습니다!');
    } catch (e) {
      _handleError(e);
    }
  }

  /// 3. 즐겨찾는 코디 메뉴
  Future<void> _favoritesMenu() async {
    while (true) {
      try {
        // 즐겨찾기 목록 조회
        final favorites = await _favoritesService.getFavoritesList();
        Views.displayFavoritesList(favorites);

        if (favorites.isEmpty) {
          Logger.blankLine();
          Logger.log('→ 메인 메뉴로 돌아갑니다...');
          return;
        }

        final itemId = Prompt.selectItemId();
        if (itemId == null) continue; // 잘못된 입력
        if (itemId == -1) return; // 뒤로가기

        // 선택한 코디가 목록에 있는지 확인
        final selected =
            favorites.where((fav) => fav.id == itemId).firstOrNull;
        if (selected == null) {
          Logger.error('존재하지 않는 코디 ID입니다.');
          continue;
        }

        // 코디 상세 화면
        await _favoriteDetailMenu(itemId);
      } catch (e) {
        _handleError(e);
        // 에러 발생 시 메인 메뉴로 돌아가기 (무한 루프 방지)
        return;
      }
    }
  }

  /// 즐겨찾는 코디 상세 화면
  Future<void> _favoriteDetailMenu(int id) async {
    while (true) {
      try {
        // 코디 상세 조회
        final favorite = await _favoritesService.getFavoriteById(id);
        Views.displayFavoriteDetail(favorite);
        Views.displayFavoriteOptions();

        final choice = Prompt.selectMenu(1, 3);
        if (choice == null) continue;

        switch (choice) {
          case 1: // 이름 변경하기
            final newName = Prompt.inputText('새로운 코디 이름을 입력하세요');
            if (newName == null) break; // 뒤로가기

            await _favoritesService.renameFavorite(id, newName);
            Logger.success(
                '"${favorite.name}"의 이름이 "$newName"으로 변경되었습니다!');
            return; // 목록으로 돌아가기

          case 2: // 삭제하기
            if (Prompt.confirm('"${favorite.name}" 코디를 삭제하시겠습니까?')) {
              await _favoritesService.deleteFavorite(id);
              Logger.success('"${favorite.name}" 코디가 삭제되었습니다!');
              return; // 목록으로 돌아가기
            }
            break;

          case 3: // 뒤로가기
            return;
        }
      } catch (e) {
        _handleError(e);
        return; // 에러 발생 시 목록으로 돌아가기
      }
    }
  }

  /// 에러 처리
  void _handleError(dynamic error) {
    if (error is ApiException) {
      Logger.error(error.message);
    } else {
      Logger.error('오류가 발생했습니다: $error');
    }
  }
}
