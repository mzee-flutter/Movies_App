class AppException implements Exception {
  final String _message;
  final String _prefix;

  AppException(
    this._message,
    this._prefix,
  );
  @override
  String toString() {
    return '$_message, $_prefix';
  }
}

class FetchDataException extends AppException {
  FetchDataException(String? message)
      : super(message!, 'Error during Communication');
}

class BadRequestException extends AppException {
  BadRequestException(String? message) : super(message!, 'Invalid request');
}

class UnauthorizedRequestException extends AppException {
  UnauthorizedRequestException(String? message)
      : super(message!, 'Unauthorized request exception');
}

class TimeOutRequestException extends AppException {
  TimeOutRequestException(String? message)
      : super(message!, 'server request timeOut');
}
