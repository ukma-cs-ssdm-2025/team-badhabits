import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check current authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event to sign in a user
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign up a new user
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final UserType userType;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
  });

  @override
  List<Object?> get props => [email, password, name, userType];
}

/// Event to sign out the current user
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Event when authentication state changes
class AuthStateChanged extends AuthEvent {
  final UserEntity? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
