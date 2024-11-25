import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ali_ai_call/ai_call_kit.dart';
import 'config_service.dart';

class AIService {
  static const String baseUrl = 'http://172.25.11.96:8081';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));

  // 生成智能体通话配置
  Future<AiConfigModel> generateAIAgentCall() async {
    try {
      // 获取保存的配置
      final config = await ConfigService.getConfig();

      final Map<String, dynamic> requestBody = {
        "user_id": config['userId'],
        "ai_agent_id": config['aiAgentId'],
        "workflow_type": config['workflowType'],
        "region": config['region'],
        "template_config": "{}"
      };

      final response = await _dio.post(
        '/api/v2/aiagent/generateAIAgentCall',
        data: requestBody,
      );

      print('Generate Response status: ${response.statusCode}');
      print('Generate Response data: ${response.data}');

      if (response.statusCode == 200) {
        return AiConfigModel.fromJson(response.data);
      } else {
        throw Exception('服务器响应错误: ${response.statusCode}');
      }
    } catch (e) {
      print('Generate Error details: $e');
      throw Exception('生成通话配置失败: $e');
    }
  }
}

T? asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class AiConfigModel {
  AiConfigModel({
    this.aiAgentId,
    this.rtcAuthToken,
    this.code,
    this.aiAgentInstanceId,
    this.aiAgentUserId,
    this.workflowType,
    this.channelId,
    this.requestId,
  });

  factory AiConfigModel.fromJson(Map<String, dynamic> json) => AiConfigModel(
        aiAgentId: asT<String?>(json['ai_agent_id']),
        rtcAuthToken: asT<String?>(json['rtc_auth_token']),
        code: asT<int?>(json['code']),
        aiAgentInstanceId: asT<String?>(json['ai_agent_instance_id']),
        aiAgentUserId: asT<String?>(json['ai_agent_user_id']),
        workflowType: asT<String?>(json['workflow_type']),
        channelId: asT<String?>(json['channel_id']),
        requestId: asT<String?>(json['request_id']),
      );

  String? aiAgentId;
  String? rtcAuthToken;
  int? code;
  String? aiAgentInstanceId;
  String? aiAgentUserId;
  String? workflowType;
  String? channelId;
  String? requestId;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ai_agent_id': aiAgentId,
        'rtc_auth_token': rtcAuthToken,
        'code': code,
        'ai_agent_instance_id': aiAgentInstanceId,
        'ai_agent_user_id': aiAgentUserId,
        'workflow_type': workflowType,
        'channel_id': channelId,
        'request_id': requestId,
      };
}
