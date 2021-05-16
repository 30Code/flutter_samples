import 'package:dio/dio.dart';
import 'package:flutter_samples/data/api/apis.dart';
import 'package:flutter_samples/data/model/article_model.dart';
import 'package:flutter_samples/data/model/banner_model.dart';
import 'package:flutter_samples/data/model/base_model.dart';
import 'package:flutter_samples/data/model/collection_model.dart';
import 'package:flutter_samples/data/model/hot_word_model.dart';
import 'package:flutter_samples/data/model/knowledge_detail_model.dart';
import 'package:flutter_samples/data/model/knowledge_tree_model.dart';
import 'package:flutter_samples/data/model/navigation_model.dart';
import 'package:flutter_samples/data/model/project_article_model.dart';
import 'package:flutter_samples/data/model/project_tree_model.dart';
import 'package:flutter_samples/data/model/search_article_model.dart';
import 'package:flutter_samples/data/model/user_info_model.dart';
import 'package:flutter_samples/data/model/user_model.dart';
import 'package:flutter_samples/data/model/user_score_model.dart';
import 'package:flutter_samples/data/model/wx_article_model.dart';
import 'package:flutter_samples/data/model/wx_chapters_model.dart';
import 'package:flutter_samples/net/dio_manager.dart';
import 'package:flutter_samples/utils/print_long.dart';

ApiService _apiService = new ApiService();

ApiService get apiService => _apiService;

class ApiService {

  ///  获取首页轮播数据
  void getBannerList(Function callback) async {
    dio.get(Apis.HOME_BANNER).then((response) => {
      callback(BannerModel.fromJson(response.data))
    });
  }

  /// 获取首页置顶文章数据
  void getTopArticleList(Function callback, Function errorCallback) async {
    dio.get(Apis.HOME_TOP_ARTICLE_LIST).then((response) => {
      callback(TopArticleModel.fromJson(response.data))
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取首页文章列表数据
  void getArticleList(Function callback, Function errorCallback, int _page) async {
    dio.get(Apis.HOME_ARTICLE_LIST + "/$_page/json").then((response) {
      // printLong(" 获取首页文章列表数据 " + response.data.toString());
      callback(ArticleModel.fromJson(response.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取广场列表数据
  void getSquareList(Function callback, Function errorCallBack, int _page) async {
    dio.get(Apis.SQUARE_LIST + "/$_page/json").then((value) {
      callback(ArticleModel.fromJson(value.data));
    }).catchError((e) {
      errorCallBack(e);
    });
  }

  /// 获取公众号名称
  void getWxChaptersList(Function callback, Function errorCallback) async {
    dio.get(Apis.WX_CHAPTERS_LIST).then((value) {
      callback(WXChaptersModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取公众号文章列表数据
  void getWxArticleList(Function callback, Function errorCallback,
      int _id, int _page) async {
    dio.get(Apis.WX_ARTICLE_LIST + "/$_id/$_page/json").then((value) => {
      callback(WXArticleModel.fromJson(value.data))
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取知识体系数据
  void getKnowledgeTreeList(Function callback, Function errorCallback) async {
    dio.get(Apis.KNOWLEDGE_TREE_LIST).then((value) {
      callback(KnowledgeTreeModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取知识体系详情数据
  void getKnowledgeDetailList(
      Function callback, Function errorCallback, int _page, int _id) async {
    dio
        .get(Apis.KNOWLEDGE_DETAIL_LIST + "/$_page/json?cid=$_id")
        .then((response) {
      callback(KnowledgeDetailModel.fromJson(response.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取导航列表数据
  void getNavigationList(Function callback, Function errorCallback) async {
    dio.get(Apis.NAVIGATION_LIST).then((value) {
      callback(NavigationModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取项目分类列表数据
  void getProjectTreeList(Function callback, Function errorCallback) async {
    dio.get(Apis.PROJECT_TREE_LIST).then((value) {
      callback(ProjectTreeModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取项目文章列表数据
  void getProjectArticleList(Function callback, Function errorCallback, int _id, int _page) async {
    dio.get(Apis.PROJECT_ARTICLE_LIST + "/$_page/json?cid=$_id").then((value) {
      callback(ProjectArticleListModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取用户个人信息
  void getUserInfo(Function callback, Function errorCallback) async {
    dio.get(Apis.USER_INFO).then((value) {
      callback(UserInfoModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 登录
  void login(Function callback, Function errorCallback,
      String _username, String _password) async {
    FormData formData = new FormData.fromMap({"username": _username, "password": _password});
    dio.post(Apis.USER_LOGIN, data: formData).then((value) {
      callback(UserModel.fromJson(value.data), value);
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 注册
  void register(Function callback, Function errorCallback,
      String _username, String _password) async {
    FormData formData = new FormData.fromMap({
      "username": _username,
      "password": _password,
      "repassword": _password
    });
    dio.post(Apis.USER_REGISTER, data: formData).then((value) {
      callback(UserModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取收藏列表
  void getCollectionList(Function callback, Function errorCallback, int _page) async {
    dio.get(Apis.COLLECTION_LIST + "/$_page/json").then((value) {
      callback(CollectionModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 新增收藏(收藏站内文章)
  void addCollection(Function callback, Function errorCallback, int _id) async {
    dio.post(Apis.ADD_COLLECTION + "/$_id/json").then((value) {
      callback(BaseModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 取消收藏
  void cancelCollection(
      Function callback, Function errorCallback, int _id) async {
    dio.post(Apis.CANCEL_COLLECTION + "/$_id/json").then((response) {
      callback(BaseModel.fromJson(response.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 退出登录
  void logout(Function callback, Function errorCallBack) async {
    dio.get(Apis.USER_LOGOUT).then((value) {
      callback(BaseModel.fromJson(value.data));
    }).catchError((e) {
      errorCallBack(e);
    });
  }

  /// 获取搜索热词列表数据
  void getSearchHotList(Function callback, Function errorCallback) async {
    dio.get(Apis.SEARCH_HOT_LIST).then((value) {
      callback(HotWordModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取搜索的文章列表
  void getSearchArticleList(Function callback, Function errorCallback,
      int _page, String _keyword) async {
    FormData formData = new FormData.fromMap({"k" : _keyword});
    dio.post(Apis.SEARCH_ARTICLE_LIST + "/$_page/json", data: formData).then((value) {
      callback(SearchArticleModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }

  /// 获取我的积分列表数据
  void getUserScoreList(Function callback, Function errorCallback, int _page) async {
    dio.get(Apis.USER_SCORE_LIST + "/$_page/json").then((value) {
      callback(UserScoreModel.fromJson(value.data));
    }).catchError((e) {
      errorCallback(e);
    });
  }
}