// models
import 'package:flutter/material.dart';
import 'package:stormflutterapp/models/user.dart';

import '../common/Global.dart';
import '../models/profile.dart';

class ProfileChangeNotifier extends ChangeNotifier {
  Profile get _profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile();
    super.notifyListeners();
  }
}

class UserModel extends ProfileChangeNotifier {
  User? get _user => _profile.user;

  bool get isLogin => _user != null;

  set user(User user) {
    if (user.login != _profile.lastLogin) {
      _profile.lastLogin = _profile.user?.login;
      _profile.user = user;
      notifyListeners();
    }
  }
}

class ThemeModel extends ProfileChangeNotifier {
  ColorSwatch get theme =>
      Global.themes.firstWhere((element) => _profile.theme == element.value,
          orElse: () => Colors.blue);

  set theme(ColorSwatch? color) {
    if (null == color) return;
    if (theme != color) {
      _profile.theme = color[500]!.value;
      notifyListeners();
    }
  }
}

class LocaleModel extends ProfileChangeNotifier {
  Locale? getLocale() {
    if (_profile.locale == null) {
      return null;
    }
    var t = _profile.locale!.split("_");
    return Locale(t[0], t[1]);
  }

  String? get locale => _profile.locale;

  set locale(String? locale) {
    if (null == locale) return;
    if (locale != _profile.locale) {
      _profile.locale = locale;
      notifyListeners();
    }
  }
}
