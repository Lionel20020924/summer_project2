import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'config/openai_config.dart';
import 'services/openai_service.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 应用启动中...');
  
  // 初始化环境配置（异步）
  await OpenAIConfig.initialize();
  
  // 初始化 OpenAI 服务
  OpenAIService.initialize();
  
  print('🎉 应用初始化完成');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.LOGIN,
      getPages: AppPages.routes,
    );
  }
}
