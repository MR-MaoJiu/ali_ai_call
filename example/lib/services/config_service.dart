import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static Future<Map<String, String>> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId') ?? '9527',
      'aiAgentId':
          prefs.getString('aiAgentId') ?? 'fe3b67ab350a4e05a81653b9bce709c5',
      'workflowType': prefs.getString('workflowType') ?? 'System_VoiceChat',
      'region': prefs.getString('region') ?? 'cn-shanghai',
    };
  }
}
