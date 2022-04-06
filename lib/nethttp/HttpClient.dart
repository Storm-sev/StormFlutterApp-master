import 'dart:io';

import 'package:dio/dio.dart';

import 'AppNet.dart';
import 'Exception.dart';
import 'Http.dart';
import 'HttpResponse.dart';
import 'TransFormer.dart';

class HttpClient {
  late AppNet _dio;

  HttpClient({BaseOptions? options, HttpConfig? config})
      : _dio = AppNet(options: options, config: config);

  AppNet get dio => _dio;



  void headers(Map<String, dynamic> headers) {
    // _dio.headers(headers);

    dio.options.headers.addAll(headers);

  }

  Future<HttpResponse> get<T>(String url,
      {Map<String, dynamic>? queryParamsters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiverProgress,
      HttpTransFormer? httpTransFormer}) async {
    try {
      Response response = await _dio.get<T>(url,
          queryParameters: queryParamsters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiverProgress);
      return handleResponse(response, httpTransFormer: httpTransFormer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  // post 请求
  Future<HttpResponse> post(String url,
      {data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress,
      HttpTransFormer? httpTransFormer}) async {
    try {
      var response = await _dio.post(url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      return handleResponse(response, httpTransFormer: httpTransFormer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<HttpResponse> patch(String url,
      {data,
      Map<String, dynamic>? queryParamsters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress,
      HttpTransFormer? httpTransFormer}) async {
    try {
      var response = await _dio.patch(url,
          data: data,
          queryParameters: queryParamsters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      return handleResponse(response);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<HttpResponse> delete(String url,
      {data,
      Map<String, dynamic>? queryParamsters,
      Options? options,
      CancelToken? cancelToken,
      HttpTransFormer? httpTransFormer}) async {
    try {
      var response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParamsters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse(response);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<HttpResponse> put(String url,
      {data,
      Map<String, dynamic>? queryParamsters,
      Options? options,
      CancelToken? cancelToken,
      HttpTransFormer? httpTransFormer}) async {
    try {
      var response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParamsters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse(response);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<Response> download(String urlPath, savePath,
      {ProgressCallback? onReceiveProgress,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      bool deleteOnError = true,
      String lengthHeader = Headers.contentLengthHeader,
      data,
      Options? options,
      HttpTransFormer? httpTransFormer}) async {
    try {
      var response = await _dio.download(urlPath, savePath,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          deleteOnError: deleteOnError,
          lengthHeader: lengthHeader,
          data: data,
          options: options);
      return response;
    } catch (e) {
      throw e;
    }
  }

  // 响应体处理
  HttpResponse handleResponse(Response? response,
      {HttpTransFormer? httpTransFormer}) {
    httpTransFormer ??= DefaultHttpTransFormer.getInstance();

    // 是否为null
    if (null == response) {
      return HttpResponse.failureFromError();
    }
    if (_isTokenTimeout(response.statusCode)) {
      return HttpResponse.failureFromError(
          UnauthorisedException(message: "token失效"));
    }
    // 接口调用成功

    if (_isRequestSuccess(response.statusCode)) {
      return httpTransFormer.parse(response);
    } else {
      return HttpResponse.failure(response.statusMessage, response.statusCode);
    }
  }

  /// 鉴权失败
  bool _isTokenTimeout(int? code) {
    return code == 401;
  }

  bool _isRequestSuccess(int? statusCode) {
    return (null != statusCode && statusCode >= 200 && statusCode < 300);
  }

  HttpResponse handleException(Exception exception) {
    var parseException = _parseException(exception);
    return HttpResponse.failureFromError(parseException);
  }

  // 异常解析处理
  HttpException _parseException(Exception error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
          return NetworkException(message: error.message);
        case DioErrorType.cancel:
          return CancelException(error.message);
        case DioErrorType.response:
          try {
            int? errorCode = error.response?.statusCode;
            switch (errorCode) {
              case 400:
                return BadRequestException(message: "请求语法错误", code: errorCode);
              case 401:
                return UnauthorisedException(message: "没有权限", code: errorCode);
              case 403:
                return BadRequestException(message: "服务器拒绝执行", code: errorCode);
              case 404:
                return BadRequestException(message: "无法连接服务器", code: errorCode);
              case 405:
                return BadRequestException(message: "请求方法被禁止", code: errorCode);
              case 500:
                return BadServiceException(message: "服务器内部错误", code: errorCode);
              case 502:
                return BadServiceException(message: "无效的请求", code: errorCode);
              case 503:
                return BadServiceException(message: "服务器挂了", code: errorCode);
              case 505:
                return UnauthorisedException(
                    message: "不支付http协议请求", code: errorCode);
              default:
                return UnknownException(error.message);
            }
          } on Exception catch (e) {
            return UnknownException(error.message);
          }

        case DioErrorType.other:
          if (error.error is SocketException) {
            return NetworkException(message: error.message);
          } else {
            return UnknownException(error.message);
          }
        default:
          return UnknownException(error.message);
      }
    } else {
      return UnknownException(error.toString());
    }
  }
}
