import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/chat_bubble.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../providers/language_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _startText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    _startText = _messageController.text;
    await _speechToText.listen(onResult: _onSpeechResult, localeId: "id_ID");
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      String newText = result.recognizedWords;
      if (_startText.isNotEmpty) {
        _messageController.text = "$_startText $newText";
      } else {
        _messageController.text = newText;
      }
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
    });
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

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
    final theme = Theme.of(context);

    if (chat.messages.isNotEmpty) _scrollToBottom();

    return Column(
      children: [
        Expanded(
          child: chat.messages.isEmpty
              ? _buildDraftState(username, theme)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  itemCount: chat.messages.length + (chat.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chat.messages.length) {
                      return ChatBubble(
                        message: context.watch<LanguageProvider>().getText(
                          'thinking',
                        ),
                        isUser: false,
                        skipTranslation: true,
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
        _buildInput(chat, theme),
      ],
    );
  }

  Widget _buildDraftState(String username, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated gradient icon container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.secondary.withOpacity(0.2),
                  ],
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "${context.watch<LanguageProvider>().getText('welcome_back')} $username! 👋",
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Mau belajar apa hari ini?",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Suggestion chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip("Python Basics", theme),
                _buildSuggestionChip("Machine Learning", theme),
                _buildSuggestionChip("Web Development", theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, ThemeData theme) {
    final chat = context.read<ChatProvider>();
    return ActionChip(
      label: Text(text),
      backgroundColor: context.surfaceColor,
      side: BorderSide(color: context.dividerColor),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
      ),
      onPressed: () {
        _messageController.text = "Ajarkan saya tentang $text";
        _sendMessage(chat);
      },
    );
  }

  Widget _buildInput(ChatProvider chat, ThemeData theme) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: context.dividerColor),
                ),
                child: TextField(
                  controller: _messageController,
                  onSubmitted: (_) => _sendMessage(chat),
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: context.watch<LanguageProvider>().getText(
                      'type_message',
                    ),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Mic Button
            Container(
              decoration: BoxDecoration(
                color: _isListening
                    ? Colors.redAccent.withOpacity(0.2)
                    : theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _speechEnabled ? _toggleListening : null,
                icon: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: _isListening
                      ? Colors.redAccent
                      : theme.colorScheme.primary,
                ),
                tooltip: "Voice input",
              ),
            ),
            const SizedBox(width: 8),
            // Send Button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: chat.isSending ? null : () => _sendMessage(chat),
                icon: chat.isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
                tooltip: "Send message",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
