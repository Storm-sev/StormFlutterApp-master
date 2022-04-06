import 'dart:collection';

import 'package:dio/dio.dart';

import '../common/Global.dart';

class CacheObject {
  CacheObject(this.response)
      : timeStamp = DateTime.now().microsecondsSinceEpoch;
  Response response;
  int timeStamp;

  @override
  bool operator ==(Object other) => response.hashCode == other.hashCode;

  @override
  int get hashCode => response.realUri.hashCode;
}

// 网络缓存拦截器
class NetCache extends Interceptor {
  // 创建
  var cache = LinkedHashMap<String, CacheObject>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!Global.profile.cache!.enable) {
      // 没有开启网络缓存
      return handler.next(options);
    }
    // 是否是下拉刷新
    bool refresh = options.extra['refresh'] == true;
    if (refresh) {
      if (options.extra["list"] == true) {
        // 是列表

        cache.removeWhere((key, value) => key.contains(options.path));
      } else {
        dellete(options.uri.toString());
      }
      return handler.next(options);
    }

    if (options.extra["noCache"] != true &&
        options.method.toLowerCase() == "get") {
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      var ob = cache[key];
      if (ob != null) {
        // 如果缓存未过期
        if ((DateTime.now().microsecondsSinceEpoch - ob.timeStamp) / 1000 <
            Global.profile.cache!.maxAge) {
          return handler.resolve(ob.response);
        } else {
          cache.remove(key);
        }
      }
    }
    handler.next(options);
    // super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 如果启动缓存
    if (Global.profile.cache!.enable) {
      _saveCache(response);
    }
    handler.next(response);

    // super.onResponse(response, handler);
  }

  void dellete(String key) {
    cache.remove(key);
  }

  void _saveCache(Response response) {
    var options = response.requestOptions;
    if (options.extra["noCache"] != true &&
        options.method.toLowerCase() == "get") {
      if (cache.length == Global.profile.cache!.maxCount) {
        cache.remove(cache[cache.keys.first]);
      }
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      cache[key] = CacheObject(response);
    }
  }
}
