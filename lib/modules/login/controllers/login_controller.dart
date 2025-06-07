import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var usernameError = ''.obs;
  var passwordError = ''.obs;
  
  // 便捷测试账号
  final List<Map<String, String>> testAccounts = [
    {'username': 'admin', 'password': '123456', 'name': '管理员'},
    {'username': 'test', 'password': '123', 'name': '测试用户'},
    {'username': 'demo', 'password': '888', 'name': '演示账号'},
  ];
  
  // 文本控制器
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // 默认填充第一个测试账号
    fillTestAccount(0);
  }

  void login(String username, String password) async {
    // 重置错误信息
    usernameError.value = '';
    passwordError.value = '';

    // 验证输入
    if (username.isEmpty) {
      usernameError.value = '请输入用户名';
      return;
    }
    if (password.isEmpty) {
      passwordError.value = '请输入密码';
      return;
    }

    isLoading.value = true;

    // 模拟登录请求（缩短时间便于测试）
    await Future.delayed(Duration(milliseconds: 800));

    // 检查测试账号
    bool loginSuccess = false;
    for (var account in testAccounts) {
      if (username == account['username'] && password == account['password']) {
        loginSuccess = true;
        break;
      }
    }

    if (loginSuccess) {
      Get.snackbar(
        '登录成功', 
        '欢迎回来，$username！',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: Duration(seconds: 2),
      );
      // 延迟一下让用户看到成功消息
      await Future.delayed(Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.CHAT_LIST);
    } else {
      Get.snackbar(
        '登录失败', 
        '用户名或密码错误',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }

    isLoading.value = false;
  }
  
  /// 快速登录（跳过动画）
  void quickLogin() async {
    isLoading.value = true;
    
    // 使用默认管理员账号
    await Future.delayed(Duration(milliseconds: 300));
    
    Get.snackbar(
      '快速登录成功', 
      '已使用管理员账号登录',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
      duration: Duration(seconds: 1),
    );
    
    Get.offAllNamed(AppRoutes.CHAT_LIST);
    isLoading.value = false;
  }
  
  /// 填充测试账号
  void fillTestAccount(int index) {
    if (index < testAccounts.length) {
      usernameController.text = testAccounts[index]['username']!;
      passwordController.text = testAccounts[index]['password']!;
      // 清除错误信息
      usernameError.value = '';
      passwordError.value = '';
    }
  }
  
  /// 清空表单
  void clearForm() {
    usernameController.clear();
    passwordController.clear();
    usernameError.value = '';
    passwordError.value = '';
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
} 