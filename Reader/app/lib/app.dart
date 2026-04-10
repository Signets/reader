import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/player_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/floating_player.dart';
import 'widgets/search_modal.dart';
import 'providers/speech_provider.dart';
import 'providers/library_provider.dart';
import 'models/playlist_item.dart';

class FluidReaderApp extends StatelessWidget {
  const FluidReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluid Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSearchOpen = false;

  late final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speech = context.watch<SpeechProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── 背景装饰光晕 ──────────────────────────
          const Positioned.fill(child: _BackgroundGradient()),

          // ── 主内容（PageView 保持各页面状态）────────
          Positioned.fill(
            bottom: 0,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                HomeScreen(),
                LibraryScreen(),
                SettingsScreen(),
              ],
            ),
          ),

          // ── 底部导航栏 ────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              currentIndex: _currentIndex,
              onTap: _navigateTo,
            ),
          ),

          // ── 全屏播放器 ────────────────────────────
          if (speech.currentItem != null && !speech.isMinimized)
            PlayerScreen(
              key: const ValueKey('player'),
              item: speech.currentItem!,
              onMinimize: () => speech.minimize(),
              onNavigateToSettings: () {
                speech.minimize();
                _navigateTo(2);
              },
            ),

          // ── 悬浮迷你播放球 ────────────────────────
          if (speech.currentItem != null && speech.isMinimized && speech.isPlaying)
            FloatingPlayer(
              title: speech.currentItem!.title,
              onTap: () => speech.restore(),
            ),

          // ── 搜索浮层 ──────────────────────────────
          if (_isSearchOpen)
            SearchModal(
              onClose: () => setState(() => _isSearchOpen = false),
              onSelectItem: (item) {
                setState(() => _isSearchOpen = false);
                _playItem(item);
              },
            ),
        ],
      ),
    );
  }

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  void _playItem(PlaylistItem item) {
    final speech = context.read<SpeechProvider>();
    final library = context.read<LibraryProvider>();
    speech.playItem(item, library);
    speech.restore();
  }

  // 供子页面调用（通过 InheritedWidget 或直接找 State）
  void openSearch() => setState(() => _isSearchOpen = true);
}

// ── 背景渐变装饰 ─────────────────────────────────────

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
