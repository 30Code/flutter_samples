import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/common/application.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/common/user.dart';
import 'package:flutter_samples/data/api/apis_service.dart';
import 'package:flutter_samples/data/model/base_model.dart';
import 'package:flutter_samples/data/model/user_info_model.dart';
import 'package:flutter_samples/event/login_event.dart';
import 'package:flutter_samples/event/theme_change_event.dart';
import 'package:flutter_samples/res/styles.dart';
import 'package:flutter_samples/ui/collect_screen.dart';
import 'package:flutter_samples/ui/score_screen.dart';
import 'package:flutter_samples/ui/setting_screen.dart';
import 'package:flutter_samples/ui/todo_screen.dart';
import 'package:flutter_samples/utils/route_util.dart';
import 'package:flutter_samples/utils/sp_util.dart';
import 'package:flutter_samples/utils/theme_util.dart';
import 'package:flutter_samples/utils/toast_util.dart';
import 'package:flutter_samples/utils/utils.dart';

import 'login_screen.dart';

/// 侧滑页面
class DrawerScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new DrawerScreenState();
  }

}

class DrawerScreenState extends State<DrawerScreen> with AutomaticKeepAliveClientMixin {

  bool isLogin = false;
  String username = "去登录";
  String level = "--";  // 等级
  String rank = "--"; // 排名
  String myScore = ''; // 我的积分

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    registerLoginEvent();

    if (User.singleton.userName != null && User.singleton.userName.isNotEmpty) {
      isLogin = true;
      username = User.singleton.userName;
      getUserInfo();
    }
  }

  void registerLoginEvent() {
    Application.eventBus.on<LoginEvent>().listen((event) {
      setState(() {
        isLogin = true;
        username = User.singleton.userName;
        getUserInfo();
      });
    });
  }

  /// 获取用户信息
  Future getUserInfo() async {
    apiService.getUserInfo((UserInfoModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        setState(() {
          level = (model.data.coinCount ~/ 100 + 1).toString();
          rank = model.data.rank.toString();
          myScore = model.data.coinCount.toString();
        });
      }
    }, (DioError error) {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(16, 40, 16, 10),
                color: Theme.of(context).primaryColor,
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        child: Image.asset(
                          Utils.getImgPath('ic_rank'),
                          color: Colors.white,
                          width: 20,
                          height: 20,
                        ),
                        onTap: () {
                          //排行版

                        },
                      ),
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage(Utils.getImgPath('ic_default_avatar')),
                      radius: 40,
                    ),
                    Gaps.vGap10,
                    InkWell(
                      child: Text(
                        username,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      onTap: () {
                        if (!isLogin) {
                          //登录
                          RouteUtil.push(context, LoginScreen());
                        }
                      },
                    ),
                    Gaps.vGap5,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '等级:',
                          style: TextStyle(fontSize: 11, color: Colors.grey[100]),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                            level,
                            style: TextStyle(fontSize: 11, color: Colors.grey[100]),
                            textAlign: TextAlign.center,
                        ),
                        Gaps.hGap5,
                        Text(
                            '排名:',
                            style:
                            TextStyle(fontSize: 11, color: Colors.grey[100]),
                            textAlign: TextAlign.center,
                        ),
                        Text(
                            rank,
                            style:
                            TextStyle(fontSize: 11, color: Colors.grey[100]),
                            textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Image.asset(
                  Utils.getImgPath('ic_score'),
                  width: 24,
                  height: 24,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  "我的积分",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  myScore,
                  style: TextStyle(color: Colors.grey[500]),
                ),
                onTap: () {
                  if (isLogin) {
                    //我的积分
                    RouteUtil.push(context, ScoreScreen(myScore));
                  } else {
                    //登录
                    T.show(msg: "请先登录~");
                    RouteUtil.push(context, LoginScreen());
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.favorite_border,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  "我的收藏",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  if (isLogin) {
                    //我的收藏
                    RouteUtil.push(context, CollectScreen());
                  } else {
                    //登录
                    T.show(msg: "请先登录~");
                    RouteUtil.push(context, LoginScreen());
                  }
                },
              ),
              ListTile(
                title: Text(
                  "我的分享",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
                leading: Image.asset(
                  Utils.getImgPath('ic_share'),
                  width: 24,
                  height: 24,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  if (isLogin) {
                    //我的分享
                    // RouteUtil.push(context, ShareScreen());
                  } else {
                    T.show(msg: "请先登录~");
                    RouteUtil.push(context, LoginScreen());
                  }
                },
              ),
              ListTile(
                title: Text(
                  "TODO",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
                leading: Image.asset(
                  Utils.getImgPath('ic_todo'),
                  width: 24,
                  height: 24,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  if (isLogin) {
                    //发布
                    RouteUtil.push(context, TodoScreen());
                  } else {
                    T.show(msg: "请先登录~");
                    RouteUtil.push(context, LoginScreen());
                  }
                },
              ),
              ListTile(
                title: Text(
                  "夜间模式",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
                leading: Icon(Icons.brightness_2,
                    size: 24, color: Theme.of(context).primaryColor),
                onTap: () {
                  setState(() {
                    //夜间模式
                    changeTheme();
                  });
                },
              ),
              ListTile(
                title: Text(
                  "系统设置",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
                leading: Icon(Icons.settings,
                    size: 24, color: Theme.of(context).primaryColor),
                onTap: () {
                  //系统设置
                  RouteUtil.push(context, SettingScreen());
                },
              ),
              Offstage(
                offstage: !isLogin,
                child: ListTile(
                  title: Text(
                    "退出登录",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(Icons.power_settings_new,
                      size: 24, color: Theme.of(context).primaryColor),
                  onTap: () {
                    _logout(context);
                  },
                ),
              ),
            ],
          ),
        ),
        onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(true);
    return true;
  }

  changeTheme() async {
    ThemeUtils.dark = !ThemeUtils.dark;
    SPUtil.putBool(Constants.DARK_KEY, ThemeUtils.dark);
    Application.eventBus.fire(new ThemeChangeEvent());
  }

  /// 退出登录
  void _logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          content: new Text('确定退出登录吗？'),
          actions: <Widget>[
            new TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: new Text('取消', style: TextStyle(color: Colors.cyan)),
            ),
            new TextButton(
              onPressed: () => {
                apiService.logout((BaseModel model) {
                  Navigator.of(context).pop(true);
                  if (model.errorCode == Constants.STATUS_SUCCESS) {
                    User.singleton.clearUserInfo();
                    setState(() {
                      isLogin = false;
                      username = "去登录";
                      level = "--";
                      rank = "--";
                      myScore = '';
                    });
                    T.show(msg: '已退出登录');
                  } else {
                    T.show(msg: model.errorMsg);
                  }
                }, (DioError error) {
                  print(error.response);
                })
              },
              child: new Text('确定', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        ),
    );
  }
}