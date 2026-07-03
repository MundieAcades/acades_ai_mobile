class AppException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    required this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

class AuthException extends AppException {
  AuthException({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

class NetworkException extends AppException {
  NetworkException({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  ValidationException({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ServerException extends AppException {
  ServerException({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}
