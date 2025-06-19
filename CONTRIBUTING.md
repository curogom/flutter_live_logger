# Contributing to Flutter Live Logger

Thank you for your interest in contributing to Flutter Live Logger! This document provides guidelines for contributing to the project.

## 🚀 Getting Started

### Prerequisites
- Flutter 3.16+ LTS
- Dart 3.0+
- Git
- Your favorite IDE (VS Code, IntelliJ, Android Studio)

### Setup Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/flutter_live_logger.git
   cd flutter_live_logger
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Setup**
   ```bash
   flutter test
   flutter analyze
   dart format --set-exit-if-changed .
   ```

4. **Run Example App**
   ```bash
   cd example
   flutter run
   ```

## 📋 Development Workflow

### Before You Start
1. Check existing [issues](https://github.com/your-username/flutter_live_logger/issues)
2. Create an issue for new features or bug reports
3. Fork the repository
4. Create a feature branch

### Making Changes

#### Code Standards
- **Formatting**: Use `dart format` before committing
- **Analysis**: Pass `flutter analyze` with no issues
- **Testing**: Maintain 95%+ test coverage
- **Documentation**: Update dartdoc comments for public APIs

#### Commit Convention
We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add real-time log streaming
fix: resolve memory leak in transport layer  
docs: update API documentation
test: add integration tests for WebSocket
refactor: improve error handling patterns
```

### Testing Requirements

#### Unit Tests
```bash
flutter test
```

#### Integration Tests
```bash
flutter test integration_test/
```

#### Coverage Report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Code Review Process

1. **Self Review**
   - Test your changes thoroughly
   - Check code formatting and analysis
   - Update documentation
   - Add/update tests

2. **Pull Request**
   - Use descriptive title and description
   - Link related issues
   - Include screenshots for UI changes
   - Add tests for new features

3. **Review Criteria**
   - Code quality and style
   - Test coverage
   - Documentation updates
   - Performance implications
   - Breaking changes (if any)

## 🎯 Project Standards

### Code Quality
- **Null Safety**: All code must be null safe
- **Type Safety**: Use strong typing throughout
- **Performance**: Optimize for minimal memory and CPU usage
- **Error Handling**: Graceful error handling with clear messages

### Architecture Guidelines
- **Plugin Architecture**: Maintain extensible transport system
- **Minimal Dependencies**: Avoid unnecessary external packages
- **Platform Support**: Ensure iOS, Android, Web, Desktop compatibility
- **Backwards Compatibility**: No breaking changes in minor versions

### Documentation Standards
- **API Documentation**: Comprehensive dartdoc for all public APIs
- **Usage Examples**: Provide clear usage examples
- **Parameters**: Document all parameters and return values
- **Version Notes**: Use `@since` and `@deprecated` annotations

## 🔧 Common Development Tasks

### Adding a New Transport
1. Create class extending `LogTransport`
2. Implement required methods
3. Add comprehensive tests
4. Update documentation
5. Add usage example

### Adding New Log Levels
1. Update `LogLevel` enum
2. Add corresponding methods
3. Update filtering logic
4. Add tests for new functionality
5. Update API documentation

### Performance Optimization
1. Profile with Flutter DevTools
2. Use `flutter analyze --suggestions`
3. Benchmark critical paths
4. Ensure < 50ms app startup impact
5. Monitor memory usage

## 🐛 Reporting Issues

### Bug Reports
Include the following information:
- Flutter/Dart version
- Platform (iOS/Android/Web/Desktop)
- Steps to reproduce
- Expected vs actual behavior
- Error logs/stack traces
- Minimal reproduction example

### Feature Requests
- Clear description of the feature
- Use cases and benefits
- Proposed API design (if applicable)
- Potential implementation approach

## 🌟 Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Help others learn and grow
- Provide constructive feedback
- Follow our [Code of Conduct](CODE_OF_CONDUCT.md)

### Communication
- Use clear, descriptive language
- Be patient with newcomers
- Share knowledge and best practices
- Ask questions when unclear

## 📚 Resources

### Documentation
- [API Reference](https://pub.dev/documentation/flutter_live_logger/latest/)
- [Architecture Guide](docs/architecture.md)
- [Performance Guide](docs/performance.md)
- [Troubleshooting](docs/troubleshooting.md)

### Development Tools
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Dart Analyzer](https://dart.dev/guides/language/analysis-options)
- [pub.dev Scoring](https://pub.dev/help/scoring)

### Learning Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

## ✅ Checklist for Contributors

Before submitting a PR:
- [ ] Code follows project style guidelines
- [ ] Tests pass locally
- [ ] Code coverage maintained/improved
- [ ] Documentation updated
- [ ] Breaking changes documented
- [ ] Examples updated (if needed)
- [ ] Performance impact considered
- [ ] Cross-platform compatibility verified

## 🎉 Recognition

Contributors will be:
- Listed in our [Contributors](CONTRIBUTORS.md) file
- Mentioned in release notes
- Invited to join our Discord community
- Eligible for maintainer status (active contributors)

Thank you for contributing to Flutter Live Logger! 🚀 