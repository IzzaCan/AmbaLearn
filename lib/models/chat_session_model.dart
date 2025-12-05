class ChatSession {
  final String uid;
  final String title;
  final String lastModified;

  ChatSession({
    required this.uid,
    required this.title,
    required this.lastModified,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      uid: json['uid'] ?? '',
      title: json['title'] ?? 'New Chat',
      lastModified: json['last_modified'] ?? '',
    );
  }
}