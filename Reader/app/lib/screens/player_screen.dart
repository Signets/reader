import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/speech_provider.dart';
import '../models/playlist_item.dart';

class PlayerScreen extends StatefulWidget {
  final PlaylistItem item;
  final VoidCallback onMinimize;
  final VoidCallback onNavigateToSettings;

  const PlayerScreen({
    super.key,
    required this.item,
    required this.onMinimize,
    required this.onNavigateToSettings,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _slideAnim = CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeOutCubic,
  );

  final ScrollController _scrollController = ScrollController();
  bool _showRateMenu = false;
  static const List<double> _rates = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speech = context.watch<SpeechProvider>();

    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (_, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(_slideAnim),
        child: child,
      ),
      child: Material(
        color: AppColors.surface,
        child: SafeArea(
          child: Column(
            children: [
              // ── 顶部栏 ────────────────────────────
              _PlayerTopBar(
                isPlaying: speech.isPlaying,
                onMinimize: widget.onMinimize,
              ),

              // ── 封面 + 标题 ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    // 封面图（占位色块）
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.6),
                            AppColors.secondary.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 10, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.article_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item.title,
                        style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w800,
                          color: AppColors.onSurface, letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 卡拉OK 歌词区域 ───────────────────
              Expanded(
                child: _KaraokeArea(
                  sentences: speech.sentences,
                  activeIndex: speech.activeSentenceIndex,
                  scrollController: _scrollController,
                ),
              ),

              // ── 控制面板 ──────────────────────────
              _ControlPanel(
                speech: speech,
                showRateMenu: _showRateMenu,
                rates: _rates,
                onToggleRateMenu: () =>
                    setState(() => _showRateMenu = !_showRateMenu),
                onSelectRate: (r) {
                  setState(() => _showRateMenu = false);
                  // TODO: 语速调节需重新合成
                },
                onNavigateToSettings: widget.onNavigateToSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 顶部操作栏 ────────────────────────────────────────

class _PlayerTopBar extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onMinimize;

  const _PlayerTopBar({required this.isPlaying, required this.onMinimize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onMinimize,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            color: AppColors.onSurface,
          ),
          Expanded(
            child: Text(
              isPlaying ? '正在播放' : '播放已暂停',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 22),
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ── 卡拉OK 歌词区域 ───────────────────────────────────

class _KaraokeArea extends StatelessWidget {
  final List<String> sentences;
  final int activeIndex;
  final ScrollController scrollController;

  const _KaraokeArea({
    required this.sentences,
    required this.activeIndex,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (sentences.isEmpty) {
      return Center(
        child: Text(
          '正在准备朗读…',
          style: GoogleFonts.outfit(
            fontSize: 18, color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      itemCount: sentences.length,
      itemBuilder: (context, index) {
        final isActive = index == activeIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: isActive
                ? GoogleFonts.outfit(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: AppColors.karaokeActive,
                    height: 1.5,
                  )
                : GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: AppColors.karaokePending,
                    height: 1.5,
                  ),
            child: Text('${sentences[index]}。'),
          ),
        );
      },
    );
  }
}

// ── 控制面板 ──────────────────────────────────────────

class _ControlPanel extends StatelessWidget {
  final SpeechProvider speech;
  final bool showRateMenu;
  final List<double> rates;
  final VoidCallback onToggleRateMenu;
  final void Function(double rate) onSelectRate;
  final VoidCallback onNavigateToSettings;

  const _ControlPanel({
    required this.speech,
    required this.showRateMenu,
    required this.rates,
    required this.onToggleRateMenu,
    required this.onSelectRate,
    required this.onNavigateToSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30, offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Column(
        children: [
          // ── 进度条 ────────────────────────────────
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: speech.progress,
                  backgroundColor: AppColors.outlineVariant,
                  color: AppColors.primary,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(speech.currentPositionStr,
                      style: GoogleFonts.outfit(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.outline)),
                  Text(speech.totalDurationStr,
                      style: GoogleFonts.outfit(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.outline)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── 播放控制 ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 快退 15s
              _ControlButton(
                icon: Icons.replay_10_rounded,
                label: '快退',
                onTap: () => speech.seekBackward(const Duration(seconds: 15)),
              ),

              // 播放/暂停主按钮
              _PlayPauseButton(
                isPlaying: speech.isPlaying,
                isLoading: speech.isLoading,
                onTap: () {
                  if (speech.isPlaying) {
                    speech.pause();
                  } else {
                    speech.resume();
                  }
                },
              ),

              // 快进 15s
              _ControlButton(
                icon: Icons.forward_10_rounded,
                label: '快进',
                onTap: () => speech.seekForward(const Duration(seconds: 15)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── 辅助控制 ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 语速
              _RateButton(
                showMenu: showRateMenu,
                rates: rates,
                onToggle: onToggleRateMenu,
                onSelect: onSelectRate,
              ),
              // 语音库
              _AuxButton(
                icon: Icons.record_voice_over_rounded,
                label: '语音库',
                onTap: onNavigateToSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon, required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.onSurfaceVariant.withOpacity(0.7)),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 8, fontWeight: FontWeight.w700,
                  color: AppColors.outline)),
        ],
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying, required this.isLoading, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white,
                  ),
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white, size: 36,
              ),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final bool showMenu;
  final List<double> rates;
  final VoidCallback onToggle;
  final void Function(double) onSelect;

  const _RateButton({
    required this.showMenu,
    required this.rates,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('1x',
                    style: GoogleFonts.outfit(
                        fontSize: 13, fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ),
              const SizedBox(height: 4),
              Text('语速',
                  style: GoogleFonts.inter(
                      fontSize: 9, color: AppColors.outline,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (showMenu)
          Positioned(
            bottom: 56,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(14),
              color: AppColors.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: rates.map((r) {
                    return InkWell(
                      onTap: () => onSelect(r),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text('${r}x',
                            style: GoogleFonts.outfit(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AuxButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AuxButton({
    required this.icon, required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 9, color: AppColors.outline,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
