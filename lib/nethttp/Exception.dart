// 异常归档后创建
class HttpException implements Exception {
  final int? _code;

  int get code => _code ?? -1;
  final String? _message;

  String get message => _message ?? runtimeType.toString();

  // 中括号标识需要按照顺序 .
  HttpException([this._message, this._code]);

  String toString() {
    return 'HttpException{_code: $code, _message: $message}';
  }
}

// 客户端请求错误
class BadRequestException extends HttpException {
  BadRequestException({String? message, int? code}) : super(message, code);
}

//服务器请求错误
class BadServiceException extends HttpException {
  BadServiceException({String? message, int? code}) : super(message, code);
}

class UnknownException extends HttpException {
  UnknownException([String? message]) : super(message);
}

class CancelException extends HttpException {
  CancelException([String? message]) : super(message);
}

class NetworkException extends HttpException {
  NetworkException({String? message, int? code}) : super(message, code);
}

/// 401
class UnauthorisedException extends HttpException {
  UnauthorisedException({String? message, int? code = 401}) : super(message);
}

class BadResponseException extends HttpException{
  dynamic? data;
  BadResponseException([this.data]) : super();
}
