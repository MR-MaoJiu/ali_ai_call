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
  }) {
    _onCallBegin = onCallBegin;
    _onCallEnd = onCallEnd;
    _onError = onError;
    _onAIResponse = onAIResponse;
    _onUserSpeaking = onUserSpeaking;
    _onNetworkQuality = onNetworkQuality;
    _onVideoSizeChanged = onVideoSizeChanged;
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
      }
    });
  }

  static Future<void> interruptSpeaking() async {
    await _channel.invokeMethod('interruptSpeaking');
  }

  static Future<void> enableVoiceInterrupt(bool enable) async {
    await _channel.invokeMethod('enableVoiceInterrupt', {'enable': enable});
  }

  static Future<void> switchRobotVoice(String voiceId) async {
    await _channel.invokeMethod('switchRobotVoice', {'voiceId': voiceId});
  }
}
