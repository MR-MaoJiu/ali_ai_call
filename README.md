# Ali AI Call Plugin

阿里云智能对话插件的Flutter实现,支持iOS和Android平台。

## 功能特性

- 语音通话
- 实时语音转文字(ASR)
- 文字转语音(TTS)
- 音量监控
- 网络质量监控
- 麦克风/扬声器控制
- AI语音打断
- 多角色支持
- 多音色支持

## 环境要求

- Flutter: >=2.0.0
- iOS: >= 12.0
- Android: minSdkVersion 19

## 安装

1. 添加依赖到 `pubspec.yaml`:

```yaml
dependencies:
  ali_ai_call: ^1.0.0
```

2. iOS 配置:

在 `ios/Runner/Info.plist` 添加以下权限:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>需要访问麦克风进行语音通话</string>
<key>NSCameraUsageDescription</key>
<string>需要访问相机进行视频通话</string>
```

确保在 `Podfile` 中设置正确的iOS版本和源:

```ruby
platform :ios, '12.0'

source 'https://github.com/aliyun/aliyun-specs.git'
source 'https://cdn.cocoapods.org/'
```

3. Android 配置:

在 `android/app/src/main/AndroidManifest.xml` 添加权限:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
```

## 使用方法

### 初始化

```dart
await AiCallKit.initEngine(userId: "your_user_id");
```

### 设置回调

```dart
AiCallKit.setEngineCallback(
  onCallBegin: () {
    print('通话开始');
  },
  onCallEnd: () {
    print('通话结束');
  },
  onError: (error) {
    print('发生错误: $error');
  },
  onUserAsrSubtitleNotify: (Map<String, dynamic> data) {
    // 用户语音识别结果
    String text = data['text'];
    bool isSentenceEnd = data['isSentenceEnd'];
    int sentenceId = data['sentenceId'];
    print('用户语音识别: $text');
  },
  onAIAgentTTSMessage: (Map<String, dynamic> data) {
    // AI回复文本
    String text = data['text'];
    bool isSentenceEnd = data['isSentenceEnd'];
    int userAsrSentenceId = data['userAsrSentenceId'];
    print('AI回复: $text');
  },
  onVolumeChanged: (Map<String, dynamic> data) {
    // 音量变化
    String uid = data['uid'];
    int volume = data['volume'];
    print('音量变化: $volume');
  },
);
```

### 开始通话

```dart
await AiCallKit.call(
  rtcToken: "your_rtc_token",
  aiAgentInstanceId: "your_instance_id",
  aiAgentUserId: "your_agent_user_id",
  channelId: "your_channel_id",
);
```

### 结束通话

```dart
await AiCallKit.hangup();
```

### 音频控制

```dart
// 切换麦克风
await AiCallKit.switchMicrophone(true/false);

// 切换扬声器
await AiCallKit.enableSpeaker(true/false);

// 打断 AI 说话
await AiCallKit.interruptSpeaking();

// 启用语音打断
await AiCallKit.enableVoiceInterrupt(true/false);
```

### AI控制

```dart
// 切换 AI 音色
await AiCallKit.switchRobotVoice("voice_id");

// 设置 AI 角色
await AiCallKit.setAIRole("role_id", "role_name");
```

## 回调参数说明

### onUserAsrSubtitleNotify
| 参数 | 类型 | 说明 |
|-----|------|-----|
| text | String | 识别到的文本内容 |
| isSentenceEnd | bool | 是否是句子结束 |
| sentenceId | int | 句子ID |

### onAIAgentTTSMessage
| 参数 | 类型 | 说明 |
|-----|------|-----|
| text | String | AI回复的文本内容 |
| isSentenceEnd | bool | 是否是句子结束 |
| userAsrSentenceId | int | 对应的用户语音ID |

### onVolumeChanged
| 参数 | 类型 | 说明 |
|-----|------|-----|
| uid | String | 用户ID |
| volume | int | 音量大小(0-100) |

## 错误处理

插件会通过 `onError` 回调返回错误信息,建议在使用时做好错误处理:

```dart
onError: (error) {
  switch(error) {
    case "NETWORK_ERROR":
      // 处理网络错误
      break;
    case "PERMISSION_DENIED":
      // 处理权限错误
      break;
    // 处理其他错误...
  }
}
```

## 最佳实践

1. 初始化时机
   - 建议在应用启动时就完成初始化
   - 确保在调用其他方法前完成初始化

2. 资源释放
   - 在页面销毁时调用 hangup()
   - 注意清理回调避免内存泄漏

3. 错误处理
   - 对网络错误进行重试
   - 对权限错误给予用户提示
   - 记录错误日志便于问题排查

4. 性能优化
   - 避免频繁切换音色和角色
   - 合理使用语音打断功能
   - 注意控制录音文件大小

## 常见问题

1. Q: 初始化失败怎么办?
   A: 检查网络连接和参数配置是否正确

2. Q: 没有声音怎么办?
   A: 检查音量设置和权限是否正确

3. Q: 语音识别不准确怎么办?
   A: 建议在安静环境使用,说话清晰度也很重要

## 更新日志

### 1.0.0
- 初始版本发布
- 支持基础语音通话功能
- 支持语音识别和合成
- 支持音量控制和监控

## 问题反馈

如有问题请提交 [Issue](https://github.com/MR-MaoJiu/ali_ai_call/issues)

## License

MIT License
