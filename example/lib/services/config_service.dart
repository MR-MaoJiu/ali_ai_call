import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static Future<Map<String, String>> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId') ?? '9527',
      'aiAgentId':
          prefs.getString('aiAgentId') ?? 'f22071db56834e82a14755be5b20a9c1',
      'workflowType': prefs.getString('workflowType') ?? 'System_VoiceChat',
      'region': prefs.getString('region') ?? 'cn-shanghai',
    };
  }
}
