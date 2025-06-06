import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var usernameError = ''.obs;
  var passwordError = ''.obs;

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

    // 模拟登录请求
    await Future.delayed(Duration(seconds: 2));

    // 模拟登录成功
    if (username == 'admin' && password == '123456') {
      Get.offAllNamed(AppRoutes.CHAT_LIST);
    } else {
      Get.snackbar('登录失败', '用户名或密码错误');
    }

    isLoading.value = false;
  }
} 