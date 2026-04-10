/// 语音信息
class VoiceInfo {
  final String voiceId;
  final String displayName;
  final String? group;       // 分组标签（如"情感音色"、"专业播报"）
  final String? description; // 简短描述

  const VoiceInfo({
    required this.voiceId,
    required this.displayName,
    this.group,
    this.description,
  });

  factory VoiceInfo.fromJson(Map<String, dynamic> json) {
    return VoiceInfo(
      voiceId: json['voice_id'] as String,
      displayName: json['display_name'] as String,
      group: json['group'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'voice_id': voiceId,
        'display_name': displayName,
        'group': group,
        'description': description,
      };
}

/// 各引擎的默认语音列表（离线备用）
abstract final class DefaultVoices {
  static const doubao = [
    VoiceInfo(voiceId: 'zh_female_shuangkuaisisi_moon_bigtts', displayName: '爽快思思', group: '活泼女声'),
    VoiceInfo(voiceId: 'zh_male_jingqiangkanye_moon_bigtts', displayName: '京腔侃爷', group: '磁性男声'),
    VoiceInfo(voiceId: 'zh_female_wanqudashu_moon_bigtts', displayName: '温柔大姝', group: '温柔女声'),
    VoiceInfo(voiceId: 'zh_female_tianmeimeixue_moon_bigtts', displayName: '甜美美雪', group: '甜美女声'),
    VoiceInfo(voiceId: 'zh_male_aojiaobazong_moon_bigtts', displayName: '磁性霸总', group: '磁性男声'),
    VoiceInfo(voiceId: 'zh_female_qiaopizitong_moon_bigtts', displayName: '俏皮子彤', group: '活泼女声'),
  ];

  static const qwen3 = [
    VoiceInfo(voiceId: 'Cherry', displayName: 'Cherry', group: '女声'),
    VoiceInfo(voiceId: 'Serena', displayName: 'Serena', group: '女声'),
    VoiceInfo(voiceId: 'Ethan', displayName: 'Ethan', group: '男声'),
    VoiceInfo(voiceId: 'Dylan', displayName: 'Dylan', group: '男声'),
    VoiceInfo(voiceId: 'Bella', displayName: 'Bella', group: '女声'),
    VoiceInfo(voiceId: 'Brian', displayName: 'Brian', group: '男声'),
  ];

  static const seedTts2 = [
    VoiceInfo(voiceId: 'zh_female_wanqudashu', displayName: '温柔女声', group: '女声'),
    VoiceInfo(voiceId: 'zh_male_jingqiang', displayName: '磁性男声', group: '男声'),
    VoiceInfo(voiceId: 'zh_female_tianmei', displayName: '甜美女声', group: '女声'),
    VoiceInfo(voiceId: 'zh_male_kuaisu', displayName: '活力男声', group: '男声'),
  ];

  static const tencent = [
    VoiceInfo(voiceId: '1001', displayName: '智瑜（女）', group: '标准'),
    VoiceInfo(voiceId: '1002', displayName: '智聆（女）', group: '标准'),
    VoiceInfo(voiceId: '1003', displayName: '智美（女）', group: '标准'),
    VoiceInfo(voiceId: '1004', displayName: '智云（男）', group: '标准'),
    VoiceInfo(voiceId: '1005', displayName: '智莉（女）', group: '标准'),
    VoiceInfo(voiceId: '101001', displayName: '智瑜-精品（女）', group: '精品'),
    VoiceInfo(voiceId: '101002', displayName: '智聆-精品（女）', group: '精品'),
  ];

  static const microsoft = [
    VoiceInfo(voiceId: 'zh-CN-XiaoxiaoNeural', displayName: '晓晓（女）', group: '普通话'),
    VoiceInfo(voiceId: 'zh-CN-YunxiNeural', displayName: '云希（男）', group: '普通话'),
    VoiceInfo(voiceId: 'zh-CN-YunjianNeural', displayName: '云健（男）', group: '普通话'),
    VoiceInfo(voiceId: 'zh-CN-XiaohanNeural', displayName: '晓涵（女）', group: '普通话'),
    VoiceInfo(voiceId: 'zh-TW-HsiaoChenNeural', displayName: '曉臻（女）', group: '台湾'),
    VoiceInfo(voiceId: 'zh-HK-HiuMaanNeural', displayName: '曉曼（女）', group: '粤语'),
  ];

  static const minimax = [
    VoiceInfo(voiceId: 'male-qn-qingse', displayName: '青涩男声', group: '男声'),
    VoiceInfo(voiceId: 'male-qn-jingying', displayName: '精英男声', group: '男声'),
    VoiceInfo(voiceId: 'female-shaonv', displayName: '少女音色', group: '女声'),
    VoiceInfo(voiceId: 'female-yujie', displayName: '御姐音色', group: '女声'),
    VoiceInfo(voiceId: 'female-tianmei', displayName: '甜美音色', group: '女声'),
    VoiceInfo(voiceId: 'presenter_male', displayName: '男主播', group: '播报'),
    VoiceInfo(voiceId: 'presenter_female', displayName: '女主播', group: '播报'),
  ];
}
