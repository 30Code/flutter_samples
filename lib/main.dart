import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_samples/common/application.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/common/router_config.dart';
import 'package:flutter_samples/common/user.dart';
import 'package:flutter_samples/net/dio_manager.dart';
import 'package:flutter_samples/res/colors.dart';
import 'package:flutter_samples/ui/splash_screen.dart';
import 'package:flutter_samples/utils/sp_util.dart';
import 'package:flutter_samples/utils/theme_util.dart';

import 'event/theme_change_event.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await SPUtil.getInstance();

  await getTheme();

  runApp(MyApp());

  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，
    // 是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

Future<Null> getTheme() async {
  // 是否是夜间模式
  bool dark = SPUtil.getBool(Constants.DARK_KEY, defValue: false);
  ThemeUtils.dark = dark;

  // 如果不是夜间模式，设置的其他主题颜色才起作用
  if (!dark) {
    String themeColorKey = SPUtil.getString(Constants.THEME_COLOR_KEY, defValue: 'redAccent');
    if (themeColorMap.containsKey(themeColorKey)) {
      ThemeUtils.currentThemeColor = themeColorMap[themeColorKey];
    }
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyAppState();
  }

}

class MyAppState extends State<MyApp> {

  ThemeData themeData;

  @override
  void initState() {
    super.initState();
    _initAsync();
    Application.eventBus = new EventBus();
    themeData = ThemeUtils.getThemeData();
    registerThemeEvent();
  }

  void _initAsync() async {
    await User().getUserInfo();
    await DioManager.init();
  }

  /// 注册主题改变事件
  void registerThemeEvent() {
    Application.eventBus
        .on<ThemeChangeEvent>()
        .listen((ThemeChangeEvent event) {
          changeTheme(event);
    });
  }

  void changeTheme(ThemeChangeEvent event) async {
    setState(() {
      themeData = ThemeUtils.getThemeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,//去掉debug图标
      theme: themeData,
      routes: RouterConfig.generateRoute(),
      navigatorKey: navigatorKey,
      home: new SplashScreen(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Application.eventBus.destroy();
  }
}


