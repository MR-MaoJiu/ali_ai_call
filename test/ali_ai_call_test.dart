import 'package:flutter_test/flutter_test.dart';
import 'package:ali_ai_call/ali_ai_call.dart';
import 'package:ali_ai_call/ali_ai_call_platform_interface.dart';
import 'package:ali_ai_call/ali_ai_call_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// 模拟测试用的平台实现类
class MockAliAiCallPlatform
    with MockPlatformInterfaceMixin
    implements AliAiCallPlatform {
  @override
  Future<void> initEngine({required String userId}) async {}

  @override
  Future<void> call({
    required String rtcToken,
    required String aiAgentInstanceId,
    required String aiAgentUserId,
    required String channelId,
  }) async {}

  @override
  Future<void> hangup() async {}

  @override
  Future<void> switchMicrophone(bool on) async {}

  @override
  Future<void> enableSpeaker(bool enable) async {}

  @override
  Future<void> interruptSpeaking() async {}

  @override
  Future<void> enableVoiceInterrupt(bool enable) async {}

  @override
  Future<void> switchRobotVoice(String voiceId) async {}

  @override
  Future<void> setAIRole(String roleId, String roleName) async {}
}

void main() {
  final AliAiCallPlatform initialPlatform = AliAiCallPlatform.instance;

  test('$MethodChannelAliAiCall is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAliAiCall>());
  });

  test('initEngine', () async {
    MockAliAiCallPlatform fakePlatform = MockAliAiCallPlatform();
    AliAiCallPlatform.instance = fakePlatform;

    await AliAiCall.initEngine(userId: 'testUser');
  });
}
