import 'package:logging/logging.dart';

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    
    if (record.error != null) {
      // ignore: avoid_print
      print('Error: ${record.error}');
    }
    
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('Stack trace: ${record.stackTrace}');
    }
  });
}