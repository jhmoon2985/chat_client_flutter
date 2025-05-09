import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client_config.dart';

class StorageService {
  final Logger _logger = Logger('StorageService');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  Future<ClientConfig?> getClientConfig() async {
    try {
      // 민감한 정보인 clientId는 보안 저장소에서 가져옴
      final clientId = await _secureStorage.read(key: 'clientId');
      
      // 일반 설정은 SharedPreferences에서 가져옴
      final serverUrl = _prefs?.getString('serverUrl');
      final selectedGender = _prefs?.getString('selectedGender');
      
      if (clientId != null || serverUrl != null || selectedGender != null) {
        return ClientConfig(
          clientId: clientId,
          serverUrl: serverUrl,
          selectedGender: selectedGender,
        );
      }
      
      return null;
    } catch (e) {
      _logger.severe('Error retrieving client config: $e');
      return null;
    }
  }
  
  Future<void> saveClientConfig(ClientConfig config) async {
    try {
      // 민감한 정보인 clientId는 보안 저장소에 저장
      if (config.clientId != null) {
        await _secureStorage.write(key: 'clientId', value: config.clientId);
      }
      
      // 일반 설정은 SharedPreferences에 저장
      if (config.serverUrl != null) {
        await _prefs?.setString('serverUrl', config.serverUrl!);
      }
      
      if (config.selectedGender != null) {
        await _prefs?.setString('selectedGender', config.selectedGender!);
      }
    } catch (e) {
      _logger.severe('Error saving client config: $e');
    }
  }
  
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      await _prefs?.clear();
    } catch (e) {
      _logger.severe('Error clearing storage: $e');
    }
  }
}