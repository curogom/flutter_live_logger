# Contributing to Flutter Live Logger

Flutter Live Logger에 기여해주셔서 감사합니다! 이 가이드는 프로젝트에 효과적으로 기여하는 방법을 설명합니다.

## 🚀 시작하기

### 개발 환경 설정

1. **저장소 포크 및 클론**

```bash
git clone https://github.com/your-username/flutter_live_logger.git
cd flutter_live_logger
```

2. **Flutter 환경 확인**

```bash
flutter doctor -v
flutter --version  # 3.16.0 이상 필요
```

3. **의존성 설치**

```bash
flutter pub get
```

4. **테스트 실행**

```bash
flutter test
```

## 🔄 브랜치 전략 및 워크플로우

### 브랜치 보호 규칙

**main 브랜치**는 다음 규칙으로 보호됩니다:

- ✅ **직접 푸시 금지** - 모든 변경사항은 PR을 통해서만 가능
- ✅ **리뷰 필수** - 최소 1명의 승인 필요 (코드 소유자)
- ✅ **CI 통과 필수** - 모든 검증이 성공해야 머지 가능
- ✅ **브랜치 최신화** - 머지 전 main과 동기화 필요
- ✅ **관리자도 동일 규칙** - 예외 없음

### 워크플로우

1. **이슈 생성** (선택사항이지만 권장)
   - 🐛 버그 리포트
   - ✨ 기능 요청
   - 📚 문서 개선

2. **브랜치 생성**

```bash
git checkout -b feature/your-feature-name
# 또는
git checkout -b fix/bug-description
```

3. **개발 및 테스트**

```bash
# 코드 작성
# 테스트 추가/수정
flutter test
flutter analyze
dart format .
```

4. **커밋**

```bash
git add lib/specific-files.dart  # git add . 사용 금지
git commit -m "feat: add new logging transport"
```

5. **푸시 및 PR 생성**

```bash
git push origin feature/your-feature-name
# GitHub에서 PR 생성
```

## 📋 PR 체크리스트

### ✅ 제출 전 확인사항

**코드 품질:**

- [ ] `flutter analyze` 통과
- [ ] `dart format .` 적용
- [ ] 새 기능에 대한 테스트 추가
- [ ] 기존 테스트 모두 통과
- [ ] 테스트 커버리지 95% 이상 유지

**문서:**

- [ ] dartdoc 주석 추가 (public API)
- [ ] README 업데이트 (필요시)
- [ ] CHANGELOG.md 업데이트
- [ ] 예제 코드 제공

**호환성:**

- [ ] Breaking change 여부 명시
- [ ] 플랫폼 호환성 확인
- [ ] 의존성 변경 최소화

### 🤖 자동 검증

PR 생성 시 다음이 자동으로 실행됩니다:

1. **코드 분석** - Flutter analyze
2. **테스트 실행** - 모든 테스트 통과 확인
3. **커버리지 측정** - 95% 이상 유지
4. **포맷 검사** - dart format 규칙 준수
5. **패키지 검증** - pub.dev 호환성
6. **PR 크기 검사** - 적절한 크기 권장
7. **의존성 검사** - 변경사항 추적

## 💡 기여 가이드라인

### 🎯 코드 스타일

