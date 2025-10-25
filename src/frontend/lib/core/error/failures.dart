import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// Server-side failure
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message: message);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message: message);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message: message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message: message);
}
