import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/library_provider.dart';
import 'providers/speech_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 固定竖屏方向
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 透明状态栏
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // 预初始化持久化 Provider
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  final libraryProvider = LibraryProvider();
  await libraryProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<LibraryProvider>.value(value: libraryProvider),
        ChangeNotifierProxyProvider<SettingsProvider, SpeechProvider>(
          create: (_) => SpeechProvider(),
          update: (_, settings, speech) {
            speech!.updateSettings(settings);
            return speech;
          },
        ),
      ],
      child: const FluidReaderApp(),
    ),
  );
}
