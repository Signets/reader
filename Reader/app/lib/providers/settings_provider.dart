import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tts_engine.dart';
import '../models/voice_info.dart';

/// 设置状态管理
class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // ── 引擎选择 ──────────────────────────────────────
  TtsEngineId _selectedEngineId = TtsEngineId.doubao;
  TtsEngineId get selectedEngineId => _selectedEngineId;

  TtsEngine get selectedEngine =>
      TtsEngineRegistry.findById(_selectedEngineId) ??
      TtsEngineRegistry.defaultEngine;

  // ── API 凭证（按引擎存储）─────────────────────────
  /// key: engineId.name__fieldKey → value
  final Map<String, String> _credentials = {};

  // ── 声音选择（按引擎存储）────────────────────────
  final Map<String, String> _selectedVoiceIds = {};

  // ── 播放设置 ──────────────────────────────────────
  double _speed = 1.0;
  double get speed => _speed;

  double _volume = 1.0;
  double get volume => _volume;

  // ── 后端地址 ──────────────────────────────────────
  String _backendUrl = 'http://localhost:3000';
  String get backendUrl => _backendUrl;

  /// 初始化，从 SharedPreferences 加载配置
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
  }

  void _load() {
    final engineName = _prefs.getString('selected_engine') ?? TtsEngineId.doubao.name;
    _selectedEngineId = TtsEngineId.values.firstWhere(
      (e) => e.name == engineName,
      orElse: () => TtsEngineId.doubao,
    );

    _speed = _prefs.getDouble('speed') ?? 1.0;
    _volume = _prefs.getDouble('volume') ?? 1.0;
    _backendUrl = _prefs.getString('backend_url') ?? 'http://localhost:3000';

    // 加载所有凭证
    final credentialsJson = _prefs.getString('credentials');
    if (credentialsJson != null) {
      final map = jsonDecode(credentialsJson) as Map<String, dynamic>;
      map.forEach((key, value) => _credentials[key] = value as String);
    }

    // 加载声音选择
    final voicesJson = _prefs.getString('selected_voices');
    if (voicesJson != null) {
      final map = jsonDecode(voicesJson) as Map<String, dynamic>;
      map.forEach((key, value) => _selectedVoiceIds[key] = value as String);
    }
  }

  // ── 引擎切换 ──────────────────────────────────────
  Future<void> setEngine(TtsEngineId id) async {
    _selectedEngineId = id;
    await _prefs.setString('selected_engine', id.name);
    notifyListeners();
  }

  // ── 凭证操作 ──────────────────────────────────────
  String getCredential(TtsEngineId engineId, String fieldKey) {
    return _credentials['${engineId.name}__$fieldKey'] ?? '';
  }

  /// 获取当前引擎所有凭证
  Map<String, String> getEngineCredentials(TtsEngineId engineId) {
    final result = <String, String>{};
    for (final field in (TtsEngineRegistry.findById(engineId)?.configFields ?? [])) {
      result[field.key] = getCredential(engineId, field.key);
    }
    return result;
  }

  Future<void> setCredential(TtsEngineId engineId, String fieldKey, String value) async {
    _credentials['${engineId.name}__$fieldKey'] = value;
    await _saveCredentials();
  }

  /// 批量保存当前引擎凭证
  Future<void> saveEngineCredentials(TtsEngineId engineId, Map<String, String> values) async {
    values.forEach((key, value) {
      _credentials['${engineId.name}__$key'] = value;
    });
    await _saveCredentials();
    notifyListeners();
  }

  Future<void> _saveCredentials() async {
    await _prefs.setString('credentials', jsonEncode(_credentials));
  }

  // ── 声音选择 ──────────────────────────────────────
  String? getSelectedVoiceId(TtsEngineId engineId) {
    return _selectedVoiceIds[engineId.name];
  }

  VoiceInfo? getSelectedVoice(TtsEngineId engineId) {
    final voiceId = getSelectedVoiceId(engineId);
    if (voiceId == null) return null;
    final voices = getDefaultVoices(engineId);
    try {
      return voices.firstWhere((v) => v.voiceId == voiceId);
    } catch (_) {
      return voices.isNotEmpty ? voices.first : null;
    }
  }

  Future<void> setSelectedVoice(TtsEngineId engineId, String voiceId) async {
    _selectedVoiceIds[engineId.name] = voiceId;
    await _prefs.setString('selected_voices', jsonEncode(_selectedVoiceIds));
    notifyListeners();
  }

  List<VoiceInfo> getDefaultVoices(TtsEngineId engineId) {
    switch (engineId) {
      case TtsEngineId.doubao:    return DefaultVoices.doubao;
      case TtsEngineId.qwen3:     return DefaultVoices.qwen3;
      case TtsEngineId.seedTts2:  return DefaultVoices.seedTts2;
      case TtsEngineId.tencent:   return DefaultVoices.tencent;
      case TtsEngineId.microsoft: return DefaultVoices.microsoft;
      case TtsEngineId.minimax:   return DefaultVoices.minimax;
    }
  }

  // ── 播放设置 ──────────────────────────────────────
  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.5, 2.0);
    await _prefs.setDouble('speed', _speed);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _prefs.setDouble('volume', _volume);
    notifyListeners();
  }

  // ── 后端地址 ──────────────────────────────────────
  Future<void> setBackendUrl(String url) async {
    _backendUrl = url.trim();
    await _prefs.setString('backend_url', _backendUrl);
    notifyListeners();
  }

  // ── 当前引擎是否已配置 ────────────────────────────
  bool get isCurrentEngineConfigured {
    final engine = selectedEngine;
    if (engine.isFree) return true;
    for (final field in engine.configFields) {
      if (field.required) {
        final val = getCredential(engine.id, field.key);
        if (val.isEmpty) return false;
      }
    }
    return true;
  }
}
