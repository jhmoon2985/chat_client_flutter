import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          const Text('상대방 성별:'),
          const SizedBox(width: 16),
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'male',
                  label: Text('남성'),
                  icon: Icon(Icons.male),
                ),
                ButtonSegment<String>(
                  value: 'female',
                  label: Text('여성'),
                  icon: Icon(Icons.female),
                ),
              ],
              selected: {chatService.selectedGender},
              onSelectionChanged: chatService.isDisconnected 
                  ? (Set<String> selected) {
                      chatService.setSelectedGender(selected.first);
                    }
                  : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.blue;
                    }
                    return Colors.white;
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.black;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}