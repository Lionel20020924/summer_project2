# 基于 GetX 的 AI 聊天应用

这是一个使用 Flutter 和 GetX 状态管理框架构建的智能聊天应用，集成了 OpenAI GPT-3.5-turbo 模型。

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── config/                   # 配置文件
│   └── openai_config.dart    # OpenAI API 配置
├── services/                 # 服务层
│   └── openai_service.dart   # OpenAI API 服务
├── routes/                   # 路由配置
│   ├── app_routes.dart       # 路由常量
│   └── app_pages.dart        # 页面路由配置
└── modules/                  # 功能模块
    ├── login/               # 登录模块
    │   ├── bindings/        # 依赖注入
    │   │   └── login_binding.dart
    │   ├── controllers/     # 控制器
    │   │   └── login_controller.dart
    │   └── views/          # 视图
    │       └── login_view.dart
    ├── chat_list/          # 聊天列表模块
    │   ├── bindings/
    │   │   └── chat_list_binding.dart
    │   ├── controllers/
    │   │   └── chat_list_controller.dart
    │   └── views/
    │       └── chat_list_view.dart
    └── chat/               # AI 聊天模块
        ├── bindings/
        │   └── chat_binding.dart
        ├── controllers/
        │   └── chat_controller.dart
        └── views/
            └── chat_view.dart
```

## 功能特性

### 登录模块 (`lib/modules/login/`)
- 用户名和密码验证
- 登录状态管理
- 错误提示和加载状态
- 演示账号：用户名 `admin`，密码 `123456`

### 聊天列表模块 (`lib/modules/chat_list/`)
- 显示聊天列表
- 未读消息数量显示
- 点击进入 AI 聊天
- 退出登录功能

### AI 聊天模块 (`lib/modules/chat/`)
- **真实 AI 对话**：集成 OpenAI GPT-3.5-turbo 模型
- **上下文记忆**：AI 能记住对话历史
- **智能回复**：支持中文对话和多种话题
- **发送状态显示**：实时显示消息发送状态
- **错误处理**：完善的错误提示和重试机制
- **消息气泡界面**：美观的聊天界面
- **自动滚动**：新消息自动滚动到最新位置
- **清除记录**：支持清除聊天历史和 AI 记忆

## 技术栈

- **Flutter**: 跨平台移动应用开发框架
- **GetX**: 状态管理、路由管理和依赖注入
- **OpenAI API**: GPT-3.5-turbo 模型提供 AI 聊天能力
- **dart_openai**: OpenAI API 的 Dart SDK
- **Material Design**: UI 设计风格

## OpenAI API 配置

### 1. 获取 API 密钥
访问 [OpenAI API Keys](https://platform.openai.com/api-keys) 页面：
1. 登录或注册 OpenAI 账户
2. 点击 "Create new secret key"
3. 复制生成的 API 密钥

### 2. 配置项目
编辑 `lib/config/openai_config.dart` 文件：
```dart
static const String apiKey = 'sk-your-actual-api-key-here';
```

### 3. 注意事项
- API 调用会消耗 OpenAI 账户余额
- 请妥善保管您的 API 密钥
- 不要将 API 密钥提交到公共代码仓库

## 运行项目

1. 确保已安装 Flutter SDK
2. 配置 OpenAI API 密钥（见上方配置说明）
3. 获取依赖：
   ```bash
   flutter pub get
   ```
4. 运行项目：
   ```bash
   flutter run
   ```

## AI 聊天功能

### 支持的功能
- ✅ 智能对话（中文/英文）
- ✅ 上下文记忆（保留最近10轮对话）
- ✅ 多话题支持
- ✅ 错误处理和重试
- ✅ 发送状态指示
- ✅ 清除聊天记录

### API 错误处理
应用会自动处理以下常见错误：
- `401 Unauthorized`: API 密钥无效
- `429 Too Many Requests`: 请求过于频繁
- `insufficient_quota`: 账户余额不足
- 网络连接错误

### 使用提示
1. 首次使用前请确保已正确配置 API 密钥
2. 对话会消耗 API 配额，建议适度使用
3. AI 会记住对话历史，提供更连贯的回复
4. 可以随时清除聊天记录重新开始

## GetX 架构说明

本项目采用 GetX 推荐的模块化架构：

- **Controllers**: 业务逻辑和状态管理
- **Views**: UI 界面展示
- **Bindings**: 依赖注入配置
- **Routes**: 路由配置和页面管理
- **Services**: API 调用和业务服务
- **Config**: 应用配置管理

每个功能模块都独立管理，便于维护和扩展。

## 依赖包

主要依赖：
- `get: ^4.6.6` - 状态管理和路由
- `dart_openai: ^5.1.0` - OpenAI API SDK
- `cupertino_icons: ^1.0.8` - iOS 风格图标

## 开发说明

### 扩展 AI 功能
可以在 `OpenAIService` 中添加更多 OpenAI 功能：
- 图像生成 (DALL-E)
- 语音转文字 (Whisper)
- 文本嵌入 (Embeddings)
- 微调模型 (Fine-tuning)

### 自定义 AI 行为
在 `OpenAIService.sendMessage()` 中修改系统消息来改变 AI 的行为和风格。
