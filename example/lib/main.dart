import 'package:ali_ai_call/ai_call_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Call Kit Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AICallDemo(),
    );
  }
}

class AICallDemo extends StatefulWidget {
  const AICallDemo({Key? key}) : super(key: key);

  @override
  State<AICallDemo> createState() => _AICallDemoState();
}

class _AICallDemoState extends State<AICallDemo> {
  bool _isInitialized = false;
  bool _isInCall = false;
  bool _isMicOn = true;
  bool _isSpeakerOn = true;
  String _lastAIResponse = '';

  @override
  void initState() {
    super.initState();
    _initializeAICallKit();
  }

  Future<void> _initializeAICallKit() async {
    try {
      // 初始化引擎
      await AiCallKit.initEngine(userId: "demo_user_123");

      // 设置回调
      AiCallKit.setEngineCallback(
        onCallBegin: _handleCallBegin,
        onCallEnd: _handleCallEnd,
        onError: _handleError,
        onAIResponse: _handleAIResponse,
        onUserSpeaking: _handleUserSpeaking,
        onNetworkQuality: _handleNetworkQuality,
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('初始化失败: $e');
      if (e is PlatformException) {
        print('错误代码: ${e.code}');
        print('错误信息: ${e.message}');
        print('错误详情: ${e.details}');
      }
    }
  }

  Future<void> _startCall() async {
    if (!_isInitialized) return;

    if (_isInCall) {
      print('已经在通话中，请先结束当前通话');
      return;
    }

    try {
      await AiCallKit.call(
          rtcToken: "your_rtc_token_here",
          aiAgentInstanceId: "default_agent",
          aiAgentUserId: "ai_agent_001",
          channelId: "demo_channel_${DateTime.now().millisecondsSinceEpoch}");
    } catch (e) {
      print('开始通话失败: $e');
      setState(() {
        _isInCall = false; // 确保状态正确
      });
    }
  }

  Future<void> _endCall() async {
    try {
      await AiCallKit.hangup();
    } catch (e) {
      print('结束通话失败: $e');
    }
  }

  Future<void> _toggleMicrophone() async {
    try {
      await AiCallKit.switchMicrophone(!_isMicOn);
      setState(() {
        _isMicOn = !_isMicOn;
      });
    } catch (e) {
      print('切换麦克风失败: $e');
    }
  }

  Future<void> _toggleSpeaker() async {
    try {
      await AiCallKit.enableSpeaker(!_isSpeakerOn);
      setState(() {
        _isSpeakerOn = !_isSpeakerOn;
      });
    } catch (e) {
      print('切换扬声器失败: $e');
    }
  }

  Future<void> _interruptSpeaking() async {
    try {
      await AiCallKit.interruptSpeaking();
    } catch (e) {
      print('打断说话失败: $e');
    }
  }

  // 回调处理方法
  void _handleCallBegin() {
    setState(() {
      _isInCall = true;
    });
    print('通话开始');
  }

  void _handleCallEnd() {
    setState(() {
      _isInCall = false;
    });
    print('通话结束');
  }

  void _handleError(String errorCode) {
    print('发生错误: $errorCode');
  }

  void _handleAIResponse(String response) {
    setState(() {
      _lastAIResponse = response;
    });
    print('AI回复: $response');
  }

  void _handleUserSpeaking(bool isSpeaking) {
    print('用户${isSpeaking ? "正在" : "停止"}说话');
  }

  void _handleNetworkQuality(int quality) {
    print('网络质量: $quality');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI通话演示'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '状态: ${_isInitialized ? "已初始化" : "未初始化"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isInitialized && !_isInCall ? _startCall : null,
              child: const Text('开始通话'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isInCall ? _endCall : null,
              child: const Text('结束通话'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(_isMicOn ? Icons.mic : Icons.mic_off),
                  onPressed: _isInCall ? _toggleMicrophone : null,
                ),
                IconButton(
                  icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_off),
                  onPressed: _isInCall ? _toggleSpeaker : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isInCall ? _interruptSpeaking : null,
              child: const Text('打断AI说话'),
            ),
            const SizedBox(height: 20),
            Text(
              'AI最新回复:\n$_lastAIResponse',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isInCall) {
      _endCall();
    }
    super.dispose();
  }
}
