import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../services/closet_service.dart';
import '../models/closet_item.dart';
import '../api/endpoints.dart';
import 'closet_items_screen.dart';

/// 옷장 메인 화면
///
/// 상의, 하의, 신발, 아우터 4가지 카테고리를 Grid로 보여줍니다.
/// 각 카테고리별로 최근 추가된 아이템 이미지를 미리 보여줍니다.
class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final ClosetService _closetService = ClosetService();
  final ImagePicker _picker = ImagePicker();
  
  // 각 카테고리별 아이템 목록 (미리보기용)
  Map<String, List<ClosetItem>> _previewItems = {
    'top': [],
    'bottom': [],
    'shoes': [],
    'outer': [],
  };
  
  // 로딩 상태
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreviewItems();
  }

  /// 모든 카테고리의 미리보기 아이템 로드
  Future<void> _loadPreviewItems() async {
    setState(() => _isLoading = true);
    
    try {
      // 4개 카테고리 동시 요청 (병렬 처리)
      final results = await Future.wait([
        _closetService.getItemsByCategory('top'),
        _closetService.getItemsByCategory('bottom'),
        _closetService.getItemsByCategory('shoes'),
        _closetService.getItemsByCategory('outer'),
      ]);

      if (mounted) {
        setState(() {
          _previewItems['top'] = results[0];
          _previewItems['bottom'] = results[1];
          _previewItems['shoes'] = results[2];
          _previewItems['outer'] = results[3];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')),
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
        title: Text(
          'MY CLOSET',
          style: GoogleFonts.aboreto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPreviewItems,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 화면 크기에 맞춰 동적으로 비율 계산
                  final screenHeight = constraints.maxHeight;
                  final screenWidth = constraints.maxWidth;
                  final padding = 16.0;
                  final mainSpacing = 24.0; // 세로 간격 증가
                  final crossSpacing = 20.0; // 가로 간격 증가
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
                      top: 24.0, // 상단 여백 증가 (MY CLOSET과의 간격)
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
    );
  }

  /// 카테고리 카드 위젯
  Widget _buildCategoryCard(String title, String categoryCode) {
    final items = _previewItems[categoryCode] ?? [];
    // 최신 4개만 표시 (역순으로 정렬된 상태라고 가정하거나, 앞에서부터 4개)
    // 보통 서버에서 최신순으로 준다고 가정. 만약 아니라면 sort 필요.
    // 여기서는 서버 응답 순서를 따름.
    final previewItems = items.take(4).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          // 카테고리 상세 화면으로 이동
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClosetItemsScreen(
                categoryTitle: title,
                categoryCode: categoryCode,
              ),
            ),
          );
          // 돌아오면 데이터 갱신 (추가/삭제 반영)
          _loadPreviewItems();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 제목 + 화살표
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'GmarketSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              // 하단: 아이템 미리보기
              Expanded(
                child: previewItems.isEmpty
                    ? _buildEmptyState(categoryCode)
                    : _buildPreviewGrid(previewItems),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 아이템이 없을 때 (빈 상태) UI
  Widget _buildEmptyState(String categoryCode) {
    return InkWell(
      onTap: () => _showImageSourceDialog(categoryCode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              '옷을 추가해보세요',
              style: TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 소스 선택 다이얼로그 (갤러리/카메라)
  Future<void> _showImageSourceDialog(String categoryCode) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await _addItemFromSource(categoryCode, source);
    }
  }

  /// 이미지 소스에서 아이템 추가
  Future<void> _addItemFromSource(String categoryCode, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return; // 취소함

      // 로딩 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지를 업로드하는 중...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // 서버에 업로드
      final message = await _closetService.addItem(
        categoryCode,
        File(image.path),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        // 목록 새로고침
        _loadPreviewItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e')),
        );
      }
    }
  }

  /// 아이템 미리보기 그리드 (2x2)
  Widget _buildPreviewGrid(List<ClosetItem> items) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // 스크롤 방지
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        // 이미지 URL 구성
        final imageUrl = '${Endpoints.baseUrl}/${item.imageUrl}';
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error_outline, size: 16, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}