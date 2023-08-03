class NoConnectionException implements Exception {
  final String message;

  NoConnectionException(this.message);

  @override
  String toString() => message;
}

class NoResponseException implements Exception {
  final String message;

  NoResponseException(this.message);

  @override
  String toString() => message;
}

class ThrottledRequestException implements Exception {
  final String message;

  ThrottledRequestException(this.message);

  @override
  String toString() => message;
}