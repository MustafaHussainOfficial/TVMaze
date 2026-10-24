class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AppException($statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException()
      : super('No internet connection. Please check your network and try again.');
}

class TimeoutAppException extends AppException {
  const TimeoutAppException()
      : super('The server is taking too long to respond. Please try again.');
}

class NotFoundException extends AppException {
  const NotFoundException() : super('The requested content was not found.', statusCode: 404);
}

class ServerException extends AppException {
  const ServerException(int statusCode)
      : super('Something went wrong on the server ($statusCode).', statusCode: statusCode);
}

class ParsingException extends AppException {
  const ParsingException() : super('Received unexpected data from the server.');
}
