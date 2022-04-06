import 'package:dio/dio.dart';

import 'HttpResponse.dart';

abstract class HttpTransFormer {
  HttpResponse parse(Response response);
}

// 不同json 格式定制解析处理
class DefaultHttpTransFormer extends HttpTransFormer {
  @override
  HttpResponse parse(Response<dynamic> response) {
    return HttpResponse.success(response);
  }

  static DefaultHttpTransFormer _instance = DefaultHttpTransFormer._internal();

  DefaultHttpTransFormer._internal();

  factory DefaultHttpTransFormer.getInstance() => _instance;
}
