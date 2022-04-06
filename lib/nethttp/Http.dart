// http 配置


import 'package:dio/dio.dart';

class HttpConfig {
  // 基础 baseUrl
  final String? baseUrl;
  final String? proxy;
  final String? cookiePath;
  final List<Interceptor>? interceptors;
  final int? connectTimeout;
  final int? sendTimeout;
  final int? receiveTimeout;

  HttpConfig(
      {this.baseUrl,
      this.proxy,
      this.cookiePath,
      this.interceptors,
      this.connectTimeout,
      this.sendTimeout,
      this.receiveTimeout});
}
