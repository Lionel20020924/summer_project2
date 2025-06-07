import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIConfig {
  // 从环境变量读取配置
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get model => dotenv.env['OPENAI_MODEL'] ?? 'gpt-3.5-turbo';
  static int get maxTokens => int.tryParse(dotenv.env['OPENAI_MAX_TOKENS'] ?? '150') ?? 150;
  static double get temperature => double.tryParse(dotenv.env['OPENAI_TEMPERATURE'] ?? '0.7') ?? 0.7;
  
  static Future<void> initialize() async {
    // 加载环境变量
    try {
      await dotenv.load(fileName: ".env");
      print('✅ 环境配置加载成功');
      print('📁 从 .env 文件读取配置');
    } catch (e) {
      print('⚠️ 环境配置文件未找到，使用默认配置: $e');
      print('💡 请确保项目根目录存在 .env 文件');
    }
    
    if (isConfigured) {
      OpenAI.apiKey = apiKey;
      print('✅ OpenAI API 已初始化');
      print('🔑 API Key: ${_maskApiKey(apiKey)}');
      print('🤖 模型: $model');
      print('📊 最大令牌数: $maxTokens');
      print('🌡️ 温度: $temperature');
    } else {
      print('❌ OpenAI API Key 未配置');
      print('💡 请检查 .env 文件中的 OPENAI_API_KEY 配置');
      print('📝 参考 .env.example 文件进行配置');
    }
  }
  
  // 检查 API 密钥是否已配置
  static bool get isConfigured => apiKey.isNotEmpty && 
    apiKey != 'your_openai_api_key_here' && 
    apiKey.startsWith('sk-');
  
  // 获取完整配置信息
  static Map<String, dynamic> get config => {
    'api_key_configured': isConfigured,
    'api_key_masked': _maskApiKey(apiKey),
    'model': model,
    'max_tokens': maxTokens,
    'temperature': temperature,
    'app_debug': dotenv.env['APP_DEBUG'] == 'true',
    'app_version': dotenv.env['APP_VERSION'] ?? '1.0.0',
  };
  
  // 获取配置摘要（用于调试，不包含敏感信息）
  static String get configSummary => '''
🔧 OpenAI 配置摘要:
• API Key: ${isConfigured ? '已配置 ✅' : '未配置 ❌'}
• 模型: $model
• 最大令牌: $maxTokens
• 温度: $temperature
• 调试模式: ${dotenv.env['APP_DEBUG'] == 'true' ? '开启' : '关闭'}
• 应用版本: ${dotenv.env['APP_VERSION'] ?? '1.0.0'}
''';
  
  // 安全地显示API密钥（只显示前缀和后缀）
  static String _maskApiKey(String key) {
    if (key.length <= 10) return '***';
    return '${key.substring(0, 10)}...${key.substring(key.length - 4)}';
  }
  
  // 验证API密钥格式
  static bool get isValidApiKey {
    return apiKey.isNotEmpty && 
           apiKey.startsWith('sk-') && 
           apiKey.length > 20;
  }
} 