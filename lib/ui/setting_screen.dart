import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/common/application.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/event/theme_change_event.dart';
import 'package:flutter_samples/res/colors.dart';
import 'package:flutter_samples/utils/sp_util.dart';
import 'package:flutter_samples/utils/theme_util.dart';

/// 设置页面
class SettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingScreenState();
  }
}

class SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.4,
        title: Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          new ExpansionTile(
            title: new Row(
              children: <Widget>[
                Icon(Icons.color_lens, color: Theme.of(context).primaryColor,),
                Padding(padding: EdgeInsets.only(left: 10), child: Text('主题'),),
              ],
            ),
            children: <Widget>[
              new Wrap(children: themeColorMap.keys.map((String key) {
                Color color = themeColorMap[key];
                return new InkWell(
                  onTap: () {
                    SPUtil.putString(Constants.THEME_COLOR_KEY, key);
                    ThemeUtils.currentThemeColor = color;
                    Application.eventBus.fire(ThemeChangeEvent());
                  },
                  child: new Container(
                    margin: EdgeInsets.all(5),
                    width: 36,
                    height: 36,
                    color: color,
                  ),
                );
              }).toList(),),
            ],
          ),
          new ListTile(
            trailing: Icon(Icons.chevron_right),
            title: Row(
              children: <Widget>[
                Icon(Icons.feedback, color: Theme.of(context).primaryColor,),
                Padding(padding: EdgeInsets.only(left: 10), child: Text('意见反馈'),)
              ],
            ),
            onTap: () {

            },
          ),
          new ListTile(
            trailing: Icon(Icons.chevron_right),
            title: Row(
              children: <Widget>[
                Icon(Icons.settings_overscan, color: Theme.of(context).primaryColor,),
                Padding(padding: EdgeInsets.only(left: 10), child: Text('扫码下载'),)
              ],
            ),
            onTap: () {

            },
          ),
          new ListTile(
            trailing: Icon(Icons.chevron_right),
            title: Row(
              children: <Widget>[
                Icon(Icons.info, color: Theme.of(context).primaryColor,),
                Padding(padding: EdgeInsets.only(left: 10), child: Text('关于'),)
              ],
            ),
            onTap: () {

            },
          ),
        ],
      ),
    );
  }
}