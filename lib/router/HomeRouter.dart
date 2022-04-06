import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stormflutterapp/models/index.dart';
import 'package:stormflutterapp/net/Net.dart';
import 'package:stormflutterapp/nethttp/HttpResponse.dart';
import 'package:stormflutterapp/provider/Notifier.dart';

import '../generated/l10n.dart';

class HomeRouter extends StatefulWidget {
  const HomeRouter({Key? key}) : super(key: key);

  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  static const String loadingTag = "## loading ##";

  final _items = <Repo>[Repo()..name = loadingTag];
  bool hasMore = true;
  int page = 1;
  Widget line = const Divider(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).title),
      ),
      body: _buildHomeBody(),
    );
  }

  Widget _buildHomeBody() {
    var userModel = Provider.of<UserModel>(context);

    if (!userModel.isLogin) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            // ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text("去登录")));
            Navigator.of(context).pushNamed("login");
          },
          child: const Text("登录"),
        ),
      );
    } else {
      // 登录 展示 列表
      return ListView.separated(
          itemBuilder: (context, pos) {
            if (_items[pos].name == loadingTag) {
              // 如果是最后一个
              if (hasMore) {
                _retrieveData();

                // 如果能加载更多
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                    ),
                  ),
                );
              } else {
                // 没有更多
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: const Text(
                    "没有更多了",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
            }
            return RepoItem(_items[pos]);
          },
          separatorBuilder: (context, index) {
            return line;
          },
          itemCount: _items.length);
    }
  }

  // 请求数据

  void _retrieveData() async {
    HttpResponse r = await Net(context).getRepos(
      queryParameters: {
        'page': page,
        'page_size': 20,
      },
    );

    if (r.ok) {
      // List<Repo> datas = (r.data as Response<List>).data?.map((e) => Repo.fromJson(e)).toList();
      List<Repo> datas =
          (r.data as Response).data.map((e) => Repo.fromJson(e)).toList();
      hasMore = datas.length > 0;
      setState(() {
        _items.insertAll(_items.length - 1, datas);
        page++;
      });
    } else {}

    // //如果返回的数据小于指定的条数，则表示没有更多数据，反之则否
    // hasMore = data.length > 0 && data.length % 20 == 0;
    // //把请求到的新数据添加到items中
    // setState(() {
    //   _items.insertAll(_items.length - 1, data);
    //   page++;
    // });
  }
}

class RepoItem extends StatefulWidget {
  const RepoItem(this.repo, {Key? key}) : super(key: key);
  final Repo repo;

  @override
  State<RepoItem> createState() => _RepoItemState();
}

class _RepoItemState extends State<RepoItem> {
  @override
  Widget build(BuildContext context) {
    var subTitle;
    return Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Material(
          color: Colors.white,
          shape: BorderDirectional(
              bottom:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1)),
          child: Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: gmAvatar(widget.repo.owner.avatar_url,
                      width: 24, borderRadius: BorderRadius.circular(12)),
                  title: Text(
                    widget.repo.owner.login,
                    textScaleFactor: 0.9,
                  ),
                  subtitle: subTitle,
                  trailing: Text(widget.repo.language ?? '--'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.repo.fork
                            ? widget.repo.full_name
                            : widget.repo.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: widget.repo.fork
                                ? FontStyle.italic
                                : FontStyle.normal),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: widget.repo.description == null
                              ? Text(
                                  S.of(context).no_describe,
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[700]),
                                )
                              : Text(
                                  widget.repo.description!,
                                  maxLines: 3,
                                  style: TextStyle(
                                    height: 1.15,
                                    color: Colors.blueGrey[700],
                                    fontSize: 13,
                                  ),
                                )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

Widget gmAvatar(
  String url, {
  double width = 30,
  double? height,
  BoxFit? fit,
  BorderRadius? borderRadius,
}) {
  var placeholder = Image.network(
      "https://avatars2.githubusercontent.com/u/20411648?s=460&v=4", //头像占位图
      width: width,
      height: height);
  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.circular(2),
    child: CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
    ),
  );
}
