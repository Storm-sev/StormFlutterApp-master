import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stormflutterapp/generated/l10n.dart';
import 'package:stormflutterapp/models/user.dart';
import 'package:stormflutterapp/nethttp/Exception.dart';
import 'package:stormflutterapp/provider/Notifier.dart';

import '../net/Net.dart';

class LoginRouter extends StatefulWidget {
  const LoginRouter({Key? key}) : super(key: key);

  @override
  State<LoginRouter> createState() => _LoginRouterState();
}

class _LoginRouterState extends State<LoginRouter> {
  TextEditingController _unameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  bool showPwd = false;
  bool _nameAutoFocus = true;

  GlobalKey fromKey = GlobalKey<FormState>();

  @override
  void initState() {
    _unameController.text = "zq329051@outlook.com";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).login),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: fromKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _unameController,
                autofocus: _nameAutoFocus,
                decoration: InputDecoration(
                    labelText: S.of(context).username,
                    hintText: S.of(context).hint_username,
                    prefixIcon: const Icon(Icons.person)),
                validator: (v) {
                  return v == null || v.trim().isNotEmpty
                      ? null
                      : S.of(context).hint_username;
                },
              ),
              TextFormField(
                controller: _pwdController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: S.of(context).pwd,
                  hintText: S.of(context).hint_pwd,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                      icon: Icon(
                          showPwd ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          showPwd = !showPwd;
                        });
                      }),
                ),
                obscureText: !showPwd,
                validator: (v) {
                  return v == null || v.trim().isNotEmpty
                      ? null
                      : S.of(context).hint_pwd;
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(height: 55),
                  child: ElevatedButton(
                    onPressed: _onLogin,
                    child: Text(S.of(context).login),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 执行登录
  Future _onLogin() async {
    if ((fromKey.currentState as FormState).validate()) {
      showLoading();
      User? user;
      var r =
          await Net(context).login(_unameController.text, _pwdController.text);
      if (r.ok) {
        user = User.fromJson((r.data as Response).data);
        Provider.of<UserModel>(context, listen: false).user = user;
      } else {
        // 没有获取到
        print("登录失败");
        if (r.error is UnauthorisedException) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("用户名或密码错误")));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(r.error?.message ?? "")));
        }
      }

      // try {
      //   user = await Net(context)
      //       .login(_unameController.text, _pwdController.text);
      //
      //   Provider.of<UserModel>(context, listen: false).user = user;
      //   print("登录成功");
      // } on DioError catch (e) {
      //   print("登录失败");
      //
      //   if (e.response?.statusCode == 401) {
      //     ScaffoldMessenger.of(context)
      //         .showSnackBar(SnackBar(content: Text("用户名或密码做粗")));
      //   } else {
      //     ScaffoldMessenger.of(context)
      //         .showSnackBar(SnackBar(content: Text(e.toString())));
      //   }
      // } finally {
      //   // Navigator.of(context).pop();
      // }

      if (null != user) {
        Navigator.of(context).pop();
      }
    }
  }

  void showLoading() {}
}
