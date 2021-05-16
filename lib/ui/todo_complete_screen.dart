import 'package:flutter/material.dart';
import 'package:flutter/src/material/app_bar.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_samples/ui/base_widget.dart';

/// TODO 已完成列表页面
class TodoCompleteScreen extends BaseWidget {

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return TodoCompleteScreenState();
  }

}

class TodoCompleteScreenState extends BaseWidgetState<TodoCompleteScreen> {
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