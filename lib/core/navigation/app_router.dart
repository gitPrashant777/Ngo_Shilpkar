import 'package:flutter/material.dart';

class AppRouter {
  /// Push a new screen onto the navigator stack.
  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Push a new screen and replace the current screen.
  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget screen) {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Push a new screen and remove all previous screens.
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget screen) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  /// Pop the current screen.
  static void pop<T>(BuildContext context, [T? result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop<T>(context, result);
    }
  }
}
