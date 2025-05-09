import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isFromMe;
  final bool isSystemMessage;
  final DateTime timestamp;
  
  // const 제거 및 timestamp 처리 수정
  ChatMessage({
    required this.id,
    required this.content,
    this.isFromMe = false,
    this.isSystemMessage = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  String get formattedTime => DateFormat('HH:mm:ss').format(timestamp);
  
  Color get backgroundColor => isSystemMessage 
      ? Colors.grey[300]! 
      : isFromMe 
          ? Colors.lightBlue[100]! 
          : Colors.white;
  
  Alignment get alignment => isSystemMessage 
      ? Alignment.center 
      : isFromMe 
          ? Alignment.centerRight 
          : Alignment.centerLeft;
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isFromMe: json['isFromMe'] as bool,
      isSystemMessage: json['isSystemMessage'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isFromMe': isFromMe,
      'isSystemMessage': isSystemMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  @override
  List<Object?> get props => [id, content, isFromMe, isSystemMessage, timestamp];
  
  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isFromMe,
    bool? isSystemMessage,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isFromMe: isFromMe ?? this.isFromMe,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}