import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static Future<Map<String, String>> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId') ?? '9527',
      'aiAgentId':
          prefs.getString('aiAgentId') ?? '48dbfc0f1a0e45cd99f9feef9e36bf76',
      'workflowType': prefs.getString('workflowType') ?? 'System_VoiceChat',
      'region': prefs.getString('region') ?? 'cn-hangzhou',
    };
  }
}
