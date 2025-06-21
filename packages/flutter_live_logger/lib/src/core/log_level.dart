/// Log severity levels supported by Flutter Live Logger
///
/// Follows standard logging conventions with trace being the most verbose
/// and fatal being the most severe.
enum LogLevel {
  /// Very detailed debugging information
  trace(0, 'TRACE'),

  /// Detailed debugging information
  debug(1, 'DEBUG'),

  /// Informational messages about general application flow
  info(2, 'INFO'),

  /// Warning messages about potentially harmful situations
  warn(3, 'WARN'),

  /// Error messages about error conditions but app continues
  error(4, 'ERROR'),

  /// Fatal messages about very severe error events
  fatal(5, 'FATAL');

  const LogLevel(this.level, this.name);

  /// Numeric level for comparison
  final int level;

  /// String representation
  final String name;

  /// Returns true if this level is enabled for the given minimum level
  bool isEnabledFor(LogLevel minimumLevel) {
    return level >= minimumLevel.level;
  }
}
