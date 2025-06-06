# 基于 GetX 的聊天应用

这是一个使用 Flutter 和 GetX 状态管理框架构建的简单聊天应用。

## 项目结构

```
lib/
├── main.dart                 # 应用入口
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
    └── chat/               # 聊天模块
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
- 点击进入具体聊天
- 退出登录功能

### 聊天模块 (`lib/modules/chat/`)
- 消息收发功能
- 消息气泡界面
- 自动滚动到最新消息
- 模拟对方自动回复

## 技术栈

- **Flutter**: 跨平台移动应用开发框架
- **GetX**: 状态管理、路由管理和依赖注入
- **Material Design**: UI 设计风格

## 运行项目

1. 确保已安装 Flutter SDK
2. 获取依赖：
   ```bash
   flutter pub get
   ```
3. 运行项目：
   ```bash
   flutter run
   ```

## GetX 架构说明

本项目采用 GetX 推荐的模块化架构：

- **Controllers**: 业务逻辑和状态管理
- **Views**: UI 界面展示
- **Bindings**: 依赖注入配置
- **Routes**: 路由配置和页面管理

每个功能模块都独立管理，便于维护和扩展。
