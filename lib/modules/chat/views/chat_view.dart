import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../../../services/openai_service.dart';

class ChatView extends GetView<ChatController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                controller.currentChat.value?.avatar ?? '🤖',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.currentChat.value?.name ?? 'AI 助手',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'GPT-3.5 智能助手',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all, color: Colors.white),
            onPressed: controller.clearHistory,
            tooltip: '清除聊天记录',
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showMoreOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('正在初始化聊天...')
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.all(16),
                itemCount: controller.messages.length + (controller.isSending.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < controller.messages.length) {
                    final message = controller.messages[index];
                    return _buildMessageBubble(message);
                  } else {
                    // 显示"正在输入"指示器
                    return _buildTypingIndicator();
                  }
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromMe 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: message.isError 
                  ? Colors.red.shade100 
                  : Colors.blue.shade100,
              child: Text(
                message.isError ? '❌' : '🤖',
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isFromMe 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isFromMe 
                        ? Colors.blue.shade600 
                        : message.isError 
                            ? Colors.red.shade50
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: message.isError 
                        ? Border.all(color: Colors.red.shade300)
                        : null,
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: message.isFromMe 
                          ? Colors.white 
                          : message.isError 
                              ? Colors.red.shade700
                              : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  controller.formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (message.isFromMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade100,
              child: Text(
                '😊',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              '🤖',
              style: TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'AI 正在思考...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => TextField(
              controller: controller.messageController,
              enabled: !controller.isSending.value,
              decoration: InputDecoration(
                hintText: controller.isSending.value 
                    ? '请等待 AI 回复...' 
                    : '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.blue.shade600),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => controller.sendMessage(),
              textInputAction: TextInputAction.send,
            )),
          ),
          SizedBox(width: 8),
          Obx(() => FloatingActionButton(
            onPressed: controller.isSending.value ? null : controller.sendMessage,
            backgroundColor: controller.isSending.value 
                ? Colors.grey.shade400 
                : Colors.blue.shade600,
            mini: true,
            child: controller.isSending.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.send, color: Colors.white),
          )),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '更多选项',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.network_check, color: Colors.blue),
              title: Text('网络诊断'),
              subtitle: Text('检查网络连接和 API 状态'),
              onTap: () {
                Get.back();
                _showNetworkDiagnostics();
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('关于 AI 助手'),
              onTap: () {
                Get.back();
                _showAboutDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('API 配置'),
              onTap: () {
                Get.back();
                _showApiConfigDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.clear_all, color: Colors.red),
              title: Text('清除聊天记录', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                controller.clearHistory();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('关于 AI 助手'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('这是一个基于 OpenAI GPT-3.5-turbo 模型的智能聊天助手。'),
            SizedBox(height: 10),
            Text('功能特性：'),
            Text('• 智能对话'),
            Text('• 上下文记忆'),
            Text('• 中文支持'),
            Text('• 错误处理'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showApiConfigDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('API 配置说明'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('要使用 AI 聊天功能，请按以下步骤配置：'),
            SizedBox(height: 10),
            Text('1. 访问 https://platform.openai.com/api-keys'),
            Text('2. 创建新的 API 密钥'),
            Text('3. 在 lib/config/openai_config.dart 中替换 API 密钥'),
            Text('4. 重新启动应用'),
            SizedBox(height: 10),
            Text('注意：API 调用需要消耗 OpenAI 账户余额。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showNetworkDiagnostics() async {
    // 显示加载对话框
    Get.dialog(
      AlertDialog(
        title: Text('网络诊断'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在检查网络连接...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // 测试网络连接
      final isConnected = await OpenAIService.testConnection();
      final status = await OpenAIService.getNetworkStatus();
      
      // 关闭加载对话框
      Get.back();
      
      // 显示诊断结果
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(
                isConnected ? Icons.check_circle : Icons.error,
                color: isConnected ? Colors.green : Colors.red,
              ),
              SizedBox(width: 8),
              Text('网络诊断结果'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('状态: $status'),
              SizedBox(height: 10),
              if (isConnected) ...[
                Text('✅ 网络连接正常'),
                Text('✅ 可以访问 OpenAI API'),
                Text('✅ API 密钥有效'),
              ] else ...[
                Text('❌ 网络连接异常'),
                SizedBox(height: 10),
                Text('可能的解决方案:'),
                Text('• 检查网络连接'),
                Text('• 验证 API 密钥'),
                Text('• 使用 VPN (中国大陆用户)'),
                Text('• 检查防火墙设置'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('确定'),
            ),
            if (!isConnected)
              TextButton(
                onPressed: () {
                  Get.back();
                  _showApiConfigDialog();
                },
                child: Text('配置 API'),
              ),
          ],
        ),
      );
    } catch (e) {
      // 关闭加载对话框
      Get.back();
      
      // 显示错误信息
      Get.dialog(
        AlertDialog(
          title: Text('诊断失败'),
          content: Text('网络诊断过程中出现错误:\n${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }
} 