import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';

class InputSection extends StatefulWidget {
  final VoidCallback? onSend;
  
  const InputSection({
    super.key,
    this.onSend,
  });

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = Provider.of<ChatService>(context, listen: false);
      _messageController.text = chatService.messageInput;
      
      _messageController.addListener(() {
        if (_messageController.text != chatService.messageInput) {
          chatService.setMessageInput(_messageController.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(ChatService chatService) async {
    if (_messageController.text.trim().isEmpty) return;
    
    await chatService.sendMessage();
    _messageController.clear();
    widget.onSend?.call();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    
    // 입력창과 Provider 데이터 동기화
    if (_messageController.text != chatService.messageInput) {
      _messageController.text = chatService.messageInput;
    }
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              enabled: chatService.canSendMessage,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: chatService.canSendMessage ? '메시지 입력...' : '먼저 매칭을 시작하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: chatService.canSendMessage ? Colors.white : Colors.grey[100],
                filled: true,
              ),
              onSubmitted: chatService.canSendMessage
                  ? (_) => _sendMessage(chatService)
                  : null,
              textInputAction: TextInputAction.newline, // 모바일에서 엔터키 동작 설정
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: chatService.canSendMessage ? Colors.blue : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: Colors.white,
              onPressed: chatService.canSendMessage
                  ? () => _sendMessage(chatService)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}