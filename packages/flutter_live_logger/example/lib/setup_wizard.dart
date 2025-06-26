import 'package:flutter/material.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

/// 대화형 설정 마법사
class SetupWizard extends StatefulWidget {
  @override
  _SetupWizardState createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  int currentStep = 0;

  // 사용자 선택사항
  bool isProduction = false;
  bool needsRemoteLogging = false;
  bool needsPersistence = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Live Logger 설정')),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 2) {
            setState(() => currentStep++);
          } else {
            _completeSetup();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() => currentStep--);
          }
        },
        steps: [
          Step(
            title: Text('환경 선택'),
            content: Column(
              children: [
                RadioListTile(
                  title: Text('개발 환경'),
                  subtitle: Text('콘솔 출력, 상세 로그'),
                  value: false,
                  groupValue: isProduction,
                  onChanged: (value) => setState(() => isProduction = value!),
                ),
                RadioListTile(
                  title: Text('프로덕션 환경'),
                  subtitle: Text('파일 저장, 최적화된 성능'),
                  value: true,
                  groupValue: isProduction,
                  onChanged: (value) => setState(() => isProduction = value!),
                ),
              ],
            ),
          ),
          Step(
            title: Text('원격 로깅'),
            content: Column(
              children: [
                SwitchListTile(
                  title: Text('서버로 로그 전송'),
                  subtitle: Text('API 엔드포인트가 필요합니다'),
                  value: needsRemoteLogging,
                  onChanged: (value) =>
                      setState(() => needsRemoteLogging = value),
                ),
              ],
            ),
          ),
          Step(
            title: Text('로컬 저장'),
            content: Column(
              children: [
                SwitchListTile(
                  title: Text('로그 파일로 저장'),
                  subtitle: Text('오프라인에서도 로그 보관'),
                  value: needsPersistence,
                  onChanged: (value) =>
                      setState(() => needsPersistence = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _completeSetup() {
    // 사용자 선택에 따른 코드 생성
    final code = _generateCode();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('설정 완료!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('아래 코드를 main.dart에 복사하세요:'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.grey[200],
              child: SelectableText(
                code,
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('완료'),
          ),
        ],
      ),
    );
  }

  String _generateCode() {
    if (!isProduction && !needsRemoteLogging && !needsPersistence) {
      return '''
await FlutterLiveLogger.startDevelopment();''';
    }

    final buffer = StringBuffer();
    buffer.writeln('await FlutterLiveLogger.init(');
    buffer.writeln('  config: LoggerConfig(');
    buffer
        .writeln('    logLevel: LogLevel.${isProduction ? "info" : "debug"},');
    buffer.writeln(
        '    environment: "${isProduction ? "production" : "development"}",');
    buffer.writeln('    transports: [');

    if (!isProduction) {
      buffer.writeln('      MemoryTransport(enableConsoleOutput: true),');
    }

    if (needsRemoteLogging) {
      buffer.writeln('      HttpTransport(');
      buffer.writeln('        config: HttpTransportConfig(');
      buffer.writeln('          endpoint: "YOUR_API_ENDPOINT",');
      buffer.writeln('          apiKey: "YOUR_API_KEY",');
      buffer.writeln('        ),');
      buffer.writeln('      ),');
    }

    if (needsPersistence) {
      buffer.writeln('      FileTransport(');
      buffer.writeln('        config: FileTransportConfig(');
      buffer.writeln('          directory: "/logs",');
      buffer.writeln('        ),');
      buffer.writeln('      ),');
    }

    buffer.writeln('    ],');
    buffer.writeln('  ),');
    buffer.writeln(');');

    return buffer.toString();
  }
}
