import 'package:dart_openai/dart_openai.dart';
import '../config/openai_config.dart';

class OpenAIService {
  // 聊天上下文，保存对话历史
  static List<OpenAIChatCompletionChoiceMessageModel> _chatHistory = [];
  
  /// 初始化 OpenAI
  static Future<void> initialize() async {
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
  
  /// 发送消息
  static Future<String> sendMessage(String userMessage) async {
    try {
      print('🎯 开始发送消息: $userMessage');
      
      // 检查配置
      if (!OpenAIConfig.isConfigured) {
        return '❌ API 密钥未配置\n\n请在 .env 文件中设置正确的 OPENAI_API_KEY\n\n📝 参考 .env.example 文件进行配置';
      }
      
      if (!OpenAIConfig.isValidApiKey) {
        return '🔑 API 密钥格式无效\n\n请确保密钥以 "sk-" 开头且长度正确';
      }
      
      // 确保 API Key 已设置
      OpenAI.apiKey = OpenAIConfig.apiKey;
      
      // 构建消息列表
      final messages = <OpenAIChatCompletionChoiceMessageModel>[
        // 系统消息
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
      messages.addAll(_chatHistory);
      
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
      print('⚙️ 模型: ${OpenAIConfig.model}');
      print('🎛️ 最大令牌: ${OpenAIConfig.maxTokens}');
      print('🌡️ 温度: ${OpenAIConfig.temperature}');
      
      // 调用 OpenAI API
      final chatCompletion = await OpenAI.instance.chat.create(
        model: OpenAIConfig.model,
        messages: messages,
        maxTokens: OpenAIConfig.maxTokens,
        temperature: OpenAIConfig.temperature,
      );
      
      final aiReply = chatCompletion.choices.first.message.content?.first.text ?? 
          "抱歉，我无法回复这条消息。";
      
      // 保存到聊天历史
      _chatHistory.add(
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessage)
          ],
          role: OpenAIChatMessageRole.user,
        ),
      );
      
      _chatHistory.add(
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(aiReply)
          ],
          role: OpenAIChatMessageRole.assistant,
        ),
      );
      
      // 控制历史长度（保留最近20条消息）
      if (_chatHistory.length > 20) {
        _chatHistory = _chatHistory.sublist(_chatHistory.length - 20);
      }
      
      print('✅ API 调用成功');
      print('🤖 AI 回复: $aiReply');
      return aiReply;
      
    } catch (e) {
      print('❌ API 调用失败: $e');
      return _handleError(e);
    }
  }
  
  /// 流式发送消息
  static Stream<String> sendMessageStream(String userMessage) async* {
    try {
      print('🎯 开始流式发送消息: $userMessage');
      
      // 检查配置
      if (!OpenAIConfig.isConfigured) {
        yield '❌ API 密钥未配置\n\n请在 .env 文件中设置正确的 OPENAI_API_KEY';
        return;
      }
      
      // 确保 API Key 已设置
      OpenAI.apiKey = OpenAIConfig.apiKey;
      
      // 构建消息列表
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
      
      messages.addAll(_chatHistory);
      
      messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessage)
          ],
          role: OpenAIChatMessageRole.user,
        ),
      );
      
      print('🔄 开始流式调用 OpenAI API...');
      
      // 流式调用
      String fullResponse = '';
      final stream = OpenAI.instance.chat.createStream(
        model: OpenAIConfig.model,
        messages: messages,
        maxTokens: OpenAIConfig.maxTokens,
        temperature: OpenAIConfig.temperature,
      );
      
      await for (final response in stream) {
        final content = response.choices.first.delta.content?.first?.text;
        if (content != null) {
          fullResponse += content;
          yield content;
        }
      }
      
      // 保存完整对话到历史
      if (fullResponse.isNotEmpty) {
        _chatHistory.add(
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessage)
            ],
            role: OpenAIChatMessageRole.user,
          ),
        );
        
        _chatHistory.add(
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(fullResponse)
            ],
            role: OpenAIChatMessageRole.assistant,
          ),
        );
        
        // 控制历史长度
        if (_chatHistory.length > 20) {
          _chatHistory = _chatHistory.sublist(_chatHistory.length - 20);
        }
      }
      
      print('✅ 流式调用完成');
      
    } catch (e) {
      print('❌ 流式调用失败: $e');
      yield _handleError(e);
    }
  }
  
  /// 测试 API 连接
  static Future<bool> testConnection() async {
    try {
      print('🧪 测试 OpenAI API 连接...');
      
      if (!OpenAIConfig.isConfigured) {
        print('❌ API 密钥未配置');
        return false;
      }
      
      OpenAI.apiKey = OpenAIConfig.apiKey;
      
      // 使用模型列表API测试连接
      final models = await OpenAI.instance.model.list();
      
      print('✅ API 连接测试成功');
      print('📋 可用模型数量: ${models.length}');
      
      return true;
    } catch (e) {
      print('❌ 连接测试失败: $e');
      return false;
    }
  }
  
  /// 获取可用模型列表
  static Future<List<String>> getAvailableModels() async {
    try {
      OpenAI.apiKey = OpenAIConfig.apiKey;
      final models = await OpenAI.instance.model.list();
      return models.map((model) => model.id).toList();
    } catch (e) {
      print('❌ 获取模型列表失败: $e');
      return [];
    }
  }
  
  /// 处理错误
  static String _handleError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return '🔑 API 密钥问题\n\n• 检查 .env 文件中的密钥是否正确\n• 确认账户有余额\n• 验证密钥权限';
    } else if (errorStr.contains('429') || errorStr.contains('rate limit')) {
      return '⏰ 请求过于频繁\n\n• 等待几分钟后重试\n• 考虑升级账户计划';
    } else if (errorStr.contains('402') || errorStr.contains('quota')) {
      return '💳 账户余额不足\n\n请前往 OpenAI 官网充值';
    } else if (errorStr.contains('timeout') || errorStr.contains('connection')) {
      return '🌐 网络连接问题\n\n• 检查网络连接\n• 如在中国大陆请使用 VPN\n• 稍后重试';
    } else if (errorStr.contains('model') && errorStr.contains('does not exist')) {
      return '🤖 模型不存在\n\n请检查配置的模型名称是否正确';
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
  
  /// 获取聊天历史（用于调试）
  static List<Map<String, String>> getChatHistory() {
    return _chatHistory.map((msg) {
      return {
        'role': msg.role.name,
        'content': msg.content?.first.text ?? '',
      };
    }).toList();
  }
  
  /// 设置系统提示词
  static void setSystemPrompt(String prompt) {
    // 清除历史，重新开始对话
    _chatHistory.clear();
    print('🎭 系统提示词已更新: $prompt');
  }
  
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
• 聊天历史长度: ${_chatHistory.length} 条消息
''';
  }
} 