import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chat_message.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  
  const ChatMessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSystemMessage) {
      return _buildSystemMessage();
    } else {
      return _buildUserMessage();
    }
  }
  
  Widget _buildSystemMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: message.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          message.content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: 200.ms,
      ),
    );
  }
  
  Widget _buildUserMessage() {
    return Align(
      alignment: message.alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isFromMe) ...[
              Text(
                message.formattedTime,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
            ],
            
            Container(
              constraints: const BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: message.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Text(
                message.content,
                style: const TextStyle(fontSize: 15),
              ),
            ).animate().fadeIn(duration: 200.ms).slide(
              begin: Offset(message.isFromMe ? 0.1 : -0.1, 0),
              end: const Offset(0, 0),
              duration: 200.ms,
            ),
            
            if (message.isFromMe) ...[
              const SizedBox(width: 4),
              Text(
                message.formattedTime,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}