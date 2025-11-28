import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

/// 코디 명 입력 다이얼로그
///
/// 즐겨찾는 코디로 저장하거나 수정할 때 코디 이름을 입력받는 다이얼로그입니다.
/// 
/// [initialName]: 초기 코디명 (null이면 저장 모드, 있으면 수정 모드)
/// [favoriteId]: 즐겨찾기 ID (수정 모드일 때만 필요)
class FavoriteNameDialog extends StatefulWidget {
  final String? initialName;
  final int? favoriteId;

  const FavoriteNameDialog({
    super.key,
    this.initialName,
    this.favoriteId,
  });

  @override
  State<FavoriteNameDialog> createState() => _FavoriteNameDialogState();
}

class _FavoriteNameDialogState extends State<FavoriteNameDialog> {
  late final TextEditingController _nameController;
  final FavoritesService _favoritesService = FavoritesService();
  bool _isLoading = false;
  
  // 저장 모드인지 수정 모드인지 확인
  bool get _isRenameMode => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    // 초기값이 있으면 설정, 없으면 빈 문자열
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 확인 버튼 클릭
  Future<void> _handleConfirm() async {
    final name = _nameController.text.trim();

    // 빈 문자열 체크
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코디 명을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isRenameMode) {
        // 수정 모드: 이름 변경
        if (widget.favoriteId == null) {
          throw Exception('수정 모드에서는 favoriteId가 필요합니다.');
        }
        await _favoritesService.renameFavorite(widget.favoriteId!, name);

        if (mounted) {
          // 다이얼로그 닫기
          Navigator.of(context).pop(true);
          
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('코디명이 "$name"으로 변경되었습니다.')),
          );
        }
      } else {
        // 저장 모드: 즐겨찾기 저장
        await _favoritesService.saveFavorite(name);

        if (mounted) {
          // 다이얼로그 닫기
          Navigator.of(context).pop(true);
          
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"$name" 코디가 즐겨찾기에 저장되었습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isRenameMode ? '이름 변경 실패: $e' : '저장 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, // 화면 너비의 85%
        constraints: const BoxConstraints(
          maxWidth: 400, // 최대 너비 제한 (태블릿 등 큰 화면 대응)
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 (저장 모드/수정 모드에 따라 변경)
            Text(
              _isRenameMode ? '코디 명 수정' : '코디 명',
              style: const TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // 입력 필드
            TextField(
              controller: _nameController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: '코디 1',
                hintStyle: TextStyle(
                  fontFamily: 'GmarketSans',
                  color: Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey[600]!,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 14,
              ),
              onSubmitted: (_) => _handleConfirm(),
            ),
            const SizedBox(height: 24),
            // 하단 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 취소 버튼
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontFamily: 'GmarketSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 확인 버튼
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800], // 어두운 회색 배경
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '확인',
                          style: TextStyle(
                            fontFamily: 'GmarketSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