```dart
// ✅ 좋은 예시
/// HTTP를 통해 로그를 전송하는 Transport 구현
/// 
/// 압축, 재시도, 배치 처리를 지원합니다.
/// 
/// Example:
/// ```dart
/// final transport = HttpTransport(
///   config: HttpTransportConfig(
///     endpoint: 'https://api.example.com/logs',
///     apiKey: 'your-key',
///   ),
/// );
/// ```
class HttpTransport implements LogTransport {
  // 구현...
}
```

### 🔒 보안 고려사항

- API 키는 절대 하드코딩하지 마세요
- 민감한 데이터 로깅 방지
- 입력 검증 철저히
- 의존성 보안 취약점 확인

### 📱 플랫폼 호환성

지원 플랫폼에서 테스트해주세요:

- Android (최소 API 21)
- iOS (최소 iOS 12)
- Web (Chrome, Safari, Firefox)
- Desktop (Windows, macOS, Linux)

### 🎨 API 설계 원칙

1. **일관성** - 기존 API 패턴 따르기
2. **단순성** - 복잡한 것을 간단하게
3. **확장성** - 미래 확장 고려
4. **타입 안전성** - null safety 준수
5. **성능** - 메모리와 CPU 효율적

## 🐛 버그 리포트

### 좋은 버그 리포트의 조건

1. **재현 가능한 단계**
2. **예상 vs 실제 동작**
3. **환경 정보** (Flutter/Dart 버전, 플랫폼)
4. **최소 재현 코드**
5. **관련 로그/스택 트레이스**

### 🔍 버그 조사 흐름

1. 기존 이슈 검색
2. 최신 버전에서 재현 확인
3. 문제 분리 (minimal reproduction)
4. 이슈 템플릿 사용하여 신고

## ✨ 기능 요청

### 좋은 기능 요청의 조건

1. **명확한 사용 사례**
2. **구체적인 API 제안**
3. **대안 검토**
4. **Breaking change 여부**
5. **구현 복잡도 추정**

### 🎯 우선순위 기준

- 🔥 **High**: 많은 사용자에게 영향
- 📈 **Medium**: 특정 use case 개선
- 💡 **Low**: Nice to have 기능

## 🔧 개발 팁

### 로컬 테스트

```bash
# 전체 테스트 실행
flutter test

# 특정 파일 테스트
flutter test test/flutter_live_logger_test.dart

# 커버리지와 함께 테스트
flutter test --coverage

# pub.dev 호환성 검사
dart pub publish --dry-run
```

### 성능 측정

```bash
# 예제 앱으로 성능 테스트
cd example
flutter run --profile
```

### 디버깅

```dart
// 디버그 모드에서만 실행되는 로그
assert(() {
  print('Debug: 로그 전송 시작');
  return true;
}());
```

## 📞 도움 요청

### 🤝 커뮤니티 채널

- **GitHub Issues**: 버그 리포트, 기능 요청
- **GitHub Discussions**: 질문, 아이디어 공유
- **Email**: <i_am@curogom.dev> (보안 이슈)

### 💬 질문하기 전에

1. 문서 확인 (README, API docs)
2. 기존 이슈/토론 검색
3. 예제 코드 살펴보기
4. pub.dev 페이지 확인

## 🎉 기여자 인정

모든 기여자는 다음과 같이 인정받습니다:

1. **CONTRIBUTORS.md** 파일에 이름 추가
2. **README.md** contributors 섹션
3. **GitHub contributors** 탭
4. **릴리스 노트**에서 언급

### 기여 유형

- 💻 **Code**: 버그 수정, 기능 개발
- 📖 **Documentation**: 문서 개선
- 🎨 **Design**: UI/UX 개선
- 🤔 **Ideas**: 아이디어 제안
- 🚧 **Maintenance**: 프로젝트 유지보수
- 👀 **Review**: 코드 리뷰
- 🔍 **Testing**: 테스트 작성/개선
- 🌍 **Translation**: 다국어 지원

## 🚀 릴리스 프로세스

### 버전 관리 (Semantic Versioning)

- `1.0.0` - Major (Breaking changes)
- `0.1.0` - Minor (New features)
- `0.0.1` - Patch (Bug fixes)

### 릴리스 흐름

1. **개발** - feature/fix 브랜치에서 작업
2. **PR 리뷰** - 코드 품질 검토
3. **머지** - main 브랜치로 병합
4. **릴리스** - 버전 태그 및 pub.dev 출시

## 📝 라이선스

기여함으로써 당신의 기여가 [MIT License](LICENSE)에 따라 라이선스됨에 동의합니다.

---

**다시 한번 감사합니다!** 🙏 Flutter Live Logger가 더 나은 라이브러리가 될 수 있도록 도와주세요.

질문이 있으시면 언제든지 [이슈를 생성](https://github.com/curogom/flutter_live_logger/issues/new/choose)하거나 [이메일](mailto:i_am@curogom.dev)로 연락해주세요!
