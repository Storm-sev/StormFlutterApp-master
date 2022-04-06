// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "hint_pwd": MessageLookupByLibrary.simpleMessage("请输入密码"),
        "hint_username": MessageLookupByLibrary.simpleMessage("输入账号"),
        "language": MessageLookupByLibrary.simpleMessage("中文简体"),
        "login": MessageLookupByLibrary.simpleMessage("登录"),
        "no_describe": MessageLookupByLibrary.simpleMessage("暂无简介"),
        "pwd": MessageLookupByLibrary.simpleMessage("密码"),
        "title": MessageLookupByLibrary.simpleMessage("首页"),
        "username": MessageLookupByLibrary.simpleMessage("账号")
      };
}
