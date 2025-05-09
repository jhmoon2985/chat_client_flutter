import 'package:flutter/material.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/connect_section.dart';
import '../widgets/gender_selector.dart';
import '../widgets/input_section.dart';
import '../widgets/queue_controls.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebServerMVC 채팅 클라이언트'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 연결 상태 및 서버 설정
            const ConnectSection(),
            
            // 성별 선택
            const GenderSelector(),
            
            // 채팅 메시지 리스트
            Expanded(
              child: ChatMessageList(scrollController: _scrollController),
            ),
            
            // 매칭 관련 버튼
            const QueueControls(),
            
            // 메시지 입력
            InputSection(
              onSend: () {
                // 메시지 전송 후 스크롤 아래로
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}