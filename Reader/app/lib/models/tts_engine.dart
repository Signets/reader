/// TTS 引擎标识符
enum TtsEngineId {
  doubao,     // 豆包 2.0（默认）
  qwen3,      // 阿里通义 Qwen3-TTS
  seedTts2,   // 火山引擎 Seed-TTS-2
  tencent,    // 腾讯云 TTS
  microsoft,  // 微软 Azure TTS（免费）
  minimax,    // MiniMax TTS
}

/// TTS 引擎描述信息
class TtsEngine {
  final TtsEngineId id;
  final String name;
  final String provider;
  final bool isFree;
  final List<ConfigField> configFields;

  const TtsEngine({
    required this.id,
    required this.name,
    required this.provider,
    this.isFree = false,
    required this.configFields,
  });
}

/// 配置字段类型
enum ConfigFieldType {
  apiKey,    // 密码输入
  text,      // 普通文本
  url,       // URL 地址
}

/// 配置字段描述
class ConfigField {
  final String key;
  final String label;
  final String placeholder;
  final ConfigFieldType type;
  final bool required;

  const ConfigField({
    required this.key,
    required this.label,
    required this.placeholder,
    this.type = ConfigFieldType.text,
    this.required = true,
  });
}

/// 注册的引擎列表
abstract final class TtsEngineRegistry {
  static const List<TtsEngine> all = [
    TtsEngine(
      id: TtsEngineId.doubao,
      name: '豆包 2.0',
      provider: '字节跳动（火山引擎）',
      configFields: [
        ConfigField(
          key: 'api_key',
          label: 'API Key',
          placeholder: '输入您的 API Key',
          type: ConfigFieldType.apiKey,
        ),
        ConfigField(
          key: 'endpoint',
          label: 'Base URL（可选）',
          placeholder: 'https://api.volcengine.com/v1',
          type: ConfigFieldType.url,
          required: false,
        ),
      ],
    ),
    TtsEngine(
      id: TtsEngineId.qwen3,
      name: '通义千问 Qwen3-TTS',
      provider: '阿里云百炼',
      configFields: [
        ConfigField(
          key: 'api_key',
          label: 'API Key',
          placeholder: '输入阿里云 DashScope API Key',
          type: ConfigFieldType.apiKey,
        ),
      ],
    ),
    TtsEngine(
      id: TtsEngineId.seedTts2,
      name: 'Seed-TTS-2',
      provider: '字节跳动（火山引擎）',
      configFields: [
        ConfigField(
          key: 'api_key',
          label: 'API Key',
          placeholder: '输入您的 API Key',
          type: ConfigFieldType.apiKey,
        ),
      ],
    ),
    TtsEngine(
      id: TtsEngineId.tencent,
      name: '腾讯云 TTS',
      provider: '腾讯云',
      configFields: [
        ConfigField(
          key: 'app_id',
          label: 'App ID',
          placeholder: '输入腾讯云 App ID',
          type: ConfigFieldType.text,
        ),
        ConfigField(
          key: 'secret_id',
          label: 'Secret ID',
          placeholder: '输入 Secret ID',
          type: ConfigFieldType.apiKey,
        ),
        ConfigField(
          key: 'secret_key',
          label: 'Secret Key',
          placeholder: '输入 Secret Key',
          type: ConfigFieldType.apiKey,
        ),
      ],
    ),
    TtsEngine(
      id: TtsEngineId.microsoft,
      name: '微软 Azure TTS',
      provider: 'Microsoft',
      isFree: true,
      configFields: [],
    ),
    TtsEngine(
      id: TtsEngineId.minimax,
      name: 'MiniMax TTS',
      provider: 'MiniMax',
      configFields: [
        ConfigField(
          key: 'api_key',
          label: 'API Key',
          placeholder: '输入 MiniMax API Key',
          type: ConfigFieldType.apiKey,
        ),
      ],
    ),
  ];

  static TtsEngine get defaultEngine => all.first;

  static TtsEngine? findById(TtsEngineId id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
