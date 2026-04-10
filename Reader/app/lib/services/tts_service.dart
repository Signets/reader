import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/tts_engine.dart';

/// TTS API 请求参数
class TtsRequest {
  final String text;
  final TtsEngineId engineId;
  final String voiceId;
  final double speed;
  final Map<String, String> credentials;

  const TtsRequest({
    required this.text,
    required this.engineId,
    required this.voiceId,
    required this.speed,
    required this.credentials,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'engine_id': engineId.name,
        'voice_id': voiceId,
        'speed': speed,
        'credentials': credentials,
      };
}

/// TTS 合成结果
sealed class TtsResult {
  const TtsResult();
}

class TtsResultAudioUrl extends TtsResult {
  final String url;
  const TtsResultAudioUrl(this.url);
}

class TtsResultAudioBytes extends TtsResult {
  final Uint8List bytes;
  const TtsResultAudioBytes(this.bytes);
}

class TtsResultError extends TtsResult {
  final String message;
  const TtsResultError(this.message);
}

/// 后端 TTS 服务
///
/// 向后端发送 POST /api/tts/synthesize 请求，
/// 后端负责调用实际的 TTS 云服务并返回音频 URL 或 base64 音频数据。
class TtsApiService {
  final String baseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  const TtsApiService({this.baseUrl = 'http://localhost:3000'});

  /// 合成语音，返回音频 URL 或字节数据
  Future<TtsResult> synthesize(TtsRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/api/tts/synthesize');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;

        if (body.containsKey('url')) {
          return TtsResultAudioUrl(body['url'] as String);
        } else if (body.containsKey('audio_base64')) {
          final bytes = base64Decode(body['audio_base64'] as String);
          return TtsResultAudioBytes(Uint8List.fromList(bytes));
        } else {
          return const TtsResultError('后端返回格式不支持');
        }
      } else {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final message = errorBody['message'] as String? ?? '合成失败 (${response.statusCode})';
        return TtsResultError(message);
      }
    } on http.ClientException catch (e) {
      return TtsResultError('网络连接失败: ${e.message}');
    } catch (e) {
      return TtsResultError('未知错误: $e');
    }
  }

  /// 解析文章链接
  Future<Map<String, String>?> parseLink(String url) async {
    try {
      final uri = Uri.parse('$baseUrl/api/parse');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'url': url}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'title': body['title'] as String? ?? '未知标题',
          'content': body['content'] as String? ?? '',
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
