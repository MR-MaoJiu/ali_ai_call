import 'package:flutter_test/flutter_test.dart';
import 'package:ali_ai_call/ali_ai_call.dart';
import 'package:ali_ai_call/ali_ai_call_platform_interface.dart';
import 'package:ali_ai_call/ali_ai_call_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAliAiCallPlatform
    with MockPlatformInterfaceMixin
    implements AliAiCallPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AliAiCallPlatform initialPlatform = AliAiCallPlatform.instance;

  test('$MethodChannelAliAiCall is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAliAiCall>());
  });

  test('getPlatformVersion', () async {
    AliAiCall aliAiCallPlugin = AliAiCall();
    MockAliAiCallPlatform fakePlatform = MockAliAiCallPlatform();
    AliAiCallPlatform.instance = fakePlatform;

    expect(await aliAiCallPlugin.getPlatformVersion(), '42');
  });
}
