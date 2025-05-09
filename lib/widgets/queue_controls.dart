import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/chat_service.dart';

class QueueControls extends StatelessWidget {
  const QueueControls({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (chatService.canJoinQueue)
            ElevatedButton.icon(
              onPressed: () => chatService.joinQueue(),
              icon: const Icon(Icons.people_alt),
              label: const Text('대기열 참가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ).animate().fadeIn(),
          
          if (chatService.canEndChat) ...[
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => chatService.endChat(),
              icon: const Icon(Icons.exit_to_app),
              label: const Text('대화 종료'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ).animate().fadeIn(),
          ],
          
          if (!chatService.isConnected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '먼저 서버에 연결하세요',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }
}