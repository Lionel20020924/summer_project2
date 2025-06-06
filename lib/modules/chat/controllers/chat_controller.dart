import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../chat_list/controllers/chat_list_controller.dart';

class Message {
  final String id;
  final String content;
  final bool isFromMe;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.isFromMe,
    required this.timestamp,
  });
}

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  var messages = <Message>[].obs;
  var isLoading = false.obs;
  var currentChat = Rxn<ChatItem>();

  @override
  void onInit() {
    super.onInit();
    currentChat.value = Get.arguments as ChatItem?;
    loadMessages();
  }

  void loadMessages() async {
    isLoading.value = true;
    
    // 模拟加载历史消息
    await Future.delayed(Duration(seconds: 1));
    
    messages.value = [
      Message(
        id: '1',
        content: '你好！',
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
      ),
      Message(
        id: '2',
        content: '你好，很高兴和你聊天',
        isFromMe: true,
        timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
      ),
      Message(
        id: '3',
        content: '最近怎么样？',
        isFromMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      ),
      Message(
        id: '4',
        content: '还不错，工作挺忙的',
        isFromMe: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
      ),
    ];
    
    isLoading.value = false;
    scrollToBottom();
  }

  void sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    // 添加我发送的消息
    final myMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromMe: true,
      timestamp: DateTime.now(),
    );
    
    messages.add(myMessage);
    messageController.clear();
    scrollToBottom();

    // 模拟对方回复
    await Future.delayed(Duration(seconds: 2));
    final replies = [
      '好的，我知道了',
      '哈哈，有趣',
      '确实是这样',
      '我也这么认为',
      '说得对',
      '👍',
      '好主意！',
    ];
    
    final replyMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: replies[DateTime.now().millisecond % replies.length],
      isFromMe: false,
      timestamp: DateTime.now(),
    );
    
    messages.add(replyMessage);
    scrollToBottom();
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

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
} 