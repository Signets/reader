import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/playlist_item.dart';
import '../providers/library_provider.dart';

class SearchModal extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<PlaylistItem> onSelectItem;

  const SearchModal({
    super.key,
    required this.onClose,
    required this.onSelectItem,
  });

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final TextEditingController _controller = TextEditingController();
  List<PlaylistItem> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final library = context.read<LibraryProvider>();
    final items = library.history.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase()) || 
             item.content.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() => _results = items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 搜索框区域
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: _performSearch,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                      onPressed: widget.onClose,
                    ),
                    hintText: '搜索标题或内容...',
                    hintStyle: GoogleFonts.inter(color: AppColors.outline),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: GoogleFonts.inter(color: AppColors.onSurface),
                ),
              ),
              const SizedBox(height: 16),
              // 搜索结果区域
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _results.isEmpty 
                      ? Center(
                          child: Text(
                            _controller.text.isEmpty ? '输入关键词开始搜索' : '没有找到相关内容',
                            style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: _results.length,
                          separatorBuilder: (context, index) => Divider(
                            color: AppColors.outlineVariant.withOpacity(0.3),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.article_rounded, color: AppColors.primary, size: 20),
                              ),
                              title: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                item.excerpt,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              onTap: () => widget.onSelectItem(item),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
