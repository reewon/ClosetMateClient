import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/outfit_service.dart';
import '../models/outfit.dart';
import '../models/closet_item.dart';
import '../api/endpoints.dart';
import '../api/api_client.dart';
import '../widgets/item_selection_dialog.dart';
import '../widgets/favorite_name_dialog.dart';

/// 오늘의 코디 메인 화면
///
/// 상의, 하의, 신발, 아우터 4가지 카테고리를 Grid로 보여줍니다.
/// 각 카테고리별로 선택된 아이템을 표시합니다.
class TodayOutfitScreen extends StatefulWidget {
  const TodayOutfitScreen({super.key});

  @override
  State<TodayOutfitScreen> createState() => _TodayOutfitScreenState();
}

class _TodayOutfitScreenState extends State<TodayOutfitScreen> {
  final OutfitService _outfitService = OutfitService();

  Outfit? _outfit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOutfit();
  }

  /// 오늘의 코디 조회
  Future<void> _loadOutfit() async {
    setState(() => _isLoading = true);
    try {
      final outfit = await _outfitService.getTodayOutfit();
      if (mounted) {
        setState(() {
          _outfit = outfit;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('코디를 불러오는데 실패했습니다: $e')),
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
          '오늘의 코디',
          style: TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          // AI 추천 버튼
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 24.0),
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _handleAiRecommend(),
              icon: const Icon(
                IconData(
                  0xf06c, // Material Symbols smart_toy 아이콘 코드 포인트
                  fontFamily: 'MaterialSymbolsRounded',
                ),
                size: 18,
              ),
              label: const Text(
                'AI 추천',
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[100], // 연한 보라색 배경
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 2x2 Grid 레이아웃
                Expanded(
            child: LayoutBuilder(
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
                    top: 24.0, // 상단 여백 (AppBar와의 간격)
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: GridView.count(
                    crossAxisCount: 2, // 2열
                    mainAxisSpacing: mainSpacing,
                    crossAxisSpacing: crossSpacing,
                    childAspectRatio: aspectRatio,
                    children: [
                      _buildCategoryCard('상의', 'top'),
                      _buildCategoryCard('하의', 'bottom'),
                      _buildCategoryCard('신발', 'shoes'),
                      _buildCategoryCard('아우터', 'outer'),
                    ],
                  ),
                );
              },
            ),
          ),
          // 하단 "즐겨찾는 코디로 저장" 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _showFavoriteNameDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800], // 어두운 회색 배경
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '즐겨찾는 코디로 저장',
                  style: TextStyle(
                    fontFamily: 'GmarketSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 아이템 선택 Dialog 표시
  Future<void> _showItemSelectionDialog(String title, String categoryCode) async {
    final selectedItemId = await showDialog<int>(
      context: context,
      builder: (context) => ItemSelectionDialog(
        categoryTitle: title,
        categoryCode: categoryCode,
      ),
    );

    // Dialog에서 아이템이 선택되었으면 업데이트
    if (selectedItemId != null) {
      await _updateOutfitItem(categoryCode, selectedItemId);
    }
  }

  /// 코디 아이템 업데이트
  Future<void> _updateOutfitItem(String category, int itemId) async {
    try {
      setState(() => _isLoading = true);
      await _outfitService.updateOutfitItem(category, itemId);
      
      // 화면 새로고침
      await _loadOutfit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('코디가 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('코디 업데이트 실패: $e')),
        );
      }
    }
  }

  /// AI 추천 기능
  Future<void> _handleAiRecommend() async {
    try {
      setState(() => _isLoading = true);

      // AI 추천 실행
      await _outfitService.recommendOutfit();

      // 화면 새로고침
      await _loadOutfit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 추천이 완료되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // 에러 메시지 처리
        String errorMessage = 'AI 추천 실패: $e';
        
        // ApiException인 경우 서버 메시지 사용
        if (e is ApiException) {
          errorMessage = e.message;
          
          // 404 에러인 경우 (옷장에 아이템 없음)
          if (e.statusCode == 404) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '옷장에 아이템이 없습니다',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '먼저 옷장에 아이템을 추가해주세요',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
            return;
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  /// 코디 명 입력 다이얼로그 표시
  Future<void> _showFavoriteNameDialog() async {
    // 코디 완성 여부 확인 (outer는 선택 사항)
    if (_outfit == null || !_outfit!.isCompleteForFavorite) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '코디를 완성해주세요',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '상의, 하의, 신발이 모두 선택되어야 합니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const FavoriteNameDialog(),
    );

    // 저장 성공 시 화면 새로고침 (필요한 경우)
    if (result == true) {
      // 다이얼로그에서 이미 성공 메시지를 표시하므로 여기서는 추가 작업 없음
    }
  }

  /// 카테고리 카드 위젯
  Widget _buildCategoryCard(String title, String categoryCode) {
    final item = _outfit?.getItemByCategory(categoryCode);
    final hasItem = item != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () => _showItemSelectionDialog(title, categoryCode),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 제목
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              // 하단: 아이템 표시 영역
              Expanded(
                child: hasItem
                    ? _buildItemImage(item!)
                    : _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 아이템이 없을 때 (빈 상태) UI
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 48, // 큰 검은색 "+" 아이콘
        ),
      ),
    );
  }

  /// 아이템이 있을 때 이미지 표시
  Widget _buildItemImage(ClosetItem item) {
    final imageUrl = item.imageUrl != null
        ? '${Endpoints.baseUrl}/${item.imageUrl}'
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error_outline, color: Colors.grey),
              ),
            )
          : Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
    );
  }
}

