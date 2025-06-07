import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../chat_list/controllers/chat_list_controller.dart';
import '../../../services/openai_service.dart';
import '../../../services/elevenlabs_service.dart';
import '../../../services/audio_service.dart';

class Message {
  final String id;
  final String content;
  final bool isFromMe;
  final DateTime timestamp;
  final bool isError;
  final String? audioFilePath;
  final bool isGeneratingAudio;

  Message({
    required this.id,
    required this.content,
    required this.isFromMe,
    required this.timestamp,
    this.isError = false,
    this.audioFilePath,
    this.isGeneratingAudio = false,
  });

  Message copyWith({
    String? id,
    String? content,
    bool? isFromMe,
    DateTime? timestamp,
    bool? isError,
    String? audioFilePath,
    bool? isGeneratingAudio,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isFromMe: isFromMe ?? this.isFromMe,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      isGeneratingAudio: isGeneratingAudio ?? this.isGeneratingAudio,
    );
  }
}

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  var messages = <Message>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var isTyping = false.obs;
  var currentChat = Rxn<ChatItem>();
  var audioGeneratingMessageIds = <String>{}.obs;
  
  // 🎵 自动语音播放设置
  var autoPlayVoice = true.obs; // 默认开启自动语音播放

  AudioService get audioService => AudioService.instance;

  @override
  void onInit() {
    super.onInit();
    currentChat.value = Get.arguments as ChatItem?;
    
    // 确保音频服务已初始化
    if (!Get.isRegistered<AudioService>()) {
      Get.put(AudioService());
    }
    
    loadMessages();
  }

  void loadMessages() async {
    isLoading.value = true;
    
    try {
      final networkStatus = await OpenAIService.getNetworkStatus();
      print('网络状态: $networkStatus');
    } catch (e) {
      print('网络检查失败: $e');
    }
    
    await Future.delayed(Duration(seconds: 1));
    
    final welcomeMessageId = '1';
    final welcomeContent = '你好！我是 AI 助手，有什么可以帮助您的吗？现在我的回复会自动播放语音！';
    
    messages.value = [
      Message(
        id: welcomeMessageId,
        content: welcomeContent,
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 1)),
      ),
    ];
    
    isLoading.value = false;
    scrollToBottom();
    
    // 🎵 自动为欢迎消息生成并播放语音
    if (autoPlayVoice.value) {
      await Future.delayed(Duration(milliseconds: 1000)); // 等待UI渲染完成
      await _autoGenerateAndPlayAudio(welcomeMessageId, welcomeContent);
    }
  }

  void sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || isSending.value) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromMe: true,
      timestamp: DateTime.now(),
    );
    
    messages.add(userMessage);
    messageController.clear();
    scrollToBottom();

    isSending.value = true;
    isTyping.value = true;

    try {
      final aiMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      final replyMessage = Message(
        id: aiMessageId,
        content: '正在思考中...',
        isFromMe: false,
        timestamp: DateTime.now(),
      );
      
      messages.add(replyMessage);
      scrollToBottom();

      String fullResponse = '';
      bool isFirstChunk = true;
      
      await for (final chunk in OpenAIService.sendMessageStream(content)) {
        if (isFirstChunk) {
          isTyping.value = false;
          fullResponse = chunk;
          isFirstChunk = false;
        } else {
          fullResponse += chunk;
        }
        
        final isError = fullResponse.contains('❌') || 
                       fullResponse.contains('⚠️') || 
                       fullResponse.contains('⏰') || 
                       fullResponse.contains('💳');
        
        final messageIndex = messages.indexWhere((msg) => msg.id == aiMessageId);
        if (messageIndex != -1) {
          messages[messageIndex] = Message(
            id: aiMessageId,
            content: fullResponse,
            isFromMe: false,
            timestamp: DateTime.now(),
            isError: isError,
          );
          
          if (fullResponse.length % 30 == 0) {
            scrollToBottom();
          }
        }
      }
      
      scrollToBottom();
      
      // 🎵 自动生成并播放语音 - 新增功能
      if (autoPlayVoice.value && fullResponse.isNotEmpty && !fullResponse.contains('❌') && !fullResponse.contains('⚠️')) {
        print('🎤 AI回复完成，自动生成语音输出...');
        
        // 延迟一下确保UI更新完成
        await Future.delayed(Duration(milliseconds: 500));
        
        // 自动生成并播放语音
        await _autoGenerateAndPlayAudio(aiMessageId, fullResponse);
      }
      
    } catch (e) {
      print('发送消息错误: $e');
      
      messages.removeWhere((msg) => msg.content == '正在思考中...');
      
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '抱歉，发送消息时出现错误，请稍后重试。\n\n错误详情: ${e.toString()}',
        isFromMe: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      
      messages.add(errorMessage);
      scrollToBottom();
    } finally {
      isSending.value = false;
      isTyping.value = false;
    }
  }

  /// 自动生成并播放语音（内部方法）
  Future<void> _autoGenerateAndPlayAudio(String messageId, String text) async {
    try {
      // 检查文本是否适合TTS
      if (text.length < 5) {
        print('⚠️ 文本太短，跳过语音生成');
        return;
      }

      // 标记正在生成音频
      audioGeneratingMessageIds.add(messageId);
      
      print('🎤 自动生成语音: ${text.length > 50 ? text.substring(0, 50) + "..." : text}');
      
      // 调用ElevenLabs服务生成语音
      final audioFilePath = await ElevenLabsService.textToSpeech(text);
      
      if (audioFilePath != null) {
        // 更新消息，添加音频文件路径
        final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
        if (messageIndex != -1) {
          messages[messageIndex] = messages[messageIndex].copyWith(
            audioFilePath: audioFilePath,
          );
        }
        
        // 自动播放音频
        final success = await audioService.playAudio(audioFilePath, messageId);
        
        if (success) {
          print('✅ 语音自动生成并播放成功');
          Get.snackbar(
            '🎵 AI语音', 
            '正在播放AI回复的语音版本', 
            duration: Duration(seconds: 3),
            backgroundColor: Colors.blue.withOpacity(0.1),
            colorText: Colors.blue,
          );
        } else {
          print('❌ 音频播放失败');
        }
      } else {
        print('❌ 语音生成失败');
      }
      
    } catch (e) {
      print('❌ 自动语音生成失败: $e');
    } finally {
      audioGeneratingMessageIds.remove(messageId);
    }
  }

  /// 生成并播放语音
  Future<void> generateAndPlayAudio(String messageId, String text) async {
    try {
      // 检查文本是否适合TTS
      if (text.length < 5 || text.contains('❌') || text.contains('⚠️')) {
        Get.snackbar('提示', '该消息无法生成语音');
        return;
      }

      // 标记正在生成音频
      audioGeneratingMessageIds.add(messageId);
      
      print('🎤 开始为消息生成语音: $messageId');
      
      // 调用ElevenLabs服务生成语音
      final audioFilePath = await ElevenLabsService.textToSpeech(text);
      
      if (audioFilePath != null) {
        // 更新消息，添加音频文件路径
        final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
        if (messageIndex != -1) {
          messages[messageIndex] = messages[messageIndex].copyWith(
            audioFilePath: audioFilePath,
          );
        }
        
        // 播放音频
        final success = await audioService.playAudio(audioFilePath, messageId);
        
        if (success) {
          print('✅ 语音生成并播放成功');
          Get.snackbar('成功', '🎵 语音播放开始', duration: Duration(seconds: 2));
        } else {
          Get.snackbar('错误', '音频播放失败');
        }
      } else {
        Get.snackbar('错误', '语音生成失败，请检查ElevenLabs配置');
      }
      
    } catch (e) {
      print('❌ 语音生成失败: $e');
      Get.snackbar('错误', '语音生成失败: ${e.toString()}');
    } finally {
      audioGeneratingMessageIds.remove(messageId);
    }
  }

  /// 切换音频播放状态
  Future<void> toggleAudioPlayback(String messageId, String? audioFilePath) async {
    if (audioFilePath == null) {
      // 如果没有音频文件，生成新的
      final message = messages.firstWhere((msg) => msg.id == messageId);
      await generateAndPlayAudio(messageId, message.content);
      return;
    }

    // 播放已存在的音频文件
    final success = await audioService.playAudio(audioFilePath, messageId);
    if (!success) {
      Get.snackbar('错误', '音频播放失败');
    }
  }
  
  /// 切换自动语音播放设置
  void toggleAutoPlayVoice() {
    autoPlayVoice.value = !autoPlayVoice.value;
    final status = autoPlayVoice.value ? '开启' : '关闭';
    Get.snackbar(
      '🎵 语音设置', 
      '自动语音播放已$status',
      duration: Duration(seconds: 2),
      backgroundColor: autoPlayVoice.value ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
      colorText: autoPlayVoice.value ? Colors.green : Colors.orange,
    );
    print('🎵 自动语音播放设置: $status');
  }
  
  /// 获取自动语音播放状态文本
  String get autoPlayVoiceStatusText {
    return autoPlayVoice.value ? '自动语音: 开启' : '自动语音: 关闭';
  }

  void retrySendMessage(String content) {
    messageController.text = content;
    sendMessage();
  }

  void stopGeneration() {
    isSending.value = false;
    isTyping.value = false;
  }

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);
    
    if (messageDay == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void clearHistory() {
    Get.dialog(
      AlertDialog(
        title: Text('清除聊天记录'),
        content: Text('确定要清除所有聊天记录吗？此操作无法撤销，包括已生成的语音文件。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 停止音频播放
              await audioService.stopAudio();
              
              // 清理音频文件
              await ElevenLabsService.clearAllAudioFiles();
              
              // 清除消息和历史
              messages.clear();
              OpenAIService.clearHistory();
              audioGeneratingMessageIds.clear();
              
              Get.back();
              Get.snackbar('成功', '聊天记录和语音文件已清除');
            },
            child: Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
} 