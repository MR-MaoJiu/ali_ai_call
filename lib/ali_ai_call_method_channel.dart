import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'ali_ai_call_platform_interface.dart';
import 'src/voice_print_status.dart';

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

  /// ���色变化回调
  void Function(String)? _onRoleChanged;

  /// AI代理状态变化回调
  void Function(String)? _onAIAgentStateChanged;

  /// 用户ASR字幕通知回调
  void Function(Map<String, dynamic>)? _onUserAsrSubtitleNotify;

  /// AI代理字幕通知回调
  void Function(Map<String, dynamic>)? _onAIAgentSubtitleNotify;

  /// 音量变化回调，包含音量大小信息
  void Function(Map<String, dynamic>)? _onVolumeChanged;

  /// 智能体视频推流可用状态回调
  void Function(bool)? _onAgentVideoAvailable;

  /// 智能体音频推流可用状态回调
  void Function(bool)? _onAgentAudioAvailable;

  /// 数字人首帧渲染完成回调
  void Function()? _onAgentAvatarFirstFrameDrawn;

  /// 语音打断功能开关变化回调
  void Function(bool)? _onVoiceInterrupted;

  /// 其他用户上线回调
  void Function(String)? _onUserOnline;

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
    void Function(Map<String, dynamic>)? onUserAsrSubtitleNotify,
    void Function(Map<String, dynamic>)? onAIAgentSubtitleNotify,
    void Function(Map<String, dynamic>)? onVolumeChanged,
    void Function(bool)? onAgentVideoAvailable,
    void Function(bool)? onAgentAudioAvailable,
    void Function()? onAgentAvatarFirstFrameDrawn,
    void Function(bool)? onVoiceInterrupted,
    void Function(String)? onUserOnline,
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
    _onUserAsrSubtitleNotify = onUserAsrSubtitleNotify;
    _onAIAgentSubtitleNotify = onAIAgentSubtitleNotify;
    _onVolumeChanged = onVolumeChanged;
    _onAgentVideoAvailable = onAgentVideoAvailable;
    _onAgentAudioAvailable = onAgentAudioAvailable;
    _onAgentAvatarFirstFrameDrawn = onAgentAvatarFirstFrameDrawn;
    _onVoiceInterrupted = onVoiceInterrupted;
    _onUserOnline = onUserOnline;
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
        case 'onUserAsrSubtitleNotify':
          if (_onUserAsrSubtitleNotify != null) {
            final Map<String, dynamic> args =
                Map<String, dynamic>.from(call.arguments as Map);
            // 将字符串转换为枚举
            if (args.containsKey('voicePrintStatus')) {
              final status = VoicePrintStatusCode.fromString(
                  args['voicePrintStatus'] as String);
              args['voicePrintStatus'] = status;
            }
            _onUserAsrSubtitleNotify?.call(args);
          }
          break;
        case 'onAIAgentSubtitleNotify':
          _onAIAgentSubtitleNotify
              ?.call(Map<String, dynamic>.from(call.arguments as Map));
          break;
        case 'onVolumeChanged':
          _onVolumeChanged
              ?.call(Map<String, dynamic>.from(call.arguments as Map));
          break;
        case 'onAgentVideoAvailable':
          _onAgentVideoAvailable?.call(call.arguments as bool);
          break;
        case 'onAgentAudioAvailable':
          _onAgentAudioAvailable?.call(call.arguments as bool);
          break;
        case 'onAgentAvatarFirstFrameDrawn':
          _onAgentAvatarFirstFrameDrawn?.call();
          break;
        case 'onVoiceInterrupted':
          _onVoiceInterrupted?.call(call.arguments as bool);
          break;
        case 'onUserOnLine':
          _onUserOnline?.call(call.arguments as String);
          break;
      }
    });
  }
}
