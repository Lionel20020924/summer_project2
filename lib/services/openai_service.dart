import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../config/openai_config.dart';

class OpenAIService {
  // 聊天上下文，保存对话历史
  static List<Map<String, String>> _chatHistory = [];
  
  /// 初始化 OpenAI
  static void initialize() {
    if (OpenAIConfig.isConfigured) {
      OpenAI.apiKey = OpenAIConfig.apiKey;
      print('✅ OpenAI Service 已初始化');
      print('🔑 API Key: ${OpenAIConfig.config['api_key_masked']}');
      print(OpenAIConfig.configSummary);
    } else {
      print('❌ OpenAI Service 初始化失败');
      print('💡 请检查 .env 文件中的环境变量配置');
    }
  }
  
  /// 使用 HTTP 直接调用 OpenAI API
  static Future<String> sendMessageDirect(String userMessage) async {
    try {
      print('🚀 使用 HTTP 直接调用 OpenAI API');
      print('📤 用户消息: $userMessage');
      
      // 构建请求体 - 使用环境变量配置
      final messages = [
        {
          "role": "system",
          "content": "你是一个友善、有帮助的AI助手。请用中文简洁地回复用户的问题。"
        },
        ..._chatHistory,
        {
          "role": "user",
          "content": userMessage
        }
      ];
      
      final requestBody = {
        "model": OpenAIConfig.model,           // 使用环境变量
        "messages": messages,
        "max_tokens": OpenAIConfig.maxTokens,  // 使用环境变量
        "temperature": OpenAIConfig.temperature, // 使用环境变量
      };
      
      print('📡 发送请求到 OpenAI...');
      print('🔗 URL: https://api.openai.com/v1/chat/completions');
      print('⚙️ 模型: ${OpenAIConfig.model}');
      print('🎛️ 最大令牌: ${OpenAIConfig.maxTokens}');
      
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}', // 使用环境变量
        },
        body: json.encode(requestBody),
      ).timeout(Duration(seconds: 30));
      
      print('📨 响应状态码: ${response.statusCode}');
      print('📄 响应头: ${response.headers}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API 调用成功');
        print('📋 完整响应: ${json.encode(data)}');
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final aiReply = data['choices'][0]['message']['content'] as String;
          
          // 保存到聊天历史
          _chatHistory.add({"role": "user", "content": userMessage});
          _chatHistory.add({"role": "assistant", "content": aiReply});
          
          // 控制历史长度
          if (_chatHistory.length > 20) {
            _chatHistory = _chatHistory.sublist(_chatHistory.length - 20);
          }
          
          print('🤖 AI 回复: $aiReply');
          return aiReply;
        } else {
          print('❌ 响应中没有找到回复内容');
          return '抱歉，AI 没有返回有效的回复内容。';
        }
      } else {
        print('❌ API 调用失败');
        print('🔍 错误响应: ${response.body}');
        
        if (response.statusCode == 401) {
          return '🔑 API 密钥无效或已过期\n\n请检查：\n• .env 文件中的 OPENAI_API_KEY 是否正确\n• 账户是否有余额\n• 密钥权限是否正确';
        } else if (response.statusCode == 429) {
          return '⏰ 请求过于频繁\n\n请等待一段时间后重试';
        } else if (response.statusCode == 402) {
          return '💳 账户余额不足\n\n请前往 OpenAI 官网充值';
        } else {
          return '❌ API 调用失败 (${response.statusCode})\n\n错误信息: ${response.body}';
        }
      }
    } catch (e) {
      print('💥 HTTP 请求异常: $e');
      if (e.toString().contains('TimeoutException')) {
        return '⏰ 请求超时\n\n请检查网络连接或稍后重试';
      } else if (e.toString().contains('SocketException')) {
        return '🌐 网络连接失败\n\n请检查网络连接，如果在中国大陆请使用 VPN';
      } else {
        return '❌ 请求失败: ${e.toString()}';
      }
    }
  }
  
  /// 使用 dart_openai 包调用 API
  static Future<String> sendMessageWithPackage(String userMessage) async {
    try {
      print('📦 使用 dart_openai 包调用 API');
      print('📤 用户消息: $userMessage');
      
      // 确保 API Key 已设置
      OpenAI.apiKey = OpenAIConfig.apiKey;
      
      // 构建消息历史
      final messages = <OpenAIChatCompletionChoiceMessageModel>[
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "你是一个友善、有帮助的AI助手。请用中文简洁地回复用户的问题。"
            )
          ],
          role: OpenAIChatMessageRole.system,
        ),
      ];
      
      // 添加历史消息
      for (final msg in _chatHistory) {
        messages.add(
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(msg['content']!)
            ],
            role: msg['role'] == 'user' 
                ? OpenAIChatMessageRole.user 
                : OpenAIChatMessageRole.assistant,
          ),
        );
      }
      
      // 添加当前用户消息
      messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessage)
          ],
          role: OpenAIChatMessageRole.user,
        ),
      );
      
      print('🔄 调用 OpenAI Chat Completion API...');
      print('⚙️ 使用配置: 模型=${OpenAIConfig.model}, 令牌=${OpenAIConfig.maxTokens}, 温度=${OpenAIConfig.temperature}');
      
      final chatCompletion = await OpenAI.instance.chat.create(
        model: OpenAIConfig.model,          // 使用环境变量
        messages: messages,
        maxTokens: OpenAIConfig.maxTokens,  // 使用环境变量
        temperature: OpenAIConfig.temperature, // 使用环境变量
      );
      
      final aiReply = chatCompletion.choices.first.message.content?.first.text ?? 
          "抱歉，我无法回复这条消息。";
      
      // 保存到聊天历史
      _chatHistory.add({"role": "user", "content": userMessage});
      _chatHistory.add({"role": "assistant", "content": aiReply});
      
      // 控制历史长度
      if (_chatHistory.length > 20) {
        _chatHistory = _chatHistory.sublist(_chatHistory.length - 20);
      }
      
      print('✅ dart_openai 调用成功');
      print('🤖 AI 回复: $aiReply');
      return aiReply;
    } catch (e) {
      print('❌ dart_openai 调用失败: $e');
      print('🔍 错误类型: ${e.runtimeType}');
      throw e;
    }
  }
  
  /// 发送消息的主方法
  static Future<String> sendMessage(String userMessage) async {
    try {
      print('🎯 开始发送消息: $userMessage');
      
      if (!OpenAIConfig.isConfigured) {
        return '❌ API 密钥未配置\n\n请在 .env 文件中设置正确的 OPENAI_API_KEY\n\n📝 参考 .env.example 文件进行配置';
      }
      
      if (!OpenAIConfig.isValidApiKey) {
        return '🔑 API 密钥格式无效\n\n请确保密钥以 "sk-" 开头且长度正确';
      }
      
      // 先尝试使用 HTTP 直接调用
      try {
        print('🔄 尝试方法1: HTTP 直接调用');
        return await sendMessageDirect(userMessage);
      } catch (e) {
        print('⚠️ HTTP 直接调用失败: $e');
        print('🔄 尝试方法2: dart_openai 包调用');
        
        // 如果 HTTP 调用失败，尝试使用 dart_openai 包
        try {
          return await sendMessageWithPackage(userMessage);
        } catch (e2) {
          print('❌ dart_openai 包调用也失败: $e2');
          return _handleError(e2);
        }
      }
    } catch (e) {
      print('💥 总体调用失败: $e');
      return _handleError(e);
    }
  }
  
  /// 测试 API 连接
  static Future<bool> testConnection() async {
    try {
      print('🧪 测试 OpenAI API 连接...');
      
      final response = await http.get(
        Uri.parse('https://api.openai.com/v1/models'),
        headers: {
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}', // 使用环境变量
        },
      ).timeout(Duration(seconds: 10));
      
      print('📊 测试响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ API 连接测试成功');
        final data = json.decode(response.body);
        print('📋 可用模型数量: ${data['data']?.length ?? 0}');
        return true;
      } else if (response.statusCode == 401) {
        print('🔑 API 密钥无效');
        return false;
      } else {
        print('⚠️ API 响应异常: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ 连接测试失败: $e');
      return false;
    }
  }
  
  /// 处理错误
  static String _handleError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return '🔑 API 密钥问题\n\n• 检查 .env 文件中的密钥是否正确\n• 确认账户有余额\n• 验证密钥权限';
    } else if (errorStr.contains('429')) {
      return '⏰ 请求过于频繁\n\n• 等待几分钟后重试\n• 考虑升级账户计划';
    } else if (errorStr.contains('402') || errorStr.contains('quota')) {
      return '💳 账户余额不足\n\n请前往 OpenAI 官网充值';
    } else if (errorStr.contains('timeout') || errorStr.contains('connection')) {
      return '🌐 网络连接问题\n\n• 检查网络连接\n• 如在中国大陆请使用 VPN\n• 稍后重试';
    } else {
      return '❌ 调用失败\n\n错误信息: ${error.toString()}';
    }
  }
  
  /// 清除聊天历史
  static void clearHistory() {
    _chatHistory.clear();
    print('🗑️ 聊天历史已清除');
  }
  
  /// 获取聊天历史长度
  static int get historyLength => _chatHistory.length;
  
  /// 获取网络状态
  static Future<String> getNetworkStatus() async {
    final isConnected = await testConnection();
    return isConnected ? '✅ API 连接正常' : '❌ API 连接异常';
  }
  
  /// 获取当前配置信息（用于调试）
  static String getConfigInfo() {
    return '''
🔧 当前 OpenAI 配置:
${OpenAIConfig.configSummary}

🔍 配置详情:
• API Key 配置: ${OpenAIConfig.isConfigured ? '✅' : '❌'}
• API Key 格式: ${OpenAIConfig.isValidApiKey ? '✅' : '❌'}
• 聊天历史长度: $_chatHistory.length 条消息
''';
  }
} 