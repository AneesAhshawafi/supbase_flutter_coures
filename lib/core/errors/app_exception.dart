/// Base application exception with a human-readable [message].
class AppException implements Exception {
  final String message;
  final Object? originalError;

  const AppException(this.message, {this.originalError});

  @override
  String toString() => message;
}

/// Thrown when a Supabase database operation fails.
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.originalError});
}

/// Thrown when a Supabase storage operation fails.
class StorageException extends AppException {
  const StorageException(super.message, {super.originalError});
}

/// Thrown when an authentication operation fails.
class AuthException extends AppException {
  const AuthException(super.message, {super.originalError});
}
