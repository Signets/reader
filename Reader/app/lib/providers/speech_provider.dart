import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/playlist_item.dart';
import '../providers/settings_provider.dart';
import '../providers/library_provider.dart';
import '../services/tts_service.dart';

/// 播放状态
enum PlaybackState {
  idle,     // 空闲
  loading,  // 加载/合成中
  playing,  // 播放中
  paused,   // 已暂停
  error,    // 错误
}

/// TTS 播放状态管理
class SpeechProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  PlaylistItem? _currentItem;
  PlaylistItem? get currentItem => _currentItem;

  PlaybackState _state = PlaybackState.idle;
  PlaybackState get state => _state;

  bool get isPlaying => _state == PlaybackState.playing;
  bool get isLoading => _state == PlaybackState.loading;

  bool _isMinimized = false;
  bool get isMinimized => _isMinimized;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 当前朗读文本按句分割
  List<String> _sentences = [];
  List<String> get sentences => _sentences;

  int _activeSentenceIndex = 0;
  int get activeSentenceIndex => _activeSentenceIndex;

  /// 当前播放进度（0.0 ～ 1.0）
  double _progress = 0.0;
  double get progress => _progress;

  String _currentPositionStr = '00:00';
  String _totalDurationStr = '00:00';
  String get currentPositionStr => _currentPositionStr;
  String get totalDurationStr => _totalDurationStr;

  SettingsProvider? _settings;

  SpeechProvider() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _state = PlaybackState.playing;
      } else if (state == PlayerState.paused) {
        _state = PlaybackState.paused;
      } else if (state == PlayerState.stopped || state == PlayerState.completed) {
        if (_state != PlaybackState.idle) {
          _state = PlaybackState.idle;
        }
      }
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      _currentPositionStr = _formatDuration(pos);
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      _totalDurationStr = _formatDuration(dur);
    });
  }

  void updateSettings(SettingsProvider settings) {
    _settings = settings;
  }

  // ── 播放操作 ──────────────────────────────────────

  Future<void> playItem(PlaylistItem item, LibraryProvider library) async {
    _currentItem = item;
    _isMinimized = false;
    _state = PlaybackState.loading;
    _errorMessage = null;
    _sentences = _splitSentences(item.content);
    _activeSentenceIndex = 0;
    notifyListeners();

    // 移动到历史记录
    await library.moveToHistory(item);

    await _synthesizeAndPlay(item.content);
  }

  Future<void> _synthesizeAndPlay(String text) async {
    if (_settings == null) {
      _setError('设置未初始化');
      return;
    }

    if (!_settings!.isCurrentEngineConfigured) {
      _setError('请先在设置页面配置 API Key');
      return;
    }

    final engine = _settings!.selectedEngine;
    final voiceId = _settings!.getSelectedVoiceId(engine.id)
        ?? _settings!.getDefaultVoices(engine.id).firstOrNull?.voiceId
        ?? '';

    final request = TtsRequest(
      text: text,
      engineId: engine.id,
      voiceId: voiceId,
      speed: _settings!.speed,
      credentials: _settings!.getEngineCredentials(engine.id),
    );

    final service = TtsApiService(baseUrl: _settings!.backendUrl);
    final result = await service.synthesize(request);

    switch (result) {
      case TtsResultAudioUrl(:final url):
        await _audioPlayer.setVolume(_settings!.volume);
        await _audioPlayer.play(UrlSource(url));

      case TtsResultAudioBytes(:final bytes):
        await _audioPlayer.setVolume(_settings!.volume);
        await _audioPlayer.play(BytesSource(bytes));

      case TtsResultError(:final message):
        _setError(message);
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _state = PlaybackState.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_state == PlaybackState.paused) {
      await _audioPlayer.resume();
      _state = PlaybackState.playing;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _state = PlaybackState.idle;
    notifyListeners();
  }

  Future<void> seekForward(Duration delta) async {
    final pos = await _audioPlayer.getCurrentPosition() ?? Duration.zero;
    await _audioPlayer.seek(pos + delta);
  }

  Future<void> seekBackward(Duration delta) async {
    final pos = await _audioPlayer.getCurrentPosition() ?? Duration.zero;
    final newPos = pos - delta;
    await _audioPlayer.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  void minimize() {
    _isMinimized = true;
    notifyListeners();
  }

  void restore() {
    _isMinimized = false;
    notifyListeners();
  }

  void _setError(String message) {
    _state = PlaybackState.error;
    _errorMessage = message;
    notifyListeners();
  }

  static List<String> _splitSentences(String text) {
    return text
        .split(RegExp(r'[。！？…\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
