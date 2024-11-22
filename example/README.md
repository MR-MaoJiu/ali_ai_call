# ali_ai_call_example

这是ali_ai_call插件的示例应用。

## 项目结构

example/lib/
  ├── main.dart              # 应用入口
  ├── models/                # 数据模型
  │   └── message.dart       # 消息模型
  ├── screens/               # 页面
  │   └── chat_screen.dart   # 聊天主界面
  ├── services/              # 服务
  │   └── ai_service.dart    # AI服务接口
  └── widgets/               # 组件
      └── message_bubble.dart # 消息气泡组件

## 使用说明

1. 确保已安装所有依赖：
   ```bash
   flutter pub get
   ```

2. 运行示例：
   ```bash
   flutter run
   ```
