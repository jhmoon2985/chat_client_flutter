import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:signalr_core/signalr_core.dart';  // signalr_netcore 대신 사용
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../models/chat_message.dart';
import '../models/client_config.dart';
import 'storage_service.dart';

class ChatService extends ChangeNotifier {
  final Logger _logger = Logger('ChatService');
  final StorageService _storage = GetIt.instance<StorageService>();
  final AppConfig _config = GetIt.instance<AppConfig>();
  
  HubConnection? _hubConnection;
  String? _clientId;
  
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isMatched = false;
  String _partnerGender = '';
  double _distance = 0.0;
  String _connectionStatus = '연결 끊김';
  String _matchStatus = '매칭 대기 중';
  String _selectedGender = 'male';
  String _serverUrl = '';
  String _messageInput = '';
  
  StreamSubscription? _connectivitySubscription;
  
  final List<ChatMessage> _messages = [];
  
  // Getters
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  bool get isDisconnected => !_isConnected;
  bool get isMatched => _isMatched;
  bool get canJoinQueue => _isConnected && !_isMatched;
  bool get canSendMessage => _isConnected && _isMatched;
  bool get canEndChat => _isConnected && _isMatched;
  
  String get connectionStatus => _connectionStatus;
  String get matchStatus => _matchStatus;
  String get selectedGender => _selectedGender;
  String get serverUrl => _serverUrl;
  String get messageInput => _messageInput;
  List<ChatMessage> get messages => _messages;
  
