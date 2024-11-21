import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ali_ai_call_method_channel.dart';

abstract class AliAiCallPlatform extends PlatformInterface {
  /// Constructs a AliAiCallPlatform.
  AliAiCallPlatform() : super(token: _token);

  static final Object _token = Object();

  static AliAiCallPlatform _instance = MethodChannelAliAiCall();

  /// The default instance of [AliAiCallPlatform] to use.
  ///
  /// Defaults to [MethodChannelAliAiCall].
  static AliAiCallPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AliAiCallPlatform] when
  /// they register themselves.
  static set instance(AliAiCallPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
