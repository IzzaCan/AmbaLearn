import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(ChatProvider chat) {
    final text = _messageController.text.trim();
    if (text.isEmpty || chat.isSending) return;

    _messageController.clear();
    chat.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final username = auth.user?.username ?? "Guest";

    if (chat.messages.isNotEmpty) _scrollToBottom();

    return Column(
      children: [
        Expanded(
          child: chat.messages.isEmpty
              ? _buildDraftState(username)
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: chat.messages.length + (chat.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chat.messages.length) {
                      return const ChatBubble(
                        message: "Thinking...",
                        isUser: false,
                      );
                    }
                    final msg = chat.messages[index];
                    return ChatBubble(
                      message: msg['content'],
                      isUser: msg['role'] == 'user',
                    );
                  },
                ),
        ),
        _buildInput(chat),
      ],
    );
  }

  Widget _buildDraftState(String username) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Hello, $username",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Mau belajar apa hari ini?",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(ChatProvider chat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: const Color(0xFF4D0005),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(chat),
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Ketik pesan...",
                hintStyle: TextStyle(color: Colors.white38),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.mic, color: Color(0xFF870005)),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: IconButton(
              onPressed: chat.isSending ? null : () => _sendMessage(chat),
              icon: const Icon(Icons.send, color: Color(0xFF870005)),
            ),
          ),
        ],
      ),
    );
  }
}
