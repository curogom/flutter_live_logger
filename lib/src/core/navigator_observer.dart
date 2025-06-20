/// Flutter Live Logger - Navigator Observer
///
/// Automatically tracks screen navigation events and logs them.
/// Provides insights into user navigation patterns and screen transitions.
///
/// Example:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     FlutterLiveLoggerNavigatorObserver(),
///   ],
///   // ... rest of app configuration
/// );
/// ```

import 'package:flutter/material.dart';
import 'flutter_live_logger.dart';

/// Navigator observer that automatically logs screen transitions
///
/// Features:
/// - Automatic logging of page pushes, pops, and replacements
/// - Screen duration tracking
/// - Navigation breadcrumb tracking
/// - Configurable filtering and custom naming
class FlutterLiveLoggerNavigatorObserver extends NavigatorObserver {
  final Map<Route<dynamic>, DateTime> _routeStartTimes = {};
  final List<String> _navigationBreadcrumbs = [];
  final bool _enableDurationTracking;
  final bool _enableBreadcrumbs;
  final int _maxBreadcrumbs;
  final String Function(Route<dynamic>)? _routeNameExtractor;
  final bool Function(Route<dynamic>)? _shouldLogRoute;

  /// Create a navigator observer with configuration options
  ///
  /// [enableDurationTracking] Whether to track how long users spend on each screen
  /// [enableBreadcrumbs] Whether to maintain navigation breadcrumbs
  /// [maxBreadcrumbs] Maximum number of breadcrumbs to keep
  /// [routeNameExtractor] Custom function to extract route names
  /// [shouldLogRoute] Function to filter which routes should be logged
  FlutterLiveLoggerNavigatorObserver({
    bool enableDurationTracking = true,
    bool enableBreadcrumbs = true,
    int maxBreadcrumbs = 10,
    String Function(Route<dynamic>)? routeNameExtractor,
    bool Function(Route<dynamic>)? shouldLogRoute,
  })  : _enableDurationTracking = enableDurationTracking,
        _enableBreadcrumbs = enableBreadcrumbs,
        _maxBreadcrumbs = maxBreadcrumbs,
        _routeNameExtractor = routeNameExtractor,
        _shouldLogRoute = shouldLogRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (!_shouldLog(route)) return;

    final routeName = _getRouteName(route);
    final now = DateTime.now();

    if (_enableDurationTracking) {
      _routeStartTimes[route] = now;
    }

    if (_enableBreadcrumbs) {
      _addToBreadcrumbs(routeName);
    }

    FlutterLiveLogger.event('screen_push', {
      'screen_name': routeName,
      'previous_screen':
          previousRoute != null ? _getRouteName(previousRoute) : null,
      'navigation_type': 'push',
      'timestamp': now.toIso8601String(),
      'breadcrumbs':
          _enableBreadcrumbs ? List<String>.from(_navigationBreadcrumbs) : null,
      'route_type': route.runtimeType.toString(),
    });

    FlutterLiveLogger.info('Screen pushed: $routeName');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    if (!_shouldLog(route)) return;

    final routeName = _getRouteName(route);
    final now = DateTime.now();

    Map<String, dynamic> eventData = {
      'screen_name': routeName,
      'next_screen':
          previousRoute != null ? _getRouteName(previousRoute) : null,
      'navigation_type': 'pop',
      'timestamp': now.toIso8601String(),
      'breadcrumbs':
          _enableBreadcrumbs ? List<String>.from(_navigationBreadcrumbs) : null,
      'route_type': route.runtimeType.toString(),
    };

    // Add duration tracking if enabled
    if (_enableDurationTracking && _routeStartTimes.containsKey(route)) {
      final startTime = _routeStartTimes.remove(route)!;
      final duration = now.difference(startTime);
      eventData['screen_duration_ms'] = duration.inMilliseconds;
      eventData['screen_duration_readable'] = _formatDuration(duration);
    }

    if (_enableBreadcrumbs) {
      _removeFromBreadcrumbs(routeName);
    }

    FlutterLiveLogger.event('screen_pop', eventData);
    FlutterLiveLogger.info('Screen popped: $routeName');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    if (newRoute == null || !_shouldLog(newRoute)) return;

    final newRouteName = _getRouteName(newRoute);
    final oldRouteName = oldRoute != null ? _getRouteName(oldRoute) : null;
    final now = DateTime.now();

    // Handle duration tracking for replaced route
    if (_enableDurationTracking && oldRoute != null) {
      if (_routeStartTimes.containsKey(oldRoute)) {
        _routeStartTimes.remove(oldRoute);
      }
      _routeStartTimes[newRoute] = now;
    }

