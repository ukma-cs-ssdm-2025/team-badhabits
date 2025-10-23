/**
 * Widget Tests - Login Screen
 *
 * Tests UI interactions and validation:
 * - Form rendering
 * - Email validation
 * - Password validation
 * - Button interactions
 * - State changes (password visibility toggle)
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('Login Screen Widget Tests', () {
    testWidgets('Test 1: Login form renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const LoginForm(),
        ),
      );

      // Verify all UI elements are present
      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      expect(find.text('Login'), findsWidgets);

      debugPrint('✓ Test 1 PASSED: All UI elements found');
    });

    testWidgets('Test 2: Email validation with invalid input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const LoginForm(),
        ),
      );

      // Enter invalid email
      await tester.enterTextAndSettle(
        find.byKey(const Key('emailField')),
        'invalid-email',
      );

      // Trigger validation by tapping login
      await tester.tapAndSettle(find.byKey(const Key('loginButton')));

      // Verify error message appears
      expect(find.text('Invalid email format'), findsOneWidget);
      debugPrint('✓ Test 2 PASSED: Email validation works');
    });

    testWidgets('Test 3: Password validation with short password',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const LoginForm(),
        ),
      );

      // Enter valid email but short password
      await tester.enterTextAndSettle(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );
      await tester.enterTextAndSettle(
        find.byKey(const Key('passwordField')),
        '12345',
      );

      // Trigger validation
      await tester.tapAndSettle(find.byKey(const Key('loginButton')));

      // Verify password error
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      debugPrint('✓ Test 3 PASSED: Password validation works');
    });

    testWidgets('Test 4: Login button tap with valid credentials',
        (WidgetTester tester) async {
      bool loginCalled = false;

      await tester.pumpWidget(
        createTestableWidget(
          LoginForm(
            onLogin: (email, password) {
              loginCalled = true;
              debugPrint('Login callback invoked with $email');
            },
          ),
        ),
      );

      // Enter valid credentials
      await tester.enterTextAndSettle(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );
      await tester.enterTextAndSettle(
        find.byKey(const Key('passwordField')),
        'password123',
      );

      // Tap login button
      await tester.tapAndSettle(find.byKey(const Key('loginButton')));

      // Verify login callback was called
      expect(loginCalled, isTrue);
      debugPrint('✓ Test 4 PASSED: Login callback invoked');
    });

    testWidgets('Test 5: Password visibility toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const LoginForm(),
        ),
      );

      // Find password field
      final passwordField =
          tester.widget<TextField>(find.byKey(const Key('passwordField')));

      // Initially obscured
      expect(passwordField.obscureText, isTrue);

      // Tap visibility icon
      await tester.tapAndSettle(find.byIcon(Icons.visibility));

      // Password should be visible now
      final updatedPasswordField =
          tester.widget<TextField>(find.byKey(const Key('passwordField')));
      expect(updatedPasswordField.obscureText, isFalse);

      debugPrint('✓ Test 5 PASSED: Password visibility toggled');
    });
  });
}

// ====================Mock Login Form Widget ====================

class LoginForm extends StatefulWidget {
  final void Function(String email, String password)? onLogin;

  const LoginForm({super.key, this.onLogin});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  void _validateAndSubmit() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Email validation
    if (!_emailController.text.contains('@')) {
      setState(() {
        _emailError = 'Invalid email format';
      });
      return;
    }

    // Password validation
    if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      return;
    }

    // Call callback
    widget.onLogin?.call(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            key: const Key('emailField'),
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: _emailError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('passwordField'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _passwordError,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('loginButton'),
            onPressed: _validateAndSubmit,
            child: const Text('Login'),
          ),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
