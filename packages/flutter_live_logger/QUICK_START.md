# 🚀 5분 안에 시작하기

## 1. 설치 (30초)
```yaml
dependencies:
  flutter_live_logger: ^0.2.0
```

## 2. 초기화 (10초)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 이게 전부입니다!
  await FlutterLiveLogger.start();
  
  runApp(MyApp());
}
```

## 3. 사용하기 (즉시)
```dart
// 정보 로그
FlutterLiveLogger.info('User logged in');

// 에러 로그
FlutterLiveLogger.error('Payment failed');

// 이벤트 추적
FlutterLiveLogger.event('button_clicked', {'screen': 'home'});
```

## 🎯 이게 전부입니다!

기본 설정으로:
- ✅ 개발 환경에서는 콘솔 출력
- ✅ 프로덕션에서는 파일 저장
- ✅ 자동 에러 포맷팅
- ✅ 메모리 효율적 관리

---

## 더 필요한가요?

### 🏢 프로덕션 설정 (선택사항)
```dart
// 프로덕션에 최적화된 설정
await FlutterLiveLogger.startProduction();
```

### 🌐 원격 서버로 전송 (선택사항)
```dart
await FlutterLiveLogger.init(
  config: LoggerConfig.production(
    transports: [
      HttpTransport.simple('https://your-api.com/logs'),
    ],
  ),
);
```

### 📱 화면 전환 추적 (선택사항)
```dart
MaterialApp(
  navigatorObservers: [
    FlutterLiveLoggerNavigatorObserver(),
  ],
  // ...
)
```

---

## 💡 팁

1. **VS Code 사용자**: `fll-` 입력하면 자동완성 제공
2. **디버깅**: 개발 중에는 콘솔에서 바로 확인
3. **성능**: 기본 설정으로도 400,000+ logs/sec 처리

## 🆘 도움말

- 문제가 있나요? [GitHub Issues](https://github.com/curogom/flutter_live_logger/issues)
- 예제가 필요하세요? [Example 폴더](./example)
- 고급 설정? [전체 문서](./README.md)