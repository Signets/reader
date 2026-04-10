import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/library_provider.dart';
import '../providers/speech_provider.dart';
import '../models/playlist_item.dart';
import '../widgets/library_item_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  bool _isSelectMode = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _cancelSelectMode() {
    setState(() {
      _isSelectMode = false;
      _selectedIds.clear();
    });
  }

  void _deleteSelected() {
    final library = context.read<LibraryProvider>();
    final ids = _selectedIds.toList();
    if (_tabController.index == 0) {
      library.deleteFromPlaylist(ids);
    } else {
      library.deleteFromHistory(ids);
    }
    _cancelSelectMode();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return SafeArea(
      child: Column(
        children: [
          // ── 顶部标题 ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Text(
                  '媒体库',
                  style: GoogleFonts.outfit(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: AppColors.primary, letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSelectMode = !_isSelectMode;
                      _selectedIds.clear();
                    });
                  },
                  child: Text(
                    _isSelectMode ? '取消' : '选择',
                    style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 标签页 ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              controller: _tabController,
              labelStyle: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w500,
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant.withOpacity(0.6),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.outlineVariant,
              tabs: const [
                Tab(text: '播放清单'),
                Tab(text: '历史记录'),
              ],
            ),
          ),

          // ── 列表内容 ────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ItemList(
                  items: library.playlist,
                  emptyText: '播放清单为空\n在首页添加内容开始朗读',
                  isSelectMode: _isSelectMode,
                  selectedIds: _selectedIds,
                  onToggleSelect: _toggleSelect,
                  onPlayItem: _playItem,
                ),
                _ItemList(
                  items: library.history,
                  emptyText: '暂无历史记录',
                  isSelectMode: _isSelectMode,
                  selectedIds: _selectedIds,
                  onToggleSelect: _toggleSelect,
                  onPlayItem: _playItem,
                ),
              ],
            ),
          ),

          // ── 多选操作栏 ──────────────────────────────
          AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            offset: _isSelectMode && _selectedIds.isNotEmpty
                ? Offset.zero
                : const Offset(0, 1),
            child: _SelectionBar(
              count: _selectedIds.length,
              onDelete: _deleteSelected,
              onCancel: _cancelSelectMode,
            ),
          ),

          const SizedBox(height: 90),
        ],
      ),
    );
  }

  void _playItem(PlaylistItem item) {
    final speech = context.read<SpeechProvider>();
    final library = context.read<LibraryProvider>();
    speech.playItem(item, library);
    speech.restore();
  }
}

// ── 列表组件 ──────────────────────────────────────────

class _ItemList extends StatelessWidget {
  final List<PlaylistItem> items;
  final String emptyText;
  final bool isSelectMode;
  final Set<String> selectedIds;
  final void Function(String id) onToggleSelect;
  final void Function(PlaylistItem item) onPlayItem;

  const _ItemList({
    required this.items,
    required this.emptyText,
    required this.isSelectMode,
    required this.selectedIds,
    required this.onToggleSelect,
    required this.onPlayItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_music_rounded,
                size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text(
              emptyText,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedIds.contains(item.id);

        return LibraryItemCard(
          item: item,
          isSelectMode: isSelectMode,
          isSelected: isSelected,
          onTap: () => isSelectMode ? onToggleSelect(item.id) : onPlayItem(item),
        )
            .animate(delay: Duration(milliseconds: index * 40))
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.05, end: 0);
      },
    );
  }
}

// ── 多选操作栏 ────────────────────────────────────────

class _SelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const _SelectionBar({
    required this.count,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, -4),
          ),
        ],
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text('取消 ($count)'),
            style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
          ),
          Container(
              width: 1, height: 28, color: AppColors.outlineVariant),
          TextButton.icon(
            onPressed: count > 0 ? onDelete : null,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('删除'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }
}
