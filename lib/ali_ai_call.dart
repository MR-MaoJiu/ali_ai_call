import 'package:flutter/services.dart';
import 'ali_ai_call_platform_interface.dart';
import 'ai_call_kit.dart';

class AliAiCall {
  static const MethodChannel _channel = MethodChannel('ali_ai_call');

  Future<String?> getPlatformVersion() {
    return AliAiCallPlatform.instance.getPlatformVersion();
  }

  // 暴露 AiCallKit 的静态方法
  static Future<void> initEngine({required String userId}) {
    return AiCallKit.initEngine(userId: userId);
  }

  // 可以添加其他需要的方法...
}
