import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/speech_provider.dart';
import '../providers/library_provider.dart';
import '../providers/settings_provider.dart';
import '../models/playlist_item.dart';
import '../services/tts_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isParsing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ── 文件导入 ──────────────────────────────────────
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
    );
    if (result != null && result.files.single.path != null) {
      final bytes = result.files.single.bytes;
      if (bytes != null) {
        setState(() => _textController.text = String.fromCharCodes(bytes));
      }
    }
  }

  // ── 开始朗读 ──────────────────────────────────────
  Future<void> _handleStart() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final settings = context.read<SettingsProvider>();
    if (!settings.isCurrentEngineConfigured) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先在设置页面配置 API Key')),
        );
      }
      return;
    }

    final isLink = text.startsWith('http://') || text.startsWith('https://');

    if (isLink) {
      setState(() => _isParsing = true);
      final service = TtsApiService(baseUrl: settings.backendUrl);
      final parsed = await service.parseLink(text);
      if (!mounted) return;
      setState(() => _isParsing = false);

      final title = parsed?['title'] ?? '链接内容';
      final content = parsed?['content'] ?? text;
      _startReading(title: title, content: content, type: PlaylistItemType.link);
    } else {
      final title = text.length > 20 ? '${text.substring(0, 20)}…' : text;
      _startReading(title: title, content: text, type: PlaylistItemType.clipboard);
    }

    _textController.clear();
  }

  void _startReading({
    required String title,
    required String content,
    required PlaylistItemType type,
  }) {
    final item = PlaylistItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      excerpt: content.length > 100 ? '${content.substring(0, 100)}…' : content,
      content: content,
      type: type,
      timestamp: '刚刚',
    );

    final speech = context.read<SpeechProvider>();
    final library = context.read<LibraryProvider>();
    speech.playItem(item, library);
    speech.restore();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 顶部标题栏 ──
                  _HomeHeader(onSearchTap: () {
                    // 通知 AppShell 打开搜索
                    final state = context.findAncestorStateOfType<State>();
                    if (state != null && state.runtimeType.toString() == '_AppShellState') {
                      (state as dynamic).openSearch();
                    }
                  }),

                  const SizedBox(height: 28),

                  // ── 诗意副标题 ──
                  _PoetryTitle()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 24),

                  // ── 输入区域 ──
                  _InputCanvas(
                    controller: _textController,
                    isParsing: _isParsing,
                    onPickFile: _pickFile,
                    onStart: _handleStart,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: 0.12, end: 0),

                  const SizedBox(height: 20),

                  // ── 快捷入口卡片 ──
                  _QuickActions()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 320.ms),
                ],
              ),
            ),
          ),

          // 底部 padding（给导航栏留空间）
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

// ── 顶部标题栏 ────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _HomeHeader({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Fluid Reader',
              style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: AppColors.onSurface, letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: onSearchTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: const Icon(Icons.search_rounded,
                color: AppColors.onSurfaceVariant, size: 18),
          ),
        ),
      ],
    );
  }
}

// ── 诗意副标题 ────────────────────────────────────────

class _PoetryTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACOUSTIC EXPERIENCE',
          style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w800,
            color: AppColors.primary.withOpacity(0.4),
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '听见文字的温度，\n让思想在耳畔流淌。',
          style: GoogleFonts.outfit(
            fontSize: 24, fontWeight: FontWeight.w300,
            color: AppColors.onSurface,
            height: 1.4, letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ── 输入画布 ──────────────────────────────────────────

class _InputCanvas extends StatelessWidget {
  final TextEditingController controller;
  final bool isParsing;
  final VoidCallback onPickFile;
  final VoidCallback onStart;

  const _InputCanvas({
    required this.controller,
    required this.isParsing,
    required this.onPickFile,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30, offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: '在这里输入、粘贴文字或文章链接…',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.outlineVariant,
                  ),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: GoogleFonts.inter(
                  fontSize: 15, height: 1.6, color: AppColors.onSurface,
                ),
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.outlineVariant.withOpacity(0.3)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                // 导入文件按钮
                TextButton.icon(
                  onPressed: onPickFile,
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('导入文件'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                    textStyle: GoogleFonts.outfit(
                      fontSize: 11, fontWeight: FontWeight.w700,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
                const Spacer(),
                // 开始朗读按钮
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, __) {
                    final enabled = value.text.trim().isNotEmpty && !isParsing;
                    return FilledButton.icon(
                      onPressed: enabled ? onStart : null,
                      icon: isParsing
                          ? const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow_rounded, size: 16),
                      label: Text(isParsing ? '解析中…' : '开始朗读'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        textStyle: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 快捷入口 ──────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCard(
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.primaryContainer.withOpacity(0.5),
            title: '多种音色',
            subtitle: '个性化听感',
            onTap: () {
              // 跳转到设置页
              final state = context.findAncestorStateOfType<State>();
              if (state != null) {
                try {
                  (state as dynamic).navigateTo(2);
                } catch (_) {}
              }
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _QuickCard(
            icon: Icons.history_rounded,
            iconColor: AppColors.secondary,
            iconBg: AppColors.secondaryContainer.withOpacity(0.5),
            title: '浏览历史',
            subtitle: '回顾过往',
            onTap: () {
              // 跳转到媒体库历史
              final state = context.findAncestorStateOfType<State>();
              if (state != null) {
                try {
                  (state as dynamic).navigateTo(1);
                } catch (_) {}
              }
            },
          ),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10, color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
