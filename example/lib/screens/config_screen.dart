import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _aiAgentIdController = TextEditingController();
  final _workflowTypeController = TextEditingController();
  final _regionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userIdController.text = prefs.getString('userId') ?? '9527';
      _aiAgentIdController.text =
          prefs.getString('aiAgentId') ?? 'f22071db56834e82a14755be5b20a9c1';
      _workflowTypeController.text =
          prefs.getString('workflowType') ?? 'System_VoiceChat';
      _regionController.text = prefs.getString('region') ?? 'cn-shanghai';
    });
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _userIdController.text);
    await prefs.setString('aiAgentId', _aiAgentIdController.text);
    await prefs.setString('workflowType', _workflowTypeController.text);
    await prefs.setString('region', _regionController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI配置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: '用户ID',
                hintText: '请输入用户ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入用户ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aiAgentIdController,
              decoration: const InputDecoration(
                labelText: 'AI Agent ID',
                hintText: '请输入AI Agent ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入AI Agent ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workflowTypeController,
              decoration: const InputDecoration(
                labelText: '工作流类型',
                hintText: '请输入工作流类型',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入工作流类型';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _regionController,
              decoration: const InputDecoration(
                labelText: '区域',
                hintText: '请输入区域',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入区域';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _saveConfig();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  }
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('保存并开始'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _aiAgentIdController.dispose();
    _workflowTypeController.dispose();
    _regionController.dispose();
    super.dispose();
  }
}
