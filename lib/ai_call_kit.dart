import 'dart:async';
import 'package:flutter/services.dart';

class AiCallKit {
  static const MethodChannel _channel = MethodChannel('ali_ai_call');

  // 回调函数类型定义
  static void Function()? _onCallBegin;
  static void Function()? _onCallEnd;
  static void Function(String)? _onError;
  static void Function(String)? _onAIResponse;
  static void Function(bool)? _onUserSpeaking;
  static void Function(int)? _onNetworkQuality;
  static void Function(Map<String, int>)? _onVideoSizeChanged;
  static void Function(String)? _onVoiceIdChanged;
  static void Function(String)? _onRoleChanged;
  static void Function(String)? _onAIAgentStateChanged;
  static void Function(Map<String, dynamic>)? _onAIAgentASRMessage;
  static void Function(Map<String, dynamic>)? _onAIAgentTTSMessage;
  static void Function(Map<String, dynamic>)? _onVolumeChanged;
  static void Function(Map<String, dynamic>)? _onUserAsrSubtitleNotify;

  // 初始化引擎
  static Future<void> initEngine({required String userId}) async {
    await _channel.invokeMethod('initEngine', {'userId': userId});
    _setupMethodCallHandler();
  }

  // 设置回调
  static void setEngineCallback({
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

  // 开始通话
  static Future<void> call({
    required String rtcToken,
    required String aiAgentInstanceId,
    required String aiAgentUserId,
    required String channelId,
  }) async {
    await _channel.invokeMethod('call', {
      'rtcToken': rtcToken,
      'aiAgentInstanceId': aiAgentInstanceId,
      'aiAgentUserId': aiAgentUserId,
      'channelId': channelId,
    });
  }

  // 结束通话
  static Future<void> hangup() async {
    await _channel.invokeMethod('hangup');
  }

  // 切换麦克风
  static Future<void> switchMicrophone(bool on) async {
    await _channel.invokeMethod('switchMicrophone', {'on': on});
  }

  // 切换扬声器
  static Future<void> enableSpeaker(bool enable) async {
    await _channel.invokeMethod('enableSpeaker', {'enable': enable});
  }

  // 打断AI说话
  static Future<void> interruptSpeaking() async {
    await _channel.invokeMethod('interruptSpeaking');
  }

  // 启用/禁用语音打断
  static Future<void> enableVoiceInterrupt(bool enable) async {
    await _channel.invokeMethod('enableVoiceInterrupt', {'enable': enable});
  }

  // 切换AI声音
  static Future<void> switchRobotVoice(String voiceId) async {
    await _channel.invokeMethod('switchRobotVoice', {'voiceId': voiceId});
  }

  // 设置AI角色
  static Future<void> setAIRole(String roleId, String roleName) async {
    await _channel.invokeMethod('setAIRole', {
      'roleId': roleId,
      'roleName': roleName,
    });
  }

  // 设置方法调用处理器
  static void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
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
          _onAIAgentASRMessage?.call(Map<String, dynamic>.from(call.arguments));
          break;
        case 'onAIAgentTTSMessage':
          _onAIAgentTTSMessage?.call(Map<String, dynamic>.from(call.arguments));
          break;
        case 'onVolumeChanged':
          _onVolumeChanged?.call(Map<String, dynamic>.from(call.arguments));
          break;
        case 'onUserAsrSubtitleNotify':
          _onUserAsrSubtitleNotify
              ?.call(Map<String, dynamic>.from(call.arguments));
          break;
      }
    });
  }
}
