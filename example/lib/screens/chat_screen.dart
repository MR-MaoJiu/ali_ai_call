import 'package:ali_ai_call/ali_ai_call.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../services/config_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/audio_visualizer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
  bool _agentVideoAvailable = false;
  bool _agentAudioAvailable = false;
  bool _avatarFirstFrameDrawn = false;
  bool _voiceInterruptEnabled = false;
  String _lastOnlineUserId = '';
  String _aiAgentState = '';

  @override
  void initState() {
    super.initState();
    _initAliAiCall();
  }

  void _initAliAiCall() async {
    final config = await ConfigService.getConfig();
    await AliAiCall.initEngine(userId: config['userId'] ?? '9527');

    AliAiCall.setEngineEventHandler(
      onCallBegin: () {
        setState(() {
          _isInCall = true;
          print("---------------onCallBegin-----------------");
        });
        _addMessage("通话已开始", false);
      },
      onCallEnd: () {
        setState(() {
          _isInCall = false;
        });
        print("---------------onCallEnd-----------------");
        _addMessage("通话已结束", false);
      },
      onError: (error) {
        print("---------------发生错误-----------------");
        _addMessage("发生错误: $error", false);
      },
      onUserSpeaking: (isSpeaking) {
        print("---------------onUserSpeaking-----------------");
        setState(() {
          _isUserSpeaking = isSpeaking;
        });
      },
      onNetworkQuality: (quality) {
        print("---------------onNetworkQuality-----------------");
        setState(() {
          _networkQuality = quality;
        });
      },
      onVoiceIdChanged: (voiceId) {
        print("---------------onVoiceIdChanged-----------------");
        _addMessage("AI声音已切换: $voiceId", false);
      },
      onRoleChanged: (role) {
        print("---------------onRoleChanged-----------------");
        _addMessage("AI角色已切换: $role", false);
      },
      onAIAgentStateChanged: (state) {
        print("---------------onAIAgentStateChanged-----------------");
        setState(() {
          _aiAgentState = state;
        });
        _addMessage("AI状态变更: $state", false);
      },
      onVolumeChanged: (Map<String, dynamic> volumeData) {
        print("---------------onVolumeChanged-----------------");
        setState(() {
          _currentUid = volumeData['uid'] as String;
          final int volume = volumeData['volume'] as int;
          _currentVolume = volume;
          _isUserSpeaking = volume > 0;
          print('Volume Changed: $volume, Speaking: $_isUserSpeaking');
        });
      },
      onAIAgentSubtitleNotify: (Map<String, dynamic> asrData) {
        print(
            "---------------onAIAgentSubtitleNotify${asrData}-----------------");
        setState(() {
          _currentASRText = asrData['text'] as String;
          _addMessage(_currentASRText, false);
        });
      },
      onUserAsrSubtitleNotify: (Map<String, dynamic> data) {
        print("---------------onUserAsrSubtitleNotify${data}-----------------");
        setState(() {
          _currentUserAsrText = data['text'] as String;
          _isUserSpeakingEnd = data['isSentenceEnd'] as bool;
          _currentSentenceId = data['sentenceId'] as int;
          VoicePrintStatusCode voicePrintStatus = data['voicePrintStatus'];

          switch (voicePrintStatus) {
            case VoicePrintStatusCode.speakerRecognized:
              print('说话人已识别');
              break;
            case VoicePrintStatusCode.speakerNotRecognized:
              print('说话人未识别');
              break;
            case VoicePrintStatusCode.disable:
              print('声纹识别已禁用');
              break;
            case VoicePrintStatusCode.enableWithoutRegister:
              print('声纹识别已启用但未注册');
              break;
            case VoicePrintStatusCode.unknown:
              print('未知状态');
              break;
          }
        });
      },
      onAgentVideoAvailable: (available) {
        print("---------------onAgentVideoAvailable-----------------");
        setState(() {
          _agentVideoAvailable = available;
        });
      },
      onAgentAudioAvailable: (available) {
        print("---------------onAgentAudioAvailable-----------------");
        setState(() {
          _agentAudioAvailable = available;
        });
      },
      onAgentAvatarFirstFrameDrawn: () {
        print("---------------onAgentAvatarFirstFrameDrawn-----------------");
        setState(() {
          _avatarFirstFrameDrawn = true;
        });
        _addMessage("数字人首帧已渲染", false);
      },
      onVoiceInterrupted: (enable) {
        print("---------------onVoiceInterrupted-----------------");
        setState(() {
          _voiceInterruptEnabled = enable;
        });
      },
      onUserOnline: (uid) {
        print("---------------onUserOnLine-----------------");
        setState(() {
          _lastOnlineUserId = uid;
        });
        _addMessage("有用户上线: $uid", false);
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
      // 读取本地配置中的 userId，用于 iOS call[1/2] 接口的 userId 参数
      final config = await ConfigService.getConfig();
      await AliAiCall.call(
        rtcToken: callConfig.rtcAuthToken ?? '',
        aiAgentInstanceId: callConfig.aiAgentInstanceId ?? '',
        aiAgentUserId: callConfig.aiAgentUserId ?? '',
        channelId: callConfig.channelId ?? '',
        // iOS 侧 ARTCAICallAgentInfo.agentId 需要智能体模板ID
        aiAgentId: callConfig.aiAgentId ?? '',
        // iOS 侧 call(userId:) 需要当前登录用户ID
        userId: config['userId'] ?? '',
      );

      setState(() {
        _isInCall = true;
      });
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

  void _toggleVoiceInterrupt() async {
    try {
      await AliAiCall.enableVoiceInterrupt(!_voiceInterruptEnabled);
      setState(() {
        _voiceInterruptEnabled = !_voiceInterruptEnabled;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('切换语音打断开关失败: $e')),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '网络质量: $_networkQuality',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '视频: ${_agentVideoAvailable ? "可用" : "不可用"}  音频: ${_agentAudioAvailable ? "可用" : "不可用"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (_aiAgentState.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'AI状态: $_aiAgentState',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
                if (_lastOnlineUserId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '最近上线用户: $_lastOnlineUserId',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
                if (_avatarFirstFrameDrawn) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '数字人已就绪',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
                const SizedBox(height: 12),
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
                if (_isInCall)
                  ElevatedButton.icon(
                    icon: Icon(
                      _voiceInterruptEnabled
                          ? Icons.hearing
                          : Icons.hearing_disabled,
                    ),
                    label: Text(_voiceInterruptEnabled ? '关闭语音打断' : '开启语音打断'),
                    onPressed: _toggleVoiceInterrupt,
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
