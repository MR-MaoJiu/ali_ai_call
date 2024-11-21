# ali_ai_call

基于阿里云智能媒体服务的AI实时互动Flutter插件。

## 功能特性

- 支持语音、数字人、视觉理解等多种AI交互模式
- 提供实时语音通话能力
- 支持音频控制(麦克风开关、扬声器切换等)
- 支持视频预览和渲染
- 提供丰富的回调事件

## 使用要求

- Android:
  - minSdkVersion 21 (Android 5.0 或更高版本)
  - compileSdkVersion 34
  - 依赖阿里云 ARTC SDK 6.11.3
  - 依赖阿里云 ARTCAICallKit 1.2.0

## 安装

1. 添加依赖到 pubspec.yaml:


## API文档

### 初始化相关
- `initEngine(String userId)`: 初始化AI通话引擎
  - 参数:
    - userId: 用户ID
  - 返回: Future<void>

### 通话控制
- `call(String rtcToken, String aiAgentInstanceId, String aiAgentUserId, String channelId)`: 发起通话
  - 参数:
    - rtcToken: RTC令牌
    - aiAgentInstanceId: AI代理实例ID
    - aiAgentUserId: AI代理用户ID
    - channelId: 频道ID
  - 返回: Future<void>

- `hangup()`: 结束通话
  - 返回: Future<void>

### 音视频控制
- `switchMicrophone(bool on)`: 切换麦克风
  - 参数:
    - on: 是否开启
  - 返回: Future<void>

- `enableSpeaker(bool enable)`: 切换扬声器
  - 参数:
    - enable: 是否启用
  - 返回: Future<void>

- `setVolume(int volume)`: 设置音量
  - 参数:
    - volume: 音量值(0-100)
  - 返回: Future<void>

### AI交互
- `setAIRole(String roleId, String roleName)`: 设置AI角色
  - 参数:
    - roleId: 角色ID
    - roleName: 角色名称
  - 返回: Future<void>

- `interruptSpeaking()`: 打断AI当前说话
  - 返回: Future<void>

- `enableVoiceInterrupt(bool enable)`: 启用/禁用语音打断功能
  - 参数:
    - enable: 是否启用语音打断
  - 返回: Future<void>

- `switchRobotVoice(String voiceId)`: 切换AI声音
  - 参数:
    - voiceId: 声音ID
  - 返回: Future<void>

### 视频相关
- `setVideoView(int viewId)`: 设置视频预览视图
  - 参数:
    - viewId: 视图ID
  - 返回: Future<void>

### 回调事件
- `onCallBegin`: 通话开始
- `onCallEnd`: 通话结束
- `onError`: 错误发生
- `onUserSpeaking`: 用户说话状态
- `onAIResponse`: AI响应
- `onNetworkQuality`: 网络质量
- `onVideoSizeChanged`: 视频尺寸变化

## 示例代码

### 基础用法

