import 'package:ali_ai_call/ali_ai_call.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../services/config_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/audio_visualizer.dart';
import 'dart:math' as math;

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
  bool _isUserSpeaking = false;
  int _networkQuality = 0;
  String _currentASRText = '';
  String _currentTTSText = '';
  int _currentVolume = 0;
  String _currentUserAsrText = '';
  bool _isUserSpeakingEnd = false;
  int _currentSentenceId = 0;
  String _currentUid = '';

  @override
  void initState() {
    super.initState();
    _initAliAiCall();
  }

  void _initAliAiCall() async {
    final config = await ConfigService.getConfig();
    await AliAiCall.initEngine(userId: config['userId'] ?? '9527');

    AliAiCall.setEngineCallback(
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
        setState(() {
          _isUserSpeaking = isSpeaking;
        });
      },
      onNetworkQuality: (quality) {
        setState(() {
          _networkQuality = quality;
        });
      },
      onVoiceIdChanged: (voiceId) {
        _addMessage("AI声音已切换: $voiceId", false);
      },
      onRoleChanged: (role) {
        _addMessage("AI角色已切换: $role", false);
      },
      onAIAgentStateChanged: (state) {
        _addMessage("AI状态变更: $state", false);
      },
      onVolumeChanged: (Map<String, dynamic> volumeData) {
        setState(() {
          _currentUid = volumeData['uid'] as String;
          final int volume = volumeData['volume'] as int;
          _isUserSpeaking = volume > 0;
          print('Volume Changed: $volume, Speaking: $_isUserSpeaking');
        });
      },
      onAIAgentASRMessage: (Map<String, dynamic> asrData) {
        setState(() {
          _currentASRText = asrData['text'] as String;
        });
      },
      onAIAgentTTSMessage: (Map<String, dynamic> ttsData) {
        setState(() {
          _currentTTSText = ttsData['text'] as String;
        });
      },
      onUserAsrSubtitleNotify: (Map<String, dynamic> data) {
        setState(() {
          _currentUserAsrText = data['text'] as String;
          _isUserSpeakingEnd = data['isSentenceEnd'] as bool;
          _currentSentenceId = data['sentenceId'] as int;
        });
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
    if (_isInCall) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已在通话中')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _currentASRText = '';
      _currentTTSText = '';
      _currentUserAsrText = '';
      _currentVolume = 0;
      _isUserSpeaking = false;
      _networkQuality = 0;
    });

    try {
      final AiConfigModel callConfig = await _aiService.generateAIAgentCall();
      _addMessage("已获取通话配置...", false);

      await AliAiCall.call(
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
      setState(() {
        _isInCall = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _endCall() async {
    try {
      await AliAiCall.hangup();
      setState(() {
        _isInCall = false;
        _isMicOn = true;
        _isSpeakerOn = true;
        _isUserSpeaking = false;
        _networkQuality = 0;
        _currentASRText = '';
        _currentTTSText = '';
        _currentVolume = 0;
        _currentUserAsrText = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('结束通话失败: $e')),
      );
    }
  }

  void _toggleMicrophone() async {
    try {
      await AliAiCall.switchMicrophone(!_isMicOn);
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
      await AliAiCall.enableSpeaker(!_isSpeakerOn);
      setState(() {
        _isSpeakerOn = !_isSpeakerOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('切换扬声器失败: $e')),
      );
    }
  }

  Widget _buildVoiceStatus() {
    if (!_isInCall) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                AudioVisualizer(
                  isActive: _isUserSpeaking,
                  volume: _currentVolume,
                  color: Colors.blue,
                  height: 100,
                  barsCount: 60,
                ),
                if (_currentUserAsrText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _currentUserAsrText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_currentTTSText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI回复:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentTTSText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI语音助手'),
        actions: [
          if (_isInCall) ...[
            IconButton(
              icon: Icon(_isMicOn ? Icons.mic : Icons.mic_off),
              onPressed: _toggleMicrophone,
              tooltip: '麦克风',
            ),
            IconButton(
              icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_off),
              onPressed: _toggleSpeaker,
              tooltip: '扬声器',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildVoiceStatus(),
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
                    onPressed: () => AliAiCall.interruptSpeaking(),
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
    if (_isInCall) {
      _endCall();
    }
    _messageController.dispose();
    super.dispose();
  }
}
