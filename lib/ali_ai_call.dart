
import 'ali_ai_call_platform_interface.dart';

class AliAiCall {
  Future<String?> getPlatformVersion() {
    return AliAiCallPlatform.instance.getPlatformVersion();
  }
}
