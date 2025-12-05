import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser 
              ? const Color(0xFF870005) // User: Red Theme
              : const Color(0xFF333333), // AI: Dark Grey
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 16,
                height: 1.4,
              ),
            ),
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                time!,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
                textAlign: isUser ? TextAlign.right : TextAlign.left,
              ),
            ],
          ],
        ),
      ),
    );
  }
}