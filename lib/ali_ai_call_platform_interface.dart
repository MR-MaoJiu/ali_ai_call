import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'ali_ai_call_method_channel.dart';

/// 阿里云 AI 通话插件的平台接口抽象类
/// 所有平台特定的实现都必须继承这个类
abstract class AliAiCallPlatform extends PlatformInterface {
  /// 构造函数，初始化平台接口
  AliAiCallPlatform() : super(token: _token);

  /// 用于验证平台实现的令牌
  static final Object _token = Object();

  /// 默认的平台实现实例
  static AliAiCallPlatform _instance = MethodChannelAliAiCall();

  /// 获取当前平台实现实例
  static AliAiCallPlatform get instance => _instance;

  /// 设置平台实现实例
  /// 用于测试时注入 mock 实现
  static set instance(AliAiCallPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 初始化引擎
  /// [userId] 用户ID
  Future<void> initEngine({required String userId}) {
    throw UnimplementedError('initEngine() has not been implemented.');
  }

  /// 发起通话
  /// [rtcToken] RTC通话令牌
  /// [aiAgentInstanceId] AI代理实例ID
  /// [aiAgentUserId] AI代理用户ID
  /// [channelId] 通话频道ID
  Future<void> call({
    required String rtcToken,
    required String aiAgentInstanceId,
    required String aiAgentUserId,
    required String channelId,
  }) {
    throw UnimplementedError('call() has not been implemented.');
  }

  /// 挂断通话
  Future<void> hangup() {
    throw UnimplementedError('hangup() has not been implemented.');
  }

  /// 切换麦克风状态
  /// [on] true开启，false关闭
  Future<void> switchMicrophone(bool on) {
    throw UnimplementedError('switchMicrophone() has not been implemented.');
  }

  /// 切换扬声器状态
  /// [enable] true开启，false关闭
  Future<void> enableSpeaker(bool enable) {
    throw UnimplementedError('enableSpeaker() has not been implemented.');
  }

  /// 打断AI说话
  Future<void> interruptSpeaking() {
    throw UnimplementedError('interruptSpeaking() has not been implemented.');
  }

  /// 启用/禁用语音打断功能
  /// [enable] true启用，false禁用
  Future<void> enableVoiceInterrupt(bool enable) {
    throw UnimplementedError(
        'enableVoiceInterrupt() has not been implemented.');
  }

  /// 切换AI机器人声音
  /// [voiceId] 声音ID
  Future<void> switchRobotVoice(String voiceId) {
    throw UnimplementedError('switchRobotVoice() has not been implemented.');
  }

  /// 设置AI角色
  /// [roleId] 角色ID
  /// [roleName] 角色名称
  Future<void> setAIRole(String roleId, String roleName) {
    throw UnimplementedError('setAIRole() has not been implemented.');
  }
}
