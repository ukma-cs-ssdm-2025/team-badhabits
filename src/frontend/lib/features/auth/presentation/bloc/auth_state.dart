import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Base class for authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before authentication check
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication operation is in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
class Authenticated extends AuthState {
  const Authenticated(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State when authentication error occurs
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
