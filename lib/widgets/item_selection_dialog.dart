import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/closet_service.dart';
import '../models/closet_item.dart';
import '../api/endpoints.dart';

/// 아이템 선택 Dialog
///
/// 특정 카테고리의 옷장 아이템 목록을 보여주고 선택할 수 있는 Dialog입니다.
class ItemSelectionDialog extends StatefulWidget {
  final String categoryTitle; // 화면에 표시될 한글 제목 (예: "신발")
  final String categoryCode; // API 요청용 영문 코드 (예: "shoes")

  const ItemSelectionDialog({
    super.key,
    required this.categoryTitle,
    required this.categoryCode,
  });

  @override
  State<ItemSelectionDialog> createState() => _ItemSelectionDialogState();
}

class _ItemSelectionDialogState extends State<ItemSelectionDialog> {
  final ClosetService _closetService = ClosetService();

  List<ClosetItem> _items = [];
  bool _isLoading = true;
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

  /// 확인 버튼 클릭
  void _handleConfirm() {
    // 선택된 아이템이 있으면 첫 번째(또는 마지막) 아이템 ID 반환
    // 없으면 null 반환 (Dialog만 닫기)
    if (_selectedItemIds.isNotEmpty) {
      // 마지막 선택된 아이템 반환 (또는 첫 번째: _selectedItemIds.first)
      Navigator.of(context).pop(_selectedItemIds.last);
    } else {
      // 선택된 아이템이 없으면 null 반환 (Dialog만 닫기)
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // Material Design 3 스타일
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // 화면 너비의 90%
        height: MediaQuery.of(context).size.height * 0.7, // 화면 높이의 70%
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // 상단: 헤더 (제목 + 닫기 버튼)
            _buildHeader(),
            // 중간: GridView (아이템 목록)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? _buildEmptyState()
                      : _buildItemGrid(),
            ),
            // 하단: 확인 버튼
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  /// 상단 헤더
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 카테고리 제목
          Text(
            widget.categoryTitle,
            style: const TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          // 닫기 버튼
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
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
          Icon(Icons.checkroom, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '등록된 아이템이 없습니다.',
            style: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 아이템 GridView
  Widget _buildItemGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        final imageUrl = item.imageUrl != null
            ? '${Endpoints.baseUrl}/${item.imageUrl}'
            : null;

        return GestureDetector(
          onTap: () => _toggleSelection(item.id),
          child: Stack(
            children: [
              // 아이템 이미지 카드
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.error),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          ),
                  ),
                ),
              ),
              // 체크박스 (우측 상단)
              Positioned(
                top: 4,
                right: 4,
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
            ],
          ),
        );
      },
    );
  }

  /// 하단 확인 버튼
  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleConfirm,
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
            '확인',
            style: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

