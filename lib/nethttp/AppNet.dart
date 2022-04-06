
import 'package:dio/adapter.dart';
import 'package:dio/adapter_browser.dart';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';

import 'package:stormflutterapp/nethttp/Http.dart';

class AppNet extends DioMixin implements Dio {
  AppNet({BaseOptions? options, HttpConfig? config}) {
    // 构建 baseOptions
    options ??= BaseOptions(
      baseUrl: config?.baseUrl ?? "",
      connectTimeout: config?.connectTimeout,
      sendTimeout: config?.sendTimeout,
      receiveTimeout: config?.receiveTimeout,
    );

    this.options = options;

    final cacheOption = CacheOptions(
      store: MemCacheStore(),
      // Returns a cached response on error but for statuses 401 & 403.
      // Also allows to return a cached response on network errors (e.g. offline usage).
      // Defaults to [null].
      hitCacheOnErrorExcept: [401, 403],
      // Overrides any HTTP directive to delete entry past this duration.
      // Useful only when origin server has no cache config or custom behaviour is desired.
      // Defaults to [null].
      maxStale: const Duration(days: 7),
    );

    // interceptors.add(DioCacheInterceptor(options: cacheOption));
    // cookie 管理
    // if (config?.cookiePath?.isNotEmpty ?? false) {
    //   interceptors.add(CookieManager(PersistCookieJar(
    //     storage: FileStorage(config!.cookiePath),
    //   )));
    // }

    // log相关
    if (kDebugMode) {
      interceptors.add(LogInterceptor(
        requestBody: true,
        error: true,
        requestHeader: true,
        request: true,
        responseBody: true,
        responseHeader: true,
      ));
    }

    // 添加用户自己定义的拦截器
    if (config?.interceptors?.isNotEmpty ?? false) {
      interceptors.addAll(config!.interceptors!);
    }


    if(kIsWeb) {
      httpClientAdapter = BrowserHttpClientAdapter();
    }else{
      httpClientAdapter = DefaultHttpClientAdapter();
    }

    // if (config?.proxy?.isNotEmpty ?? false) {
    //   setProxy(config!.proxy!);
    // }
  }

  setProxy(String proxy) {
    (httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      // config the http client
      client.findProxy = (uri) {
        // proxy all request to localhost:8888
        return "PROXY $proxy";
      };
      // you can also create a HttpClient to dio
      // return HttpClient();
    };
  }

  void headers(Map<String, dynamic> headers) {
    this.options.headers = headers;
  }
}
