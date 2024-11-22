import 'package:flutter/material.dart';
import 'package:ali_ai_call/ai_call_kit.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final AIService _aiService = AIService();
  bool _isLoading = false;
  bool _isInCall = false;
  bool _isMicOn = true;
  bool _isSpeakerOn = true;

  @override
  void initState() {
    super.initState();
    _initAICallKit();
  }

  void _initAICallKit() async {
    // 初始化引擎,这里需要传入用户ID
    await AiCallKit.initEngine(userId: "9527");

    // 设置通话回调
    AiCallKit.setEngineCallback(
      onCallBegin: () {
        setState(() {
          _isInCall = true;
        });
        _addMessage("通话已开始", false);
      },
      onCallEnd: () {
        setState(() {
          _isInCall = false;
        });
        _addMessage("通话已结束", false);
      },
      onError: (error) {
        _addMessage("发生错误: $error", false);
      },
      onAIResponse: (response) {
        _addMessage(response, false);
      },
      onUserSpeaking: (isSpeaking) {
        // 可以添加用户说话状态的UI反馈
      },
      onNetworkQuality: (quality) {
        // 可以添加网络质量的UI反馈
      },
    );
  }

  void _addMessage(String content, bool isFromUser) {
    setState(() {
      _messages.add(Message(
        content: content,
        isFromUser: isFromUser,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _startCall() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 首先获取通话配置
      final AiConfigModel callConfig = await _aiService.generateAIAgentCall();
      _addMessage("已获取通话配置...", false);

      // 开始通话
      await AiCallKit.call(
        rtcToken: callConfig.rtcAuthToken ?? '',
        aiAgentInstanceId: callConfig.aiAgentInstanceId ?? '',
        aiAgentUserId: callConfig.aiAgentUserId ?? '',
        channelId: callConfig.channelId ?? '',
      );

      _addMessage("正在连接AI助手...", false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('开始通话失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _endCall() async {
    try {
      await AiCallKit.hangup();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('结束通话失败: $e')),
      );
    }
  }

  void _toggleMicrophone() async {
    try {
      await AiCallKit.switchMicrophone(!_isMicOn);
      setState(() {
        _isMicOn = !_isMicOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('切换麦克风失败: $e')),
      );
    }
  }

  void _toggleSpeaker() async {
    try {
      await AiCallKit.enableSpeaker(!_isSpeakerOn);
      setState(() {
        _isSpeakerOn = !_isSpeakerOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('切换扬声器失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI语音助手'),
        actions: [
          if (_isInCall)
            IconButton(
              icon: Icon(_isMicOn ? Icons.mic : Icons.mic_off),
              onPressed: _toggleMicrophone,
            ),
          if (_isInCall)
            IconButton(
              icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_off),
              onPressed: _toggleSpeaker,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: _messages[_messages.length - 1 - index],
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isInCall ? Icons.call_end : Icons.call),
                  label: Text(_isInCall ? '结束通话' : '开始通话'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isInCall ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isInCall ? _endCall : _startCall,
                ),
                if (_isInCall)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.voice_over_off),
                    label: const Text('打断AI'),
                    onPressed: () => AiCallKit.interruptSpeaking(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
