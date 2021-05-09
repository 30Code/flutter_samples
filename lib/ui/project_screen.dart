import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/app_bar.dart';
import 'package:flutter_samples/ui/base_widget.dart';

///项目
class ProjectScreen extends BaseWidget {

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return ProjectScreenState();
  }

}

class ProjectScreenState extends BaseWidgetState<ProjectScreen> {
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