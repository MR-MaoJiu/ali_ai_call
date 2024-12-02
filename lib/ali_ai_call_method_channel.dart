import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'ali_ai_call_platform_interface.dart';

/// 通过 MethodChannel 实现的阿里云 AI 通话插件
/// 负责与原生平台进行通信
class MethodChannelAliAiCall extends AliAiCallPlatform {
  /// 用于与原生平台通信的方法通道
  @visibleForTesting
  final methodChannel = const MethodChannel('ali_ai_call');

  // 回调函数定义
  /// 通话开始回调
  void Function()? _onCallBegin;

  /// 通话结束回调
  void Function()? _onCallEnd;

  /// 错误回调，参数为错误信息
  void Function(String)? _onError;

  /// AI响应回调，参数为响应内容
  void Function(String)? _onAIResponse;

  /// 用户说话状态回调，true表示正在说话
  void Function(bool)? _onUserSpeaking;

  /// 网络质量回调，参数为质量等级(0-6)
  void Function(int)? _onNetworkQuality;

  /// 视频尺寸变化回调，包含宽高信息
  void Function(Map<String, int>)? _onVideoSizeChanged;

  /// 声音ID变化回调
  void Function(String)? _onVoiceIdChanged;

  /// 角色变化回调
  void Function(String)? _onRoleChanged;

  /// AI代理状态变化回调
  void Function(String)? _onAIAgentStateChanged;

  /// AI代理ASR消息回调，语音识别结果
  void Function(Map<String, dynamic>)? _onAIAgentASRMessage;

  /// AI代理TTS消息回调，语音合成信息
  void Function(Map<String, dynamic>)? _onAIAgentTTSMessage;

  /// 音量变化回调，包含音量大小信息
  void Function(Map<String, dynamic>)? _onVolumeChanged;

  /// 用户ASR字幕通知回调
  void Function(Map<String, dynamic>)? _onUserAsrSubtitleNotify;

  @override
  Future<void> initEngine({required String userId}) async {
    await methodChannel.invokeMethod('initEngine', {'userId': userId});
    _setupMethodCallHandler();
  }

  @override
  Future<void> call({
    required String rtcToken,
    required String aiAgentInstanceId,
    required String aiAgentUserId,
    required String channelId,
  }) async {
    await methodChannel.invokeMethod('call', {
      'rtcToken': rtcToken,
      'aiAgentInstanceId': aiAgentInstanceId,
      'aiAgentUserId': aiAgentUserId,
      'channelId': channelId,
    });
  }

  @override
  Future<void> hangup() async {
    await methodChannel.invokeMethod('hangup');
  }

  @override
  Future<void> switchMicrophone(bool on) async {
    await methodChannel.invokeMethod('switchMicrophone', {'on': on});
  }

  @override
  Future<void> enableSpeaker(bool enable) async {
    await methodChannel.invokeMethod('enableSpeaker', {'enable': enable});
  }

  @override
  Future<void> interruptSpeaking() async {
    await methodChannel.invokeMethod('interruptSpeaking');
  }

  @override
  Future<void> enableVoiceInterrupt(bool enable) async {
    await methodChannel
        .invokeMethod('enableVoiceInterrupt', {'enable': enable});
  }

  @override
  Future<void> switchRobotVoice(String voiceId) async {
    await methodChannel.invokeMethod('switchRobotVoice', {'voiceId': voiceId});
  }

  @override
  Future<void> setAIRole(String roleId, String roleName) async {
    await methodChannel.invokeMethod('setAIRole', {
      'roleId': roleId,
      'roleName': roleName,
    });
  }

  /// 设置引擎回调函数
  /// 用于接收来自原生平台的各种事件通知
  void setEngineCallback({
    void Function()? onCallBegin,
    void Function()? onCallEnd,
    void Function(String)? onError,
    void Function(String)? onAIResponse,
    void Function(bool)? onUserSpeaking,
    void Function(int)? onNetworkQuality,
    void Function(Map<String, int>)? onVideoSizeChanged,
    void Function(String)? onVoiceIdChanged,
    void Function(String)? onRoleChanged,
    void Function(String)? onAIAgentStateChanged,
    void Function(Map<String, dynamic>)? onAIAgentASRMessage,
    void Function(Map<String, dynamic>)? onAIAgentTTSMessage,
    void Function(Map<String, dynamic>)? onVolumeChanged,
    void Function(Map<String, dynamic>)? onUserAsrSubtitleNotify,
  }) {
    _onCallBegin = onCallBegin;
    _onCallEnd = onCallEnd;
    _onError = onError;
    _onAIResponse = onAIResponse;
    _onUserSpeaking = onUserSpeaking;
    _onNetworkQuality = onNetworkQuality;
    _onVideoSizeChanged = onVideoSizeChanged;
    _onVoiceIdChanged = onVoiceIdChanged;
    _onRoleChanged = onRoleChanged;
    _onAIAgentStateChanged = onAIAgentStateChanged;
    _onAIAgentASRMessage = onAIAgentASRMessage;
    _onAIAgentTTSMessage = onAIAgentTTSMessage;
    _onVolumeChanged = onVolumeChanged;
    _onUserAsrSubtitleNotify = onUserAsrSubtitleNotify;
  }

  /// 设置方法通道回调处理器
  /// 处理来自原生平台的所有方法调用
  void _setupMethodCallHandler() {
    methodChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onCallBegin':
          _onCallBegin?.call();
          break;
        case 'onCallEnd':
          _onCallEnd?.call();
          break;
        case 'onError':
          _onError?.call(call.arguments as String);
          break;
        case 'onAIResponse':
          _onAIResponse?.call(call.arguments as String);
          break;
        case 'onUserSpeaking':
          _onUserSpeaking?.call(call.arguments as bool);
          break;
        case 'onNetworkQuality':
          _onNetworkQuality?.call(call.arguments as int);
          break;
        case 'onVideoSizeChanged':
          _onVideoSizeChanged
              ?.call(Map<String, int>.from(call.arguments as Map));
          break;
        case 'onVoiceIdChanged':
          _onVoiceIdChanged?.call(call.arguments as String);
          break;
        case 'onRoleChanged':
          _onRoleChanged?.call(call.arguments as String);
          break;
        case 'onAIAgentStateChanged':
          _onAIAgentStateChanged?.call(call.arguments as String);
          break;
        case 'onAIAgentASRMessage':
          _onAIAgentASRMessage
              ?.call(Map<String, dynamic>.from(call.arguments as Map));
          break;
        case 'onAIAgentTTSMessage':
          _onAIAgentTTSMessage
              ?.call(Map<String, dynamic>.from(call.arguments as Map));
          break;
        case 'onVolumeChanged':
          _onVolumeChanged
              ?.call(Map<String, dynamic>.from(call.arguments as Map));
          break;
        case 'onUserAsrSubtitleNotify':
          _onUserAsrSubtitleNotify
              ?.call(Map<String, dynamic>.from(call.arguments as Map));
          break;
      }
    });
  }
}