    if (_enableBreadcrumbs) {
      if (oldRouteName != null) {
        _removeFromBreadcrumbs(oldRouteName);
      }
      _addToBreadcrumbs(newRouteName);
    }

    FlutterLiveLogger.event('screen_replace', {
      'new_screen': newRouteName,
      'old_screen': oldRouteName,
      'navigation_type': 'replace',
      'timestamp': now.toIso8601String(),
      'breadcrumbs':
          _enableBreadcrumbs ? List<String>.from(_navigationBreadcrumbs) : null,
      'new_route_type': newRoute.runtimeType.toString(),
      'old_route_type': oldRoute?.runtimeType.toString(),
    });

    FlutterLiveLogger.info('Screen replaced: $oldRouteName → $newRouteName');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    if (!_shouldLog(route)) return;

    final routeName = _getRouteName(route);

    // Clean up tracking data
    if (_enableDurationTracking) {
      _routeStartTimes.remove(route);
    }

    if (_enableBreadcrumbs) {
      _removeFromBreadcrumbs(routeName);
    }

    FlutterLiveLogger.event('screen_remove', {
      'screen_name': routeName,
      'previous_screen':
          previousRoute != null ? _getRouteName(previousRoute) : null,
      'navigation_type': 'remove',
      'timestamp': DateTime.now().toIso8601String(),
      'route_type': route.runtimeType.toString(),
    });

    FlutterLiveLogger.debug('Screen removed: $routeName');
  }

  /// Get the name of a route for logging
  String _getRouteName(Route<dynamic> route) {
    // Use custom extractor if provided
    if (_routeNameExtractor != null) {
      try {
        return _routeNameExtractor!(route);
      } catch (e) {
        // Fall back to default if custom extractor fails
      }
    }

    // Try to get route name from settings
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      return route.settings.name!;
    }

    // Try to extract from route type
    final routeType = route.runtimeType.toString();
    if (routeType.contains('MaterialPageRoute') ||
        routeType.contains('CupertinoPageRoute')) {
      // Try to get widget type name
      try {
        final routeString = route.toString();
        final match = RegExp(r'<(.+?)>').firstMatch(routeString);
        if (match != null) {
          return match.group(1) ?? 'UnknownWidget';
        }
      } catch (e) {
        // Ignore extraction errors
      }
    }

    // Default fallback
    return routeType.replaceAll('Route', '').replaceAll('<dynamic>', '');
  }

  /// Check if a route should be logged
  bool _shouldLog(Route<dynamic> route) {
    // Use custom filter if provided
    if (_shouldLogRoute != null) {
      try {
        return _shouldLogRoute!(route);
      } catch (e) {
        // Default to logging if custom filter fails
        return true;
      }
    }

    // Default: log all named routes and page routes
    return route.settings.name != null ||
        route is PageRoute ||
        route is PopupRoute;
  }

  /// Add route to breadcrumbs
  void _addToBreadcrumbs(String routeName) {
    _navigationBreadcrumbs.add(routeName);

    // Maintain max breadcrumbs limit
    while (_navigationBreadcrumbs.length > _maxBreadcrumbs) {
      _navigationBreadcrumbs.removeAt(0);
    }
  }

  /// Remove route from breadcrumbs
  void _removeFromBreadcrumbs(String routeName) {
    // Remove the last occurrence of this route
    for (int i = _navigationBreadcrumbs.length - 1; i >= 0; i--) {
      if (_navigationBreadcrumbs[i] == routeName) {
        _navigationBreadcrumbs.removeAt(i);
        break;
      }
    }
  }

  /// Format duration in a readable way
  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else if (duration.inSeconds > 0) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMilliseconds}ms';
    }
  }

  /// Get current navigation breadcrumbs
  List<String> get breadcrumbs => List.unmodifiable(_navigationBreadcrumbs);

  /// Get navigation statistics
  Map<String, dynamic> getNavigationStats() {
    return {
      'active_routes': _routeStartTimes.length,
      'breadcrumbs_count': _navigationBreadcrumbs.length,
      'current_breadcrumbs': List<String>.from(_navigationBreadcrumbs),
      'duration_tracking_enabled': _enableDurationTracking,
      'breadcrumbs_enabled': _enableBreadcrumbs,
    };
  }

  /// Clear all tracking data (useful for testing)
  void clearTrackingData() {
    _routeStartTimes.clear();
    _navigationBreadcrumbs.clear();
  }
}
