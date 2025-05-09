import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  final String serverUrl;
  final String defaultGender;
  
  const AppConfig({
    required this.serverUrl,
    required this.defaultGender,
  });
  
  factory AppConfig.defaults() {
    return const AppConfig(
      serverUrl: 'https://localhost:7115',
      defaultGender: 'male',
    );
  }
  
  static Future<AppConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    
    return AppConfig(
      serverUrl: prefs.getString('serverUrl') ?? 'https://localhost:7115',
      defaultGender: prefs.getString('defaultGender') ?? 'male',
    );
  }
  
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverUrl', serverUrl);
    await prefs.setString('defaultGender', defaultGender);
  }
  
  AppConfig copyWith({
    String? serverUrl,
    String? defaultGender,
  }) {
    return AppConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      defaultGender: defaultGender ?? this.defaultGender,
    );
  }
}