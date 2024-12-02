import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ali_ai_call/ali_ai_call_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAliAiCall platform = MethodChannelAliAiCall();
  const MethodChannel channel = MethodChannel('ali_ai_call');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initEngine', () async {
    await platform.initEngine(userId: 'testUser');
  });

  test('call', () async {
    await platform.call(
      rtcToken: 'testToken',
      aiAgentInstanceId: 'testInstanceId',
      aiAgentUserId: 'testAgentUserId',
      channelId: 'testChannelId',
    );
  });
}
