import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_item.dart';

/// 媒体库状态管理（播放清单 + 历史记录）
class LibraryProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  List<PlaylistItem> _playlist = [];
  List<PlaylistItem> _history = [];

  List<PlaylistItem> get playlist => List.unmodifiable(_playlist);
  List<PlaylistItem> get history => List.unmodifiable(_history);

  List<PlaylistItem> get allItems => [..._playlist, ..._history];

  /// 初始化，加载持久化数据
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
    // 如果没有数据则加载示例数据
    if (_playlist.isEmpty && _history.isEmpty) {
      _loadSampleData();
    }
  }

  void _loadData() {
    final playlistJson = _prefs.getString('playlist');
    if (playlistJson != null) {
      final list = jsonDecode(playlistJson) as List<dynamic>;
      _playlist = list.map((e) => PlaylistItem.fromJson(e as Map<String, dynamic>)).toList();
    }

    final historyJson = _prefs.getString('history');
    if (historyJson != null) {
      final list = jsonDecode(historyJson) as List<dynamic>;
      _history = list.map((e) => PlaylistItem.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  void _loadSampleData() {
    _playlist = [
      PlaylistItem(
        id: 'p1',
        title: 'AI时代的深度阅读：从被动吸收到主动构建',
        excerpt: '在这个信息爆炸的时代，如何利用 TTS 技术将碎片化时间转化为深度的学习体验？',
        content:
            '在这个信息爆炸的时代，如何利用 TTS 技术将碎片化时间转化为深度的学习体验？本文探讨了多感官参与对长时记忆的影响。研究表明，当视觉和听觉同时参与信息处理时，大脑的记忆编码效率会显著提高。',
        type: PlaylistItemType.link,
        timestamp: '2分钟前',
      ),
      PlaylistItem(
        id: 'p2',
        title: '如何更高效地使用 TTS 语音朗读进行创作',
        excerpt: '通过听自己的文字，你可以更容易发现语病、逻辑断裂以及节奏不协调的地方。',
        content:
            '通过听自己的文字，你可以更容易发现语病、逻辑断裂以及节奏不协调的地方。这是专业编辑常用的"出声校对法"。当你听到文字被朗读出来时，你的大脑会从不同的维度去审视它。',
        type: PlaylistItemType.clipboard,
        timestamp: '15分钟前',
      ),
    ];

    _history = [
      PlaylistItem(
        id: 'h1',
        title: '2024年数字极简主义生活指南',
        excerpt: '卡尔·纽波特的理论在当下依然适用。减少无意义的通知，将注意力集中在有深度的内容上。',
        content:
            '卡尔·纽波特的理论在当下依然适用。减少无意义的通知，将注意力集中在有深度、有产出的内容摄入上。数字极简主义不是拒绝技术，而是有意识地选择技术。',
        type: PlaylistItemType.file,
        timestamp: '1小时前',
        isPlayed: true,
      ),
    ];
  }

  // ── 播放清单操作 ──────────────────────────────────

  Future<void> addToPlaylist(PlaylistItem item) async {
    _playlist.insert(0, item);
    await _savePlaylist();
    notifyListeners();
  }

  Future<void> moveToHistory(PlaylistItem item) async {
    // 从清单移除
    _playlist.removeWhere((p) => p.id == item.id);
    // 添加到历史（已播放）
    _history.removeWhere((h) => h.id == item.id);
    _history.insert(0, item.copyWith(isPlayed: true, timestamp: '刚刚'));
    await _savePlaylist();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> deleteFromPlaylist(List<String> ids) async {
    _playlist.removeWhere((p) => ids.contains(p.id));
    await _savePlaylist();
    notifyListeners();
  }

  Future<void> deleteFromHistory(List<String> ids) async {
    _history.removeWhere((h) => ids.contains(h.id));
    await _saveHistory();
    notifyListeners();
  }

  // ── 持久化 ────────────────────────────────────────

  Future<void> _savePlaylist() async {
    final json = jsonEncode(_playlist.map((e) => e.toJson()).toList());
    await _prefs.setString('playlist', json);
  }

  Future<void> _saveHistory() async {
    final json = jsonEncode(_history.map((e) => e.toJson()).toList());
    await _prefs.setString('history', json);
  }
}
