import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cacheConfig.dart';
import '../models/profile.dart';
import '../net/Cache.dart';
import '../net/Net.dart';

const _theme = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
];

// 顶级
class Global {
  static late SharedPreferences _sp;
  static Profile profile = Profile(); // 用户相关信息
  // 网络缓存相关

  // 主题相关
  static List<MaterialColor> get themes => _theme;

  static bool get isRelease => const bool.fromEnvironment("com.storm.product");
  static NetCache netCache = NetCache();

  static Future init() async {
    //
    WidgetsFlutterBinding.ensureInitialized();
    _sp = await SharedPreferences.getInstance();
    var _profile = _sp.getString("profile");

    if (_profile != null) {
      try {
        profile = Profile.fromJson(json.decode(_profile));
      } catch (e) {
        print(e);
      }
    } else {
      profile = Profile()..theme = 0;
    }

    profile.cache = profile.cache ?? CacheConfig()
      ..enable = true
      ..maxAge = 3600
      ..maxCount = 100;

    // 初始化 网路请求相关配置
    Net.init();
  }

  // 保存用户信息
  static saveProfile() =>
      {_sp.setString("profile", json.encode(profile.toJson()))};
}
