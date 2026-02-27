## 1.0.1

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
