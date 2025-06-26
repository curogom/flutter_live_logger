import 'package:flutter/material.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

/// 가장 간단한 사용 예제
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 한 줄로 시작!
  await FlutterLiveLogger.start();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Logger Example',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Live Logger')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 가장 간단한 로깅
                FlutterLiveLogger.info('Button clicked!');
              },
              child: Text('Log Info'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 에러 로깅도 간단하게
                FlutterLiveLogger.error('Something went wrong!');
              },
              child: Text('Log Error'),
            ),
          ],
        ),
      ),
    );
  }
}

// 이게 전부입니다! 🎉