import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../chat_list/controllers/chat_list_controller.dart';
import '../../../services/openai_service.dart';

class Message {
  final String id;
  final String content;
  final bool isFromMe;
  final DateTime timestamp;
  final bool isError;

  Message({
    required this.id,
    required this.content,
    required this.isFromMe,
    required this.timestamp,
    this.isError = false,
  });
}

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  var messages = <Message>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var currentChat = Rxn<ChatItem>();

  @override
  void onInit() {
    super.onInit();
    currentChat.value = Get.arguments as ChatItem?;
    loadMessages();
  }

  void loadMessages() async {
    isLoading.value = true;
    
    // 检查网络连接
    try {
      final networkStatus = await OpenAIService.getNetworkStatus();
      print('网络状态: $networkStatus');
    } catch (e) {
      print('网络检查失败: $e');
    }
    
    // 模拟加载历史消息
    await Future.delayed(Duration(seconds: 1));
    
    messages.value = [
      Message(
        id: '1',
        content: '你好！我是 AI 助手，有什么可以帮助您的吗？\n\n💡 如果遇到网络问题，可以在右上角菜单中使用"网络诊断"功能。',
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 1)),
      ),
    ];
    
    isLoading.value = false;
    scrollToBottom();
  }

  void sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || isSending.value) return;

    // 添加用户发送的消息
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromMe: true,
      timestamp: DateTime.now(),
    );
    
    messages.add(userMessage);
    messageController.clear();
    scrollToBottom();

    // 设置发送状态
    isSending.value = true;

    try {
      // 调用 OpenAI API 获取回复
      final aiReply = await OpenAIService.sendMessage(content);
      
      // 添加 AI 回复消息
      final replyMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiReply,
        isFromMe: false,
        timestamp: DateTime.now(),
        isError: aiReply.contains('❌') || aiReply.contains('⚠️') || aiReply.contains('⏰') || aiReply.contains('💳'),
      );
      
      messages.add(replyMessage);
      scrollToBottom();
    } catch (e) {
      print('发送消息错误: $e');
      
      // 添加错误消息
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '抱歉，发送消息时出现错误，请稍后重试。',
        isFromMe: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      
      messages.add(errorMessage);
      scrollToBottom();
    } finally {
      isSending.value = false;
    }
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
        content: Text('确定要清除所有聊天记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              messages.clear();
              OpenAIService.clearHistory();
              Get.back();
              Get.snackbar('成功', '聊天记录已清除');
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