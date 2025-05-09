import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import 'chat_message_item.dart';

class ChatMessageList extends StatelessWidget {
  final ScrollController scrollController;
  
  const ChatMessageList({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final messages = chatService.messages;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: messages.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    chatService.isConnected
                        ? '대기열에 참가하여 대화를 시작하세요'
                        : '서버에 연결해주세요',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatMessageItem(message: messages[index]);
              },
            ),
    );
  }
}