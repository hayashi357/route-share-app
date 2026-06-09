class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(String message, {String? code}) : super(message, code: code);
}

class UserException extends AppException {
  UserException(String message, {String? code}) : super(message, code: code);
}

class RouteException extends AppException {
  RouteException(String message, {String? code}) : super(message, code: code);
}

class PhotoException extends AppException {
  PhotoException(String message, {String? code}) : super(message, code: code);
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code}) : super(message, code: code);
}
