import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ali_ai_call_platform_interface.dart';

/// An implementation of [AliAiCallPlatform] that uses method channels.
class MethodChannelAliAiCall extends AliAiCallPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ali_ai_call');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
