class Message {
  final String content;
  final bool isFromUser;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isFromUser,
    required this.timestamp,
  });
}
