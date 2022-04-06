import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:stormflutterapp/models/index.dart';
import 'package:stormflutterapp/nethttp/HttpClient.dart';
import 'package:stormflutterapp/nethttp/HttpResponse.dart';

import '../common/Global.dart';
import '../models/user.dart';
import '../nethttp/Http.dart';

class Net {
  late Options _options;
  BuildContext? context;

  // extra 格外自定子字段可以在response intercepter 中检测到
  Net([this.context]) {
    _options = Options(extra: {'context': context});
  }

  static Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.github.com/',
    headers: {
      HttpHeaders.acceptHeader: "application/vnd.github.squirrel-girl-preview,"
          "application/vnd.github.symmetra-preview+json",
    },
  ));

  static HttpConfig httpConfig = HttpConfig(
      baseUrl: 'https://api.github.com/',
      connectTimeout: 3000,
      sendTimeout: 3000,
      receiveTimeout: 3000);

  static HttpClient httpClient = HttpClient(
      options: BaseOptions(
          baseUrl: httpConfig.baseUrl!,
          headers: {
            HttpHeaders.acceptHeader:
                "application/vnd.github.squirrel-girl-preview,"
                    "application/vnd.github.symmetra-preview+json",
          },
          connectTimeout: 3000,
          sendTimeout: 3000,
          receiveTimeout: 3000));

  static void init() {
    // httpClient.dio.options.headers = ({
    //   HttpHeaders.acceptHeader: "application/vnd.github.squirrel-girl-preview,"
    //       "application/vnd.github.symmetra-preview+json"
    // });
    httpClient.dio.options.headers =
        ({HttpHeaders.authorizationHeader: Global.profile.token});

    // 添加缓存拦截器
    dio.interceptors.add(Global.netCache);
    // 设置用户token
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;
    // 调试模式下需要抓包tiaohsi
    if (!Global.isRelease) {
      // if (Platform.isAndroid) {
      if (dio.httpClientAdapter is DefaultHttpClientAdapter) {
        if (dio.httpClientAdapter is DefaultHttpClientAdapter) {
          (dio.httpClientAdapter as DefaultHttpClientAdapter)
              .onHttpClientCreate = (client) {
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
          };
        }
      }
      // }
    }

    if (!Global.isRelease) {
      if (httpClient.dio.httpClientAdapter is DefaultHttpClientAdapter) {
        (httpClient.dio.httpClientAdapter as DefaultHttpClientAdapter)
            .onHttpClientCreate = (client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        };
      }
    }
  }

  //
  Future<HttpResponse> login(String login, String pwd) async {
    String basic = 'Basic ' + base64.encode(utf8.encode('$login:$pwd'));
    _options.headers = {HttpHeaders.authorizationHeader: basic};
    _options.extra?["noCache"] = true;

    HttpResponse r = await httpClient.get("/user", options: _options);
    httpClient.dio.options.headers[HttpHeaders.authorizationHeader] = basic;
    Global.profile.token = basic;
    return r;
  }

  // 登录接口
  // Future<User> login(String login, String pwd) async {
  //   String basic = 'Basic ' + base64.encode(utf8.encode('$login:$pwd'));
  //
  //   // _options.headers![HttpHeaders.authorizationHeader] = basic;
  //   _options.headers = {HttpHeaders.authorizationHeader: basic};
  //
  //   _options.extra!["noCache"] = true;
  //
  //   var result = await dio.get("/user", options: _options);
  //   //
  //   dio.options.headers[HttpHeaders.authorizationHeader] = basic;
  //
  //
  //   //q清空所哟缓存
  //   Global.netCache.cache.clear();
  //   Global.profile.token = basic;
  //   return User.fromJson(result.data);
  //
  // }

  Future<HttpResponse> getRepos(
      {required Map<String, dynamic> queryParameters, refresh = false}) async {
    if (refresh) {
      _options.extra!.addAll({"refresh": true, "list": true});
    }

    //
    // var r = await dio.get<List>(
    //   "user/repos",
    //   queryParameters: queryParameters,
    //   options: _options,
    // );

    HttpResponse r = await httpClient.get("user/repos",
        queryParamsters: queryParameters, options: _options);
    return r;
  }
}
