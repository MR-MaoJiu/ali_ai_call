## 1.0.5

- iOS 侧对齐官方最新 SDK 文档（call[1/2] 服务端托管模式）
- 修复 iOS `ARTCAICallAgentInfo.agentId` 传值错误（原用 instanceId 充当 agentId）
- 修复 iOS `call(userId:)` 传入了智能体 UID 而非当前用户 ID
- 修复 iOS `onErrorOccurs` 回调向 Dart 发送 Int 而 Dart 侧期望 String 的类型不匹配
- 修复 iOS `onAgentStateChanged` 回调向 Dart 发送 Int 而 Dart 侧期望 String 的类型不匹配
- 新增 iOS `onNetworkStatusChanged` 回调实现（原缺失），与 Android 侧网络质量回调对齐
- iOS `onUserSubtitleNotify` 补充 `voicePrintStatus` 字段（固定返回 `disable`）防止 Dart 侧 cast 崩溃
- Dart `call()` 接口新增可选参数 `aiAgentId`（智能体模板 ID）和 `userId`（当前用户 ID）
- Example `chat_screen.dart` 发起通话时透传 `aiAgentId` 与 `userId`
- podspec 版本号同步更新至 1.0.5

## 1.0.4

- 升级 Android 侧 AliVCSDK_ARTC 至 `7.10.0`、ARTCAICallKit 至 `2.11.0`
- 升级 iOS 侧 AliVCSDK_ARTC 至 `7.10.0`、ARTCAICallKit 至 `2.11.0`
- Dart 层新增多种回调：智能体音视频可用状态、数字人首帧渲染、语音打断状态、用户上线等
- 修复 `onAIAgentStateChanged` 回调事件名与原生实现不一致的问题
- 修复 Server/Java 中部分类包名错误，保持与官方 AUIAICall Server/Java 最新版本对齐

## 1.0.0

- 初始公开版本发布
- 支持基础语音通话能力
- 支持实时语音识别（ASR）与语音合成（TTS）
- 支持音量监控、麦克风与扬声器控制
- 支持语音打断、多角色、多音色等基础 AI 能力
