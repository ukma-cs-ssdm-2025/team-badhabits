/**
 * Test Helper Functions
 * Lab 6: Testing & Debugging
 *
 * Helper utilities for widget testing with interactions
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extension methods for WidgetTester to simplify common test interactions
extension WidgetTesterExtensions on WidgetTester {
  /// Enter text into a text field and wait for animations to settle
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  /// Tap on a widget and wait for animations to settle
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Scroll until a widget is visible
  Future<void> scrollUntilVisible(
    Finder finder,
    double delta, {
    Finder? scrollable,
  }) async {
    final itemFinder = finder;
    final listFinder = scrollable ?? find.byType(Scrollable).first;

    await scrollUntilVisible(
      itemFinder,
      delta,
      scrollable: listFinder,
    );
  }

  /// Wait for a specific duration
  Future<void> waitFor(Duration duration) async {
    await pump(duration);
    await pumpAndSettle();
  }
}

/// Helper function to create a Material app wrapper for widget testing
Widget createTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

/// Helper function to create a Material app with routing for integration tests
MaterialApp createTestableApp({
  required Widget home,
  Map<String, WidgetBuilder>? routes,
}) {
  return MaterialApp(
    home: home,
    routes: routes ?? {},
  );
}

/// Mock data helpers
class MockData {
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testUserId = 'test_user_id_123';
  static const String testUserName = 'Test User';

  static Map<String, dynamic> noteJson(String id) => {
        'id': id,
        'title': 'Test Note $id',
        'content': 'This is test content for note $id',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
}

/// Custom matchers
Matcher findsNWidgets(int count) => findsNWidgets(count);

/// Helper to verify text field has error
bool textFieldHasError(WidgetTester tester, Key key) {
  final textField = tester.widget<TextField>(find.byKey(key));
  return textField.decoration?.errorText != null;
}

/// Helper to get text field error message
String? getTextFieldError(WidgetTester tester, Key key) {
  final textField = tester.widget<TextField>(find.byKey(key));
  return textField.decoration?.errorText;
}
