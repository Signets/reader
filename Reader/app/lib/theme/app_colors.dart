import 'package:flutter/material.dart';

/// 应用颜色系统 — 对应设计稿 CSS 自定义属性
abstract final class AppColors {
  // ── 主色调（暖调靛紫）──────────────────────────────
  static const Color primary = Color(0xFF5B5BDB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE5E5FF);
  static const Color onPrimaryContainer = Color(0xFF1A1871);

  // ── 次级色（浅紫）──────────────────────────────────
  static const Color secondary = Color(0xFF8B7CF6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFEDE9FF);
  static const Color onSecondaryContainer = Color(0xFF3D2FA0);

  // ── 第三色（暖橙）──────────────────────────────────
  static const Color tertiary = Color(0xFFE07B54);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFDDD2);
  static const Color onTertiaryContainer = Color(0xFF6B2D14);

  // ── 表面色（暖白系）────────────────────────────────
  static const Color surface = Color(0xFFFDFCFB);
  static const Color onSurface = Color(0xFF1A1917);
  static const Color surfaceContainer = Color(0xFFF2F0EE);
  static const Color surfaceContainerLow = Color(0xFFF7F5F3);
  static const Color surfaceContainerHigh = Color(0xFFECEAE7);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // ── 错误色 ──────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // ── 轮廓色 ──────────────────────────────────────────
  static const Color outline = Color(0xFFADADAD);
  static const Color outlineVariant = Color(0xFFD9D9D9);

  // ── 导航栏毛玻璃背景 ────────────────────────────────
  static const Color navBackground = Color(0xFFFAF9F8);

  // ── 卡拉OK 高亮 ─────────────────────────────────────
  static const Color karaokeActive = Color(0xFF1A1917);
  static const Color karaokePending = Color(0xFFADADAD);
}
