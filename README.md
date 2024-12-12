# ali_ai_call

阿里云 AI 通话 Flutter 插件,支持实时语音对话、语音识别、声纹识别等功能。

## 功能特性

- AI 语音通话
- 声纹识别
- 实时语音识别(ASR)
- 语音合成(TTS) 
- 网络质量监控
- 麦克风/扬声器控制
- AI语音打断
- 多角色支持
- 多音色支持

## 环境要求

- Flutter: >=3.3.0
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
### 后端服务需要正常运行，可以在本项目中找到Server配置文件修改配置文件中的配置然后运行一下
### 初始化

```dart
await AliAiCall.initEngine(userId: "your_user_id");
```

### 设置回调

```dart
AliAiCall.setEngineEventHandler(
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
    VoicePrintStatusCode voicePrintStatus = data['voicePrintStatus'];
    
    switch (voicePrintStatus) {
      case VoicePrintStatusCode.speakerRecognized:
        print('说话人已识别');
        break;
      case VoicePrintStatusCode.speakerNotRecognized:
        print('说话人未识别');
        break;
      case VoicePrintStatusCode.disable:
        print('声纹识别已禁用');
        break;
      case VoicePrintStatusCode.enableWithoutRegister:
        print('声纹识别已启用但未注册');
        break;
      case VoicePrintStatusCode.unknown:
        print('未知状态');
        break;
    }
    
    print('用户语音识别: $text');
  },
  onAIAgentSubtitleNotify: (Map<String, dynamic> data) {
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
await AliAiCall.call(
  rtcToken: "your_rtc_token",
  aiAgentInstanceId: "your_instance_id",
  aiAgentUserId: "your_agent_user_id",
  channelId: "your_channel_id",
);
```

### 结束通话

```dart
await AliAiCall.hangup();
```

### 音频控制

```dart
// 切换麦克风
await AliAiCall.switchMicrophone(true/false);

// 切换扬声器
await AliAiCall.enableSpeaker(true/false);

// 打断 AI 说话
await AliAiCall.interruptSpeaking();

// 启用语音打断
await AliAiCall.enableVoiceInterrupt(true/false);
```

### AI控制

```dart
// 切换 AI 音色
await AliAiCall.switchRobotVoice("voice_id");

// 设置 AI 角色
await AliAiCall.setAIRole("role_id", "role_name");
```

## 回调参数说明

### onUserAsrSubtitleNotify
| 参数 | 类型 | 说明 |
|-----|------|-----|
| text | String | 识别到的文本内容 |
| isSentenceEnd | bool | 是否是句子结束 |
| sentenceId | int | 句子ID |
| voicePrintStatus | VoicePrintStatusCode | 声纹状态，可能的值: <br> - disable: 禁用 <br> - enableWithoutRegister: 启用但未注册 <br> - speakerRecognized: 说话人已识别 <br> - speakerNotRecognized: 说话人未识别 <br> - unknown: 未知状态 |

### onAIAgentSubtitleNotify
| 参数 | 类型 | 说明 |
|-----|------|-----|
| text | String | AI回复的文本内容 |
| isSentenceEnd | bool | 是否是句子结束 |
| userAsrSentenceId | int | 对应的用户语音ID |

### onVolumeChanged
| 参数 | 类型 | 说明 |
|-----|------|-----|
| uid | String | 用户ID |
| volume | int | 音量大小 |

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
   A: 建议在安静环境使用,说话清晰度也重要

4. Q: 遇到 "Multiple commands produce xxx-umbrella.h" 错误怎么办?
   A: 这是 Xcode 构建冲突导致的问题，解决步骤如下：
   - 修改 ios/Podfile，添加 `install! 'cocoapods', :disable_input_output_paths => true`
   - 在 post_install 中添加 `config.build_settings['DEFINES_MODULE'] = 'YES'`
   - 执行清理和重装：
     ```bash
     cd ios
     pod deintegrate
     pod cache clean --all
     pod install
     ```

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

## 开源不易觉得好用给个Star或者赞助一下

![img.png](./document/img.png)
