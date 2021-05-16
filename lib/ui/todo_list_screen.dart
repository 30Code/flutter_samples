import 'package:flutter/material.dart';
import 'package:flutter/src/material/app_bar.dart';

import 'package:flutter/src/widgets/framework.dart';

import 'base_widget.dart';

/// TODO 待完成列表页面
class TodoListScreen extends BaseWidget {

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return TodoListScreenState();
  }

}

class TodoListScreenState extends BaseWidgetState<TodoListScreen> {
  @override
  AppBar attachAppBar() {
    // TODO: implement attachAppBar
    throw UnimplementedError();
  }

  @override
  Widget attachContentWidget(BuildContext context) {
    return Scaffold();
  }

  @override
  void onClickErrorWidget() {
    // TODO: implement onClickErrorWidget
  }


}