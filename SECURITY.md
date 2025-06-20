# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

The Flutter Live Logger team takes security bugs seriously. We appreciate your efforts to responsibly disclose your findings, and will make every effort to acknowledge your contributions.

### How to Report Security Issues

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to:

**📧 <i_am@curogom.dev>**

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include the following information in your report:

- **Type of issue** (e.g. buffer overflow, SQL injection, cross-site scripting, etc.)
- **Full paths** of source file(s) related to the manifestation of the issue
- **Location** of the affected source code (tag/branch/commit or direct URL)
- **Configuration** required to reproduce the issue
- **Step-by-step instructions** to reproduce the issue
- **Proof-of-concept or exploit code** (if possible)
- **Impact** of the issue, including how an attacker might exploit the issue

### Security Response Process

1. **Initial Response**: We will confirm receipt of your vulnerability report within 48 hours.

2. **Assessment**: Our team will assess the vulnerability and determine its impact and severity.

3. **Fix Development**: We will develop a fix for the vulnerability.

4. **Testing**: The fix will be thoroughly tested to ensure it resolves the issue without introducing new problems.

5. **Release**: We will release a new version containing the fix.

6. **Disclosure**: We will publicly disclose the vulnerability in a responsible manner after the fix is released.

### Security Best Practices for Users

When using Flutter Live Logger in production:

- **Keep Updated**: Always use the latest version of Flutter Live Logger
- **Secure Configuration**: Review your transport configurations, especially for HTTP transport
- **Data Sensitivity**: Avoid logging sensitive data like passwords, API keys, or personal information
- **Network Security**: Use HTTPS endpoints for HTTP transport
- **Storage Security**: Consider encryption for SQLite storage if logging sensitive application data

### Scope

This security policy applies to:

- **Core Library**: All code in the `lib/` directory
- **Dependencies**: Security issues in direct dependencies
- **Examples**: Security issues in example applications that could mislead users

### Exclusions

The following are outside the scope of this security policy:

- **Development Dependencies**: Issues only affecting development/testing dependencies
- **Example Apps**: Non-security bugs in example applications
- **Configuration Issues**: Security issues caused by user misconfiguration (though we may provide guidance)

## Contact

- **Security Email**: <i_am@curogom.dev>
- **General Issues**: [GitHub Issues](https://github.com/curogom/flutter_live_logger/issues)
- **Repository**: [GitHub](https://github.com/curogom/flutter_live_logger)

---

**Thank you for helping keep Flutter Live Logger and our users safe!**
