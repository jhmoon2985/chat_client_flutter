import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';

class ConnectSection extends StatefulWidget {
  const ConnectSection({super.key});

  @override
  State<ConnectSection> createState() => _ConnectSectionState();
}

class _ConnectSectionState extends State<ConnectSection> {
  final TextEditingController _serverUrlController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = Provider.of<ChatService>(context, listen: false);
      _serverUrlController.text = chatService.serverUrl;
    });
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    
    if (_serverUrlController.text != chatService.serverUrl && !_isEditing) {
      _serverUrlController.text = chatService.serverUrl;
    }
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        chatService.isConnected ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: chatService.isConnected ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        chatService.connectionStatus,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        chatService.isMatched ? Icons.people : Icons.person_search,
                        size: 16,
                        color: chatService.isMatched ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        chatService.matchStatus,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: chatService.isConnecting 
                    ? null 
                    : () => chatService.connect(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: chatService.isConnected ? Colors.red[100] : Colors.blue,
                  foregroundColor: chatService.isConnected ? Colors.red[900] : Colors.white,
                ),
                child: chatService.isConnecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(chatService.isConnected ? '연결 해제' : '연결'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('서버 URL:'),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _serverUrlController,
                  enabled: chatService.isDisconnected,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (value) {
                    _isEditing = true;
                    chatService.setServerUrl(value);
                  },
                  onEditingComplete: () {
                    _isEditing = false;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}