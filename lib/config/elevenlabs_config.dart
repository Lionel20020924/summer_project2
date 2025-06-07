import 'package:flutter_dotenv/flutter_dotenv.dart';

class ElevenLabsConfig {
  // 从环境变量读取配置
  static String get apiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  static String get voiceId => dotenv.env['ELEVENLABS_VOICE_ID'] ?? 'pNInz6obpgDQGcFmaJgB'; // Adam的声音ID
  static String get model => dotenv.env['ELEVENLABS_MODEL'] ?? 'eleven_multilingual_v2'; // 支持中文的模型
  static double get stability => double.tryParse(dotenv.env['ELEVENLABS_STABILITY'] ?? '0.5') ?? 0.5;
  static double get similarityBoost => double.tryParse(dotenv.env['ELEVENLABS_SIMILARITY_BOOST'] ?? '0.8') ?? 0.8;
  static double get style => double.tryParse(dotenv.env['ELEVENLABS_STYLE'] ?? '0.0') ?? 0.0;
  static bool get useSpeakerBoost => dotenv.env['ELEVENLABS_USE_SPEAKER_BOOST'] == 'true';
  
  // 检查API密钥是否已配置
  static bool get isConfigured => apiKey.isNotEmpty && apiKey != 'your_elevenlabs_api_key_here';
  
  // 获取配置摘要
  static String get configSummary => '''
🎤 ElevenLabs 配置摘要:
• API Key: ${isConfigured ? '已配置 ✅' : '未配置 ❌'}
• Voice ID: $voiceId
• 模型: $model
• 稳定性: $stability
• 相似度增强: $similarityBoost
• 风格: $style
• 声音增强: ${useSpeakerBoost ? '开启' : '关闭'}
''';
  
  // 获取完整配置信息
  static Map<String, dynamic> get config => {
    'api_key_configured': isConfigured,
    'api_key_masked': _maskApiKey(apiKey),
    'voice_id': voiceId,
    'model': model,
    'stability': stability,
    'similarity_boost': similarityBoost,
    'style': style,
    'use_speaker_boost': useSpeakerBoost,
  };
  
  // 安全地显示API密钥
  static String _maskApiKey(String key) {
    if (key.length <= 10) return '***';
    return '${key.substring(0, 10)}...${key.substring(key.length - 4)}';
  }
  
  // 验证API密钥格式
  static bool get isValidApiKey {
    return apiKey.isNotEmpty && apiKey.length > 20;
  }
  
  // 初始化配置
  static Future<void> initialize() async {
    print('🎤 ElevenLabs 配置初始化');
    if (isConfigured) {
      print('✅ ElevenLabs API 已配置');
      print(configSummary);
    } else {
      print('❌ ElevenLabs API Key 未配置');
      print('💡 请在 .env 文件中设置 ELEVENLABS_API_KEY');
      print('📝 您可以从 https://elevenlabs.io/ 获取API密钥');
    }
  }
} 