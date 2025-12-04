import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/favorites_service.dart';
import '../models/favorite.dart';
import '../models/closet_item.dart';
import '../api/endpoints.dart';
import '../widgets/favorite_name_dialog.dart';
import '../widgets/favorite_detail_dialog.dart';

/// 즐겨찾는 코디 메인 화면
///
/// 저장된 즐겨찾는 코디 목록을 카드 형식으로 보여줍니다.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();

  List<FavoriteOutfit> _favorites = [];
  bool _isLoading = true;
  
  // 편집 모드 관련 상태
  bool _isEditMode = false;
  Set<int> _selectedFavoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// 즐겨찾기 목록 로드
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      // 목록 조회
      final favoritesList = await _favoritesService.getFavoritesList();
      
      // 각 코디별 상세 정보 조회 (이미지 표시용)
      final List<FavoriteOutfit> favoritesWithDetails = [];
      for (final favorite in favoritesList) {
        try {
          final detail = await _favoritesService.getFavoriteById(favorite.id);
          favoritesWithDetails.add(detail);
        } catch (e) {
          // 상세 조회 실패 시 목록 정보만 사용
          favoritesWithDetails.add(favorite);
        }
      }

      if (mounted) {
        setState(() {
          _favorites = favoritesWithDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('즐겨찾기를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '즐겨찾는 코디',
          style: TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          // 편집 모드일 때만 삭제 버튼과 취소 버튼 표시
          if (_isEditMode) ...[
            if (_selectedFavoriteIds.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteSelectedFavorites,
                tooltip: '삭제',
              ),
            TextButton(
              onPressed: _toggleEditMode,
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: _favorites.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height - 200,
                            child: _buildEmptyState(),
                          ),
                        )
                      : _buildFavoritesList(),
                ),
        ],
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '저장된 즐겨찾기가 없습니다',
            style: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘의 코디에서 마음에 드는 코디를 저장해보세요',
            style: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  /// 즐겨찾기 목록
  Widget _buildFavoritesList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 크기에 맞춰 동적으로 비율 계산
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final padding = 16.0;
        final mainSpacing = 24.0; // 세로 간격
        final crossSpacing = 20.0; // 가로 간격
        final heightReduction = 30.0; // 카드 높이 줄이기 위한 여백 (하단 탭 바와의 거리 조정)

        // 사용 가능한 너비와 높이 계산
        final availableWidth = screenWidth - (padding * 2);
        final availableHeight = screenHeight - (padding * 2) - heightReduction;

        // 카드 너비 (2열이므로)
        final cardWidth = (availableWidth - crossSpacing) / 2;
        // 카드 높이 (2행이므로, 간격 고려)
        final cardHeight = (availableHeight - mainSpacing) / 2;

        // 비율 계산
        final aspectRatio = cardWidth / cardHeight;

        return Padding(
          padding: const EdgeInsets.only(
            top: 24.0, // 상단 여백
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2열
              mainAxisSpacing: mainSpacing,
              crossAxisSpacing: crossSpacing,
              childAspectRatio: aspectRatio,
            ),
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final favorite = _favorites[index];
              return _buildFavoriteCard(favorite);
            },
          ),
        );
      },
    );
  }

  /// 편집 모드 토글
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      _selectedFavoriteIds.clear(); // 선택 초기화
    });
  }

  /// 즐겨찾기 선택/해제
  void _toggleSelection(int favoriteId) {
    setState(() {
      if (_selectedFavoriteIds.contains(favoriteId)) {
        _selectedFavoriteIds.remove(favoriteId);
      } else {
        _selectedFavoriteIds.add(favoriteId);
      }
    });
  }

  /// 즐겨찾기 상세 다이얼로그 표시
  Future<void> _showFavoriteDetailDialog(FavoriteOutfit favorite) async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 상세 정보 조회
      final detail = await _favoritesService.getFavoriteById(favorite.id);
      
      if (!mounted) return;
      
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
      // 상세 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => FavoriteDetailDialog(favorite: detail),
      );
    } catch (e) {
      if (!mounted) return;
      
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상세 정보를 불러오는데 실패했습니다: $e')),
      );
    }
  }

  /// 선택된 즐겨찾기 삭제
  Future<void> _deleteSelectedFavorites() async {
    if (_selectedFavoriteIds.isEmpty) return;

    // 확인 다이얼로그
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text(
          _selectedFavoriteIds.length == 1
              ? '즐겨찾는 코디를 삭제하시겠습니까?'
              : '선택한 ${_selectedFavoriteIds.length}개의 즐겨찾는 코디를 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // 순차적으로 삭제
      for (final id in _selectedFavoriteIds) {
        await _favoritesService.deleteFavorite(id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedFavoriteIds.length == 1
                  ? '삭제되었습니다.'
                  : '${_selectedFavoriteIds.length}개의 코디가 삭제되었습니다.',
            ),
          ),
        );
        // 편집 모드 종료 및 새로고침
        _isEditMode = false;
        _selectedFavoriteIds.clear();
        await _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  /// 즐겨찾기 카드 위젯
  Widget _buildFavoriteCard(FavoriteOutfit favorite) {
    final isSelected = _selectedFavoriteIds.contains(favorite.id);

    return GestureDetector(
      onLongPress: () {
        // Long Press 시 편집 모드 진입
        if (!_isEditMode) {
          _toggleEditMode();
          _toggleSelection(favorite.id); // 첫 번째 선택
        }
      },
      onTap: () {
        // 편집 모드일 때는 탭으로 선택/해제
        if (_isEditMode) {
          _toggleSelection(favorite.id);
        } else {
          // 편집 모드가 아닐 때는 상세 다이얼로그 표시
          _showFavoriteDetailDialog(favorite);
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: _isEditMode && isSelected
              ? const BorderSide(color: Colors.blue, width: 2)
              : BorderSide.none,
        ),
        color: Colors.white,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 코디명 + 편집 아이콘
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        favorite.name,
                        style: const TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      // 편집 모드가 아닐 때만 편집 아이콘 표시
                      if (!_isEditMode)
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: 18,
                          ),
                          onPressed: () => _showRenameDialog(favorite),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 하단: 2x2 Grid 레이아웃 (아이템 이미지)
                  Expanded(
                    child: _buildItemGrid(
                      top: favorite.top,
                      bottom: favorite.bottom,
                      shoes: favorite.shoes,
                      outer: favorite.outer,
                    ),
                  ),
                ],
              ),
            ),
            // 편집 모드일 때 체크박스 (우측 상단)
            if (_isEditMode)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleSelection(favorite.id),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.blue : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 아이템 Grid (2x2)
  Widget _buildItemGrid({
    required ClosetItem? top,
    required ClosetItem? bottom,
    required ClosetItem? shoes,
    required ClosetItem? outer,
  }) {
    // 카테고리 순서: 상의, 하의, 신발, 아우터
    final items = [
      {'category': '상의', 'item': top},
      {'category': '하의', 'item': bottom},
      {'category': '신발', 'item': shoes},
      {'category': '아우터', 'item': outer},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final itemData = items[index];
        final item = itemData['item'] as ClosetItem?;
        final hasItem = item != null;

        if (hasItem && item.imageUrl != null) {
          // 아이템이 있는 경우: 실제 이미지 표시
          final imageUrl = '${Endpoints.baseUrl}/${item.imageUrl}';
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error_outline, color: Colors.grey, size: 24),
              ),
            ),
          );
        } else {
          // 아이템이 없는 경우: 회색 배경
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                itemData['category'] as String,
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  /// 코디명 수정 다이얼로그 표시
  Future<void> _showRenameDialog(FavoriteOutfit favorite) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => FavoriteNameDialog(
        initialName: favorite.name,
        favoriteId: favorite.id,
      ),
    );

    // 수정 성공 시 목록 새로고침
    if (result == true) {
      await _loadFavorites();
    }
  }
}