

import 'Exception.dart';

class HttpResponse {
  late bool ok;
  dynamic? data; // 具体请求数据
  HttpException? error; // 异常顺序

  HttpResponse._internal({this.ok = false});

  HttpResponse.success(this.data) {
    this.ok = true;
  }

  // 网络产生的错误
  HttpResponse.failure([String? errorMsg, int? errorCode]) {
    this.error = BadRequestException(message: errorMsg, code: errorCode);
    this.ok = false;
  }

  // 获取数据 (请求服务器所产生的错误)
  HttpResponse.failureFormResponse({dynamic? data}) {
    this.error = BadResponseException(data);
    this.ok = false;
  }

  HttpResponse.failureFromError([HttpException? error]) {
    this.error = error ?? UnknownException();
    this.ok = false;
  }
}