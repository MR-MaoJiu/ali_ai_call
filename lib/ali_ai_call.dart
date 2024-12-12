import 'ali_ai_call_platform_interface.dart';
import 'ali_ai_call_method_channel.dart';
import 'src/voice_print_status.dart';

/// 阿里云 AI 通话插件的主类
/// 提供了与 AI 通话相关的所有功能接口
class AliAiCall {
  /// 获取平台实现实例
  static AliAiCallPlatform get _platform => AliAiCallPlatform.instance;

  /// 设置引擎回调函数
  /// 用于接收来自原生平台的各种事件通知
  ///
  /// [onCallBegin] 通话开始回调
  /// [onCallEnd] 通话结束回调
  /// [onError] 错误回调，参数为错误信息
  /// [onAIResponse] AI响应回调，参数为响应内容
  /// [onUserSpeaking] 用户说话状态回调，true表示正在说话
  /// [onNetworkQuality] 网络质量回调，参数为质量等级(0-6)
  /// [onVideoSizeChanged] 视频尺寸变化回调，包含宽高信息
  /// [onVoiceIdChanged] 声音ID变化回调
  /// [onRoleChanged] 角色变化回调
  /// [onAIAgentStateChanged] AI代理状态变化回调
  /// [onAIAgentASRMessage] AI代理ASR消息回调，语音识别结果
  /// [onAIAgentTTSMessage] AI代理TTS消息回调，语音合成信息
  /// [onVolumeChanged] 音量变化回调，包含音量大小信息
  /// [onUserAsrSubtitleNotify] 用户ASR字幕通知回调
  /// [onAIAgentSubtitleNotify] AI代理字幕通知回调
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
    void Function(Map<String, dynamic>)? onUserAsrSubtitleNotify,
    void Function(Map<String, dynamic>)? onAIAgentSubtitleNotify,
    void Function(Map<String, dynamic>)? onVolumeChanged,
  }) {
    if (_platform is MethodChannelAliAiCall) {
      (_platform as MethodChannelAliAiCall).setEngineCallback(
        onCallBegin: onCallBegin,
        onCallEnd: onCallEnd,
        onError: onError,
        onAIResponse: onAIResponse,
        onUserSpeaking: onUserSpeaking,
        onNetworkQuality: onNetworkQuality,
        onVideoSizeChanged: onVideoSizeChanged,
        onVoiceIdChanged: onVoiceIdChanged,
        onRoleChanged: onRoleChanged,
        onAIAgentStateChanged: onAIAgentStateChanged,
        onUserAsrSubtitleNotify: onUserAsrSubtitleNotify,
        onAIAgentSubtitleNotify: onAIAgentSubtitleNotify,
        onVolumeChanged: onVolumeChanged,
      );
    }
  }

  /// 初始化引擎
  /// [userId] 用户ID
  static Future<void> initEngine({required String userId}) {
    return _platform.initEngine(userId: userId);
  }

  /// 发起通话
  /// [rtcToken] RTC通话令牌
  /// [aiAgentInstanceId] AI代理实例ID
  /// [aiAgentUserId] AI代理用户ID
  /// [channelId] 通话频道ID
  static Future<void> call({
    required String rtcToken,
    required String aiAgentInstanceId,
    required String aiAgentUserId,
    required String channelId,
  }) {
    return _platform.call(
      rtcToken: rtcToken,
      aiAgentInstanceId: aiAgentInstanceId,
      aiAgentUserId: aiAgentUserId,
      channelId: channelId,
    );
  }

  /// 挂断通话
  static Future<void> hangup() => _platform.hangup();

  /// 切换麦克风状态
  /// [on] true开启，false关闭
  static Future<void> switchMicrophone(bool on) =>
      _platform.switchMicrophone(on);

  /// 切换扬声器状态
  /// [enable] true开启，false关闭
  static Future<void> enableSpeaker(bool enable) =>
      _platform.enableSpeaker(enable);

  /// 打断AI说话
  static Future<void> interruptSpeaking() => _platform.interruptSpeaking();

  /// 启用/禁用语音打断功能
  /// [enable] true启用，false禁用
  static Future<void> enableVoiceInterrupt(bool enable) =>
      _platform.enableVoiceInterrupt(enable);

  /// 切换AI机器人声音
  /// [voiceId] 声音ID
  static Future<void> switchRobotVoice(String voiceId) =>
      _platform.switchRobotVoice(voiceId);

  /// 设置AI角色
  /// [roleId] 角色ID
  /// [roleName] 角色名称
  static Future<void> setAIRole(String roleId, String roleName) =>
      _platform.setAIRole(roleId, roleName);
}