  ChatService() {
    _serverUrl = _config.serverUrl;
    _selectedGender = _config.defaultGender;
    _loadClientId();
    _monitorConnectivity();
  }
  
  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        if (_isConnected) {
          _logger.info('Network lost, disconnecting from server');
          disconnect();
        }
      }
    });
  }
  
  Future<void> _loadClientId() async {
    try {
      final config = await _storage.getClientConfig();
      if (config != null) {
        _clientId = config.clientId;
        if (_clientId != null && _clientId!.isNotEmpty) {
          _logger.info('Loaded client ID: ${_clientId!.substring(0, min(8, _clientId!.length))}...');
        }
      }
    } catch (e) {
      _logger.severe('Failed to load client ID: $e');
    }
  }
  
  Future<void> _saveClientId() async {
    try {
      final config = ClientConfig(
        clientId: _clientId,
        serverUrl: _serverUrl,
        selectedGender: _selectedGender,
      );
      await _storage.saveClientConfig(config);
    } catch (e) {
      _logger.severe('Failed to save client ID: $e');
    }
  }
  
  void setServerUrl(String url) {
    _serverUrl = url;
    notifyListeners();
  }
  
  void setSelectedGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }
  
  void setMessageInput(String input) {
    _messageInput = input;
    notifyListeners();
  }
  
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return null;
      }
      
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      _logger.warning('Error getting location: $e');
      return null;
    }
  }
  
  Future<void> connect() async {
    if (_isConnected) {
      await disconnect();
      return;
    }
    
    if (_isConnecting) return;
    
    try {
      _isConnecting = true;
      _connectionStatus = '연결 중...';
      notifyListeners();
      
      // signalr_core 패키지는 인증서 검증 옵션이 추가됨
      final httpOptions = HttpConnectionOptions(
        logging: (level, message) => _logger.info(message),
        skipNegotiation: true,
        transport: HttpTransportType.webSockets,
      );
      
      _hubConnection = HubConnectionBuilder()
          .withUrl('$_serverUrl/chathub', httpOptions)
          .withAutomaticReconnect()
          .build();
      
      _registerHubCallbacks();
      
      await _hubConnection!.start();
      await _registerClient();
      
      _isConnected = true;
      _isConnecting = false;
      _connectionStatus = '연결됨';
      notifyListeners();
      
      // 현재 위치 가져오기
      final position = await getCurrentLocation();
      if (position != null) {
        await _updateLocation(position.latitude, position.longitude);
      } else {
        // 위치를 가져올 수 없는 경우 서울 중심부로 기본 설정
        await _updateLocation(37.5642135, 127.0016985);
      }
    } catch (e) {
      _isConnecting = false;
      _connectionStatus = '연결 실패';
      notifyListeners();
      _logger.severe('Failed to connect to server: $e');
    }
  }
  
  void _handleConnectionClosed(Exception? error) {
    _isConnected = false;
    _isMatched = false;
    _connectionStatus = '연결 끊김';
    _matchStatus = '매칭 없음';
    
    if (error != null) {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isSystemMessage: true,
        content: '서버 연결이 끊어졌습니다: $error',
      ));
    }
    
    notifyListeners();
    _logger.info('Connection closed, error: $error');
  }
  
  void _registerHubCallbacks() {
    _hubConnection!.on('Registered', (arguments) {
      try {
        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0] as Map<String, dynamic>;
          _clientId = data['ClientId'] as String;
          _saveClientId();
          
          _connectionStatus = '등록됨: ${_clientId!.substring(0, min(8, _clientId!.length))}...';
          notifyListeners();
        }
      } catch (e) {
        _logger.severe('Error processing registration data: $e');
      }
    });
    
    _hubConnection!.on('EnqueuedToWaiting', (arguments) {
      _matchStatus = '매칭 대기 중...';
      _isMatched = false;
      notifyListeners();
    });
    
    _hubConnection!.on('Matched', (arguments) {
      try {
        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0] as Map<String, dynamic>;
          final partnerGender = data['PartnerGender'] as String;
          final distance = data['Distance'] as double;
          
          _isMatched = true;
          _partnerGender = partnerGender;
          _distance = distance;
          _matchStatus = '매칭됨: ${partnerGender == 'male' ? '남성' : '여성'}, 거리: ${distance.toStringAsFixed(1)}km';
          
          _messages.clear();
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            isSystemMessage: true,
            content: '새로운 상대방과 연결되었습니다. 상대방 성별: ${partnerGender == 'male' ? '남성' : '여성'}, 거리: ${distance.toStringAsFixed(1)}km',
          ));
          
          notifyListeners();
        }
      } catch (e) {
        _logger.severe('Error processing match data: $e');
      }
    });
    
    _hubConnection!.on('MatchEnded', (arguments) {
      _isMatched = false;
      _matchStatus = '매칭 종료됨';
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isSystemMessage: true,
        content: '상대방이 대화를 종료했습니다.',
      ));
      
      notifyListeners();
    });
    
    _hubConnection!.on('ReceiveMessage', (arguments) {
      try {
        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0] as Map<String, dynamic>;
          final senderId = data['SenderId'] as String;
          final message = data['Message'] as String;
          final timestamp = DateTime.parse(data['Timestamp'] as String);
          
          final isFromMe = senderId == _clientId;
          _messages.add(ChatMessage(
            id: '${DateTime.now().millisecondsSinceEpoch}_${_messages.length}',
            isFromMe: isFromMe,
            content: message,
            timestamp: timestamp,
          ));
          
          notifyListeners();
        }
      } catch (e) {
        _logger.severe('Error processing received message: $e');
      }
    });
    
    // signalr_core 패키지에서는 onclose가 정확한 타입을 가짐
    _hubConnection!.onclose(_handleConnectionClosed);
  }
  
  Future<void> _registerClient() async {
    try {
      await _hubConnection!.invoke('Register', args: [_clientId]);
    } catch (e) {
      _logger.severe('Error during registration: $e');
      rethrow;
    }
  }
  
  Future<void> _updateLocation(double latitude, double longitude) async {
    try {
      if (_isConnected) {
        await _hubConnection!.invoke('UpdateLocation', args: [latitude, longitude]);
        _logger.info('Location updated: $latitude, $longitude');
      }
    } catch (e) {
      _logger.severe('Error updating location: $e');
    }
  }
  
  Future<void> joinQueue() async {
    if (!_isConnected || _isMatched) return;
    
    try {
      _matchStatus = '매칭 대기열에 참가 중...';
      notifyListeners();
      await _hubConnection!.invoke('JoinWaitingQueue', args: [_selectedGender]);
      
      // 시스템 메시지 추가
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isSystemMessage: true,
        content: '대기열에 참가했습니다. 매칭을 기다리는 중...',
      ));
      notifyListeners();
    } catch (e) {
      _matchStatus = '매칭 대기열 참가 실패';
      notifyListeners();
      _logger.severe('Error joining queue: $e');
    }
  }
  
  Future<void> sendMessage() async {
    if (!_isConnected || !_isMatched || _messageInput.trim().isEmpty) return;
    
    final messageToSend = _messageInput;
    setMessageInput(''); // UI 즉시 업데이트를 위해 미리 비움
    
    try {
      await _hubConnection!.invoke('SendMessage', args: [messageToSend]);
      // 메시지가 ReceiveMessage 이벤트를 통해 다시 수신되므로 여기서는 추가하지 않음
    } catch (e) {
      // 전송 실패 시 입력창에 메시지 복원
      setMessageInput(messageToSend);
      _logger.severe('Error sending message: $e');
    }
  }
  
  Future<void> endChat() async {
    if (!_isConnected || !_isMatched) return;
    
    try {
      await _hubConnection!.invoke('EndChat');
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isSystemMessage: true,
        content: '대화를 종료하고 새로운 상대를 찾습니다.',
      ));
      notifyListeners();
    } catch (e) {
      _logger.severe('Error ending chat: $e');
    }
  }
  
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
        _isConnected = false;
        _isMatched = false;
        _connectionStatus = '연결 끊김';
        _matchStatus = '매칭 없음';
        notifyListeners();
        _logger.info('Disconnected from server');
      } catch (e) {
        _logger.severe('Error disconnecting: $e');
      }
    }
  }
  
  @override
  void dispose() {
    disconnect();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

// 필요한 min 함수 정의
int min(int a, int b) => a < b ? a : b;