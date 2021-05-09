import 'package:dio/dio.dart';
import 'package:flutter_samples/data/model/user_model.dart';
import 'package:flutter_samples/utils/sp_util.dart';

import 'common.dart';

class User {
  static final User singleton = User._internal();

  factory User() {
    return singleton;
  }

  User._internal();

  List<String> cookie;
  String userName;

  void saveUserInfo(UserModel _userModel, Response response) {
    List<String> cookies = response.headers["set-cookie"];
    cookie = cookies;
    userName = _userModel.data.username;
    saveInfo();
  }

  Future<Null> getUserInfo() async {
    List<String> cookies = SPUtil.getStringList(Constants.COOKIES_KEY);
    if (cookies != null) {
      cookie = cookies;
    }

    String username = SPUtil.getString(Constants.USERNAME_KEY);
    if (username != null) {
      userName = username;
    }
  }

  saveInfo() async {
    SPUtil.putStringList(Constants.COOKIES_KEY, cookie);
    SPUtil.putString(Constants.USERNAME_KEY, userName);
  }

  void clearUserInfo() {
    cookie = null;
    userName = null;
    SPUtil.remove(Constants.COOKIES_KEY);
    SPUtil.remove(Constants.USERNAME_KEY);
  }
}