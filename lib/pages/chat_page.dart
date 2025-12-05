import 'package:capstone_layout/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  // Accepts a UID directly, or null if it's a new chat
  final String? chatUid;

  const ChatPage({super.key, this.chatUid});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ApiService _api = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? currentUid;
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    currentUid = widget.chatUid;
    _initializeChat();
  }

  void _initializeChat() async {
    if (currentUid == null) {
      // Create new session if no UID provided
      try {
        final res = await _api.post(ApiConfig.createSession);
        if (res.statusCode == 200 && mounted) {
          setState(() {
            currentUid = res.data['uid'];
            // Add default system greeting purely for UI (optional)
            messages.add({
              "role": "assistant",
              "content": "Hello! I am AmbaLearn AI. How can I help you today?",
            });
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) _showError("Failed to create session");
      }
    } else {
      // Load existing session
      _loadChatHistory();
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final res = await _api.get(ApiConfig.getSession(currentUid!));
      if (res.statusCode == 200 && mounted) {
        final List history = res.data['messages'] ?? [];
        setState(() {
          // Filter out system messages usually hidden from user
          messages = history
              .map((m) => m as Map<String, dynamic>)
              .where((m) => m['role'] != 'system')
              .toList();
          isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) _showError("Failed to load chat history");
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUid == null) return;

    setState(() {
      messages.add({"role": "user", "content": text});
      isSending = true;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final res = await _api.post(
        ApiConfig.chat,
        data: {"uid": currentUid, "message": text},
      );

      if (res.statusCode == 200 && mounted) {
        final reply = res.data['reply'];
        setState(() {
          messages.add({"role": "assistant", "content": reply});
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) _showError("Failed to send message");
    } finally {
      if (mounted) setState(() => isSending = false);
    }
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

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D0005),
        title: const Text(
          "Ambalearn",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        // Allow the user to open the drawer from the chat page too
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(), // Add the drawer here
      body: Column(
        children: [
          // Chat Area
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : messages.isEmpty
                ? const Center(
                    child: Text(
                      "Start a conversation...",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    itemCount: messages.length + (isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        // Loading bubble for AI response
                        return const ChatBubble(
                          message: "Thinking...",
                          isUser: false,
                        );
                      }

                      final msg = messages[index];
                      return ChatBubble(
                        message: msg['content'] ?? '',
                        isUser: msg['role'] == 'user',
                      );
                    },
                  ),
          ),

          // Input Area (Inspired by lessons.dart)
          Container(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8 + 8, // Standard padding + padding to keep it off safe area
              left: 12,
              right: 12,
            ),
            color: const Color(0xFF4D0005),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: isSending ? null : (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 5),

                // DUMMY MIC BUTTON
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                  child: IconButton(
                    onPressed: () {
                      // Dummy action for mic button
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Microphone input not yet implemented."),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.mic, color: Color(0xFF870005)),
                  ),
                ),
                const SizedBox(width: 5),

                // SEND BUTTON
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                  child: IconButton(
                    onPressed: isSending ? null : _sendMessage,
                    icon: isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.send,
                            color: Color(0xFF870005),
                            size: 24,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}