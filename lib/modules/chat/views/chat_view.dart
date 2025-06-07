import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../controllers/chat_controller.dart';
import '../../../services/openai_service.dart';

class ChatView extends GetView<ChatController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF3C1053),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 背景动画圆圈
            _buildAnimatedBackgroundCircles(),
            // 主要内容
            SafeArea(
              child: Column(
                children: [
                  _buildModernAppBar(),
                  Expanded(
                    child: _buildMessageArea(),
                  ),
                  _buildModernMessageInput(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackgroundCircles() {
    return Stack(
      children: [
        // 左上角大圆
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // 右下角中圆
        Positioned(
          bottom: -80,
          right: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.purple.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // 中间小圆
        Positioned(
          top: 250,
          right: -40,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernAppBar() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // 返回按钮
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.15),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Get.back();
                  },
                ),
              ),
              SizedBox(width: 16),
              
              // AI助手头像和信息
              Obx(() => Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.withOpacity(0.8),
                              Colors.purple.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            controller.currentChat.value?.avatar ?? '🤖',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      // 在线状态指示器
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentChat.value?.name ?? 'AI 助手',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'GPT-3.5 智能助手',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )),
              
              Spacer(),
              
              // 清除聊天记录按钮
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.15),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.clear_all_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    controller.clearHistory();
                  },
                  tooltip: '清除聊天记录',
                ),
              ),
              SizedBox(width: 8),
              
              // 更多选项按钮
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.15),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showMoreOptions();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageArea() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.8),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '正在初始化聊天...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: controller.messages.length + (controller.isSending.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < controller.messages.length) {
            final message = controller.messages[index];
            return _buildModernMessageBubble(message);
          } else {
            return _buildModernTypingIndicator();
          }
        },
      );
    });
  }

  Widget _buildModernMessageBubble(Message message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromMe 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromMe) ...[
            _buildModernAvatar(message),
            SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isFromMe 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: message.isFromMe 
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                ],
                              )
                            : message.isError 
                                ? LinearGradient(
                                    colors: [
                                      Colors.red.withOpacity(0.2),
                                      Colors.red.withOpacity(0.1),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.15),
                                    ],
                                  ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: message.isError 
                              ? Colors.red.withOpacity(0.4)
                              : Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: message.isFromMe
                                ? Color(0xFF667eea).withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(
                              color: message.isFromMe 
                                  ? Colors.white 
                                  : message.isError 
                                      ? Colors.red.shade300
                                      : Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          // 添加语音播放按钮（仅对AI回复显示）
                          if (!message.isFromMe && !message.isError) ...[
                            SizedBox(height: 12),
                            _buildAudioControls(message),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  controller.formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (message.isFromMe) ...[
            SizedBox(width: 12),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildModernAvatar(Message message) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: message.isError 
              ? [Colors.red.withOpacity(0.8), Colors.red.withOpacity(0.6)]
              : [Colors.blue.withOpacity(0.8), Colors.purple.withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: message.isError 
                ? Colors.red.withOpacity(0.3)
                : Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message.isError ? '❌' : '🤖',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.8),
            Colors.teal.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '😊',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildModernTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildModernAvatar(Message(
            id: 'typing',
            content: '',
            isFromMe: false,
            timestamp: DateTime.now(),
          )),
          SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'AI 正在思考...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMessageInput() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    enabled: !controller.isSending.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: controller.isSending.value 
                          ? '请等待 AI 回复...' 
                          : '输入消息...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20, 
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) => controller.sendMessage(),
                    textInputAction: TextInputAction.send,
                  ),
                )),
              ),
              SizedBox(width: 16),
              Obx(() => Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: controller.isSending.value
                      ? LinearGradient(
                          colors: [
                            Colors.grey.withOpacity(0.6),
                            Colors.grey.withOpacity(0.4),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6B6B),
                            Color(0xFFFF8E53),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    if (!controller.isSending.value)
                      BoxShadow(
                        color: Color(0xFFFF6B6B).withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: controller.isSending.value 
                        ? null 
                        : () {
                            HapticFeedback.mediumImpact();
                            controller.sendMessage();
                          },
                    borderRadius: BorderRadius.circular(18),
                    child: Center(
                      child: controller.isSending.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.2),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '更多选项',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 24),
                _buildModernOptionTile(
                  icon: Icons.network_check_rounded,
                  title: '网络诊断',
                  subtitle: '检查网络连接和 API 状态',
                  onTap: () {
                    Get.back();
                    _showNetworkDiagnostics();
                  },
                ),
                _buildModernOptionTile(
                  icon: Icons.info_outline_rounded,
                  title: '关于 AI 助手',
                  subtitle: '了解更多功能特性',
                  onTap: () {
                    Get.back();
                    _showAboutDialog();
                  },
                ),
                _buildModernOptionTile(
                  icon: Icons.settings_rounded,
                  title: 'API 配置',
                  subtitle: '配置API接口设置',
                  onTap: () {
                    Get.back();
                    _showApiConfigDialog();
                  },
                ),
                _buildModernOptionTile(
                  icon: Icons.record_voice_over_rounded,
                  title: 'ElevenLabs 配置',
                  subtitle: '语音服务配置和测试',
                  onTap: () {
                    Get.back();
                    _showElevenLabsConfigDialog();
                  },
                ),
                // 🎵 新增自动语音播放切换选项
                Obx(() => _buildModernOptionTile(
                  icon: controller.autoPlayVoice.value 
                      ? Icons.volume_up_rounded 
                      : Icons.volume_off_rounded,
                  title: controller.autoPlayVoiceStatusText,
                  subtitle: controller.autoPlayVoice.value 
                      ? 'AI回复将自动播放语音' 
                      : '点击切换开启自动语音播放',
                  onTap: () {
                    controller.toggleAutoPlayVoice();
                  },
                )),
                _buildModernOptionTile(
                  icon: Icons.clear_all_rounded,
                  title: '清除聊天记录',
                  subtitle: '删除所有对话历史',
                  isDestructive: true,
                  onTap: () {
                    Get.back();
                    controller.clearHistory();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDestructive
                  ? [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.2)]
                  : [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive 
                ? Colors.red.shade300 
                : Colors.white.withOpacity(0.9),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive 
                ? Colors.red.shade300 
                : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '关于 AI 助手',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '这是一个基于 OpenAI GPT-3.5-turbo 模型的智能聊天助手。',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '功能特性：',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• 智能对话', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                      Text('• 上下文记忆', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                      Text('• 中文支持', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                      Text('• 错误处理', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '确定',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showApiConfigDialog() {
    Get.dialog(
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'API 配置说明',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '要使用 AI 聊天功能，请按以下步骤配置：',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('1. 访问 https://platform.openai.com/api-keys', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  Text('2. 创建新的 API 密钥', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  Text('3. 在 lib/config/openai_config.dart 中替换 API 密钥', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  Text('4. 重新启动应用', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  SizedBox(height: 12),
                  Text(
                    '注意：API 调用需要消耗 OpenAI 账户余额。',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '确定',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showElevenLabsConfigDialog() {
    Get.dialog(
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'ElevenLabs 语音配置',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '语音合成服务状态：',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• API Key: 未配置 ❌', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontFamily: 'monospace')),
                        Text('• Voice ID: pNInz6obpgDQGcFmaJgB (Adam)', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontFamily: 'monospace')),
                        Text('• Model: eleven_multilingual_v2', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontFamily: 'monospace')),
                        Text('• 多语言支持: 中文/英文 ✅', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '配置步骤：',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('1. 访问 https://elevenlabs.io/ 注册账户', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  Text('2. 在个人资料页面获取 API Key', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  Text('3. 在项目根目录的 .env 文件中设置：', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ELEVENLABS_API_KEY=your_actual_api_key_here',
                      style: TextStyle(
                        color: Colors.green.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('4. 重新启动应用', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  SizedBox(height: 16),
                  Text(
                    '💡 免费用户每月有 10,000 字符的免费额度',
                    style: TextStyle(
                      color: Colors.yellow.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          // 这里可以添加测试TTS功能
                          Get.snackbar('测试', '🎵 测试TTS功能...');
                          // await controller.generateAndPlayAudio('test', '这是一个语音测试。');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('测试语音', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('确定', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNetworkDiagnostics() async {
    // 显示现代化加载对话框
    Get.dialog(
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '网络诊断',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '正在检查网络连接...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      
      // 显示现代化诊断结果
      Get.dialog(
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isConnected ? Icons.check_circle : Icons.error,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '网络诊断结果',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('状态: $status', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                    SizedBox(height: 10),
                    if (isConnected) ...[
                      Text('✅ 网络连接正常', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      Text('✅ 可以访问 OpenAI API', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      Text('✅ API 密钥有效', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    ] else ...[
                      Text('❌ 网络连接异常', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      SizedBox(height: 10),
                      Text('可能的解决方案:', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                      Text('• 检查网络连接', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      Text('• 验证 API 密钥', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      Text('• 使用 VPN (中国大陆用户)', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      Text('• 检查防火墙设置', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    ],
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isConnected)
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              _showApiConfigDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('配置 API', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('确定', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      // 关闭加载对话框
      Get.back();
      
      // 显示现代化错误信息
      Get.dialog(
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      '诊断失败',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '网络诊断过程中出现错误:\n${e.toString()}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        '确定',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  /// 构建音频控制按钮
  Widget _buildAudioControls(Message message) {
    return Obx(() {
      final audioService = controller.audioService;
      final isGenerating = controller.audioGeneratingMessageIds.contains(message.id);
      final isPlaying = audioService.isPlayingMessage(message.id);
      final isPaused = audioService.isPausedMessage(message.id);
      
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 播放/暂停按钮
            GestureDetector(
              onTap: isGenerating ? null : () {
                controller.toggleAudioPlayback(message.id, message.audioFilePath);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isGenerating 
                        ? [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.3)]
                        : [Colors.blue.withOpacity(0.7), Colors.purple.withOpacity(0.5)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: isGenerating
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          isPlaying 
                              ? Icons.pause_rounded 
                              : isPaused 
                                  ? Icons.play_arrow_rounded
                                  : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ),
            
            // 显示播放进度（如果正在播放）
            if (isPlaying || isPaused) ...[
              SizedBox(width: 8),
              Text(
                audioService.formatDuration(audioService.currentPosition.value),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              if (audioService.totalDuration.value.inSeconds > 0) ...[
                Text(
                  ' / ${audioService.formatDuration(audioService.totalDuration.value)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
            
            // 状态文本
            if (!isPlaying && !isPaused && !isGenerating) ...[
              SizedBox(width: 6),
              Text(
                message.audioFilePath != null ? '重播' : '语音',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else if (isGenerating) ...[
              SizedBox(width: 6),
              Text(
                '生成中...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
} 