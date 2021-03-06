import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/res/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Toast 简单封装
class T {
  static show({
    @required String msg,
    Toast toastLength = Toast.LENGTH_SHORT,
    int timeInSecForIos = 1,
    double fontSize = 16.0,
    ToastGravity gravity,
    Color backgroundColor = Colours.transparent_ba,
    Color textColor = Colors.white,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: timeInSecForIos,
      backgroundColor: backgroundColor,
      textColor: textColor, fontSize: fontSize);
  }
}