import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'screens/chat_screen.dart';
import 'services/chat_service.dart';
import 'services/storage_service.dart';
import 'utils/logger.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 로거 초기화
  setupLogger();
  
  // 서비스 등록
  await setupServices();
  
  runApp(const MyApp());
}

Future<void> setupServices() async {
  // 싱글톤 서비스 등록
  getIt.registerSingleton<StorageService>(StorageService());
  
  // Storage 서비스 초기화 대기
  await getIt<StorageService>().init();
  
  // 설정 로드
  final config = await AppConfig.load();
  
  getIt.registerSingleton<AppConfig>(config);
  getIt.registerSingleton<ChatService>(ChatService());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<ChatService>(),
      child: MaterialApp(
        title: '채팅 클라이언트',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        home: const ChatScreen(),
      ),
    );
  }
}