import 'dart:convert';

/// 媒体库条目类型
enum PlaylistItemType {
  link,       // 网页链接
  clipboard,  // 剪贴板文字
  file,       // 本地文件
}

extension PlaylistItemTypeLabel on PlaylistItemType {
  String get label {
    switch (this) {
      case PlaylistItemType.link:      return '链接';
      case PlaylistItemType.clipboard: return '剪贴板';
      case PlaylistItemType.file:      return '本地导入';
    }
  }
}

/// 媒体库条目数据模型
class PlaylistItem {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final PlaylistItemType type;
  final String timestamp;
  final bool isPlayed;

  const PlaylistItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isPlayed = false,
  });

  PlaylistItem copyWith({
    String? id,
    String? title,
    String? excerpt,
    String? content,
    PlaylistItemType? type,
    String? timestamp,
    bool? isPlayed,
  }) {
    return PlaylistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      excerpt: excerpt ?? this.excerpt,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isPlayed: isPlayed ?? this.isPlayed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'type': type.name,
      'timestamp': timestamp,
      'isPlayed': isPlayed,
    };
  }

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      content: json['content'] as String,
      type: PlaylistItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PlaylistItemType.clipboard,
      ),
      timestamp: json['timestamp'] as String,
      isPlayed: json['isPlayed'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory PlaylistItem.fromJsonString(String jsonStr) =>
      PlaylistItem.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
