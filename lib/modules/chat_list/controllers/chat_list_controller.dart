import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class ChatItem {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final int unreadCount;

  ChatItem({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });
}

class ChatListController extends GetxController {
  var chatList = <ChatItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadChatList();
  }

  void loadChatList() async {
    isLoading.value = true;
    
    // 模拟加载数据
    await Future.delayed(Duration(seconds: 1));
    
    chatList.value = [
      ChatItem(
        id: '1',
        name: '张三',
        avatar: '😊',
        lastMessage: '你好，最近怎么样？',
        time: '10:30',
        unreadCount: 2,
      ),
      ChatItem(
        id: '2',
        name: '李四',
        avatar: '🤔',
        lastMessage: '今天的会议记得参加',
        time: '09:15',
        unreadCount: 0,
      ),
      ChatItem(
        id: '3',
        name: '王五',
        avatar: '😄',
        lastMessage: '周末一起去爬山吧',
        time: '昨天',
        unreadCount: 5,
      ),
      ChatItem(
        id: '4',
        name: '赵六',
        avatar: '🎉',
        lastMessage: '生日快乐！',
        time: '昨天',
        unreadCount: 1,
      ),
    ];
    
    isLoading.value = false;
  }

  void openChat(ChatItem item) {
    Get.toNamed(AppRoutes.CHAT, arguments: item);
  }

  void logout() {
    Get.offAllNamed(AppRoutes.LOGIN);
  }
} 