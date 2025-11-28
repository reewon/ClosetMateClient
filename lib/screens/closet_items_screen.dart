import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../services/closet_service.dart';
import '../services/outfit_service.dart';
import '../models/closet_item.dart';
import '../api/endpoints.dart';

/// 카테고리별 아이템 목록 화면
class ClosetItemsScreen extends StatefulWidget {
  final String categoryTitle; // 화면에 표시될 한글 제목 (예: "상의")
  final String categoryCode;  // API 요청용 영문 코드 (예: "top")

  const ClosetItemsScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryCode,
  });

  @override
  State<ClosetItemsScreen> createState() => _ClosetItemsScreenState();
}

class _ClosetItemsScreenState extends State<ClosetItemsScreen> {
  final ClosetService _closetService = ClosetService();
  final OutfitService _outfitService = OutfitService();
  final ImagePicker _picker = ImagePicker();

  List<ClosetItem> _items = [];
  bool _isLoading = true;
  
  // 편집 모드 관련 상태
  bool _isEditMode = false;
  Set<int> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  /// 아이템 목록 로드
  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _closetService.getItemsByCategory(widget.categoryCode);
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('아이템을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  /// 이미지 추가 (업로드)
  Future<void> _addItem() async {
    try {
      // 갤러리에서 이미지 선택
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; // 취소함

      setState(() => _isLoading = true);

      // 서버에 업로드
      final message = await _closetService.addItem(
        widget.categoryCode,
        File(image.path),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        
        // 편집 모드 종료
        setState(() {
          _isEditMode = false;
          _selectedItemIds.clear();
        });
        
        // 목록 새로고침
        _loadItems();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e')),
        );
      }
    }
  }

  /// 편집 모드 토글
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      _selectedItemIds.clear(); // 선택 초기화
    });
  }

  /// 아이템 선택/해제
  void _toggleSelection(int itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  /// 선택된 아이템 삭제
  Future<void> _deleteSelectedItems() async {
    if (_selectedItemIds.isEmpty) return;

    // 확인 다이얼로그
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('아이템을 삭제하시겠습니까?'),
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
      // 순차적으로 삭제 (병렬 처리 시 서버 부하 고려)
      // 또는 서버 API가 일괄 삭제를 지원한다면 한번에 처리
      for (final id in _selectedItemIds) {
        await _closetService.deleteItem(id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다.')),
        );
        // 편집 모드 종료 및 새로고침
        _isEditMode = false;
        _selectedItemIds.clear();
        _loadItems();
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

  /// 선택된 아이템을 코디에 추가
  Future<void> _addToOutfit() async {
    if (_selectedItemIds.isEmpty) return;

    // 카테고리당 하나만 선택 가능 (마지막 선택된 것 사용)
    final lastSelectedId = _selectedItemIds.last;

    setState(() => _isLoading = true);

    try {
      final message = await _outfitService.updateOutfitItem(
        widget.categoryCode,
        lastSelectedId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        // 편집 모드 종료
        setState(() {
          _isEditMode = false;
          _selectedItemIds.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('코디 추가 실패: $e')),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          // 아이템 추가 버튼
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _addItem,
          ),
          // 편집 버튼
          IconButton(
            icon: const Icon(
              Icons.edit_square,
              color: Colors.black,
            ),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 메인 콘텐츠
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? _buildEmptyState()
                  : _buildGridView(),
          // 편집 모드일 때 하단에 떠있는 버튼들
          if (_isEditMode) _buildEditBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '등록된 아이템이 없습니다.',
            style: TextStyle(
              fontFamily: 'GmarketSans',
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: _isEditMode ? 100 : 16, // 편집 모드일 때 하단 패딩 추가
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3열
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.8, // 세로형 비율
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isSelected = _selectedItemIds.contains(item.id);
        final imageUrl = '${Endpoints.baseUrl}/${item.imageUrl}';

        return GestureDetector(
          onTap: () {
            if (_isEditMode) {
              _toggleSelection(item.id);
            } else {
              // 일반 모드일 때 탭 동작 (상세 보기 등 - 현재는 없음)
            }
          },
          child: Stack(
            children: [
              // 아이템 이미지 카드
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: _isEditMode && isSelected
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
              // 편집 모드일 때 체크박스
              if (_isEditMode)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.blue : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditBottomBar() {
    final hasSelection = _selectedItemIds.isNotEmpty;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 48, // 더 위로 이동
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 삭제 버튼
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: hasSelection ? _deleteSelectedItems : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '삭제',
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // 코디에 추가 버튼
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: ElevatedButton(
              onPressed: hasSelection ? _addToOutfit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '코디에 추가',
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

