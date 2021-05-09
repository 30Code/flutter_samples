import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/app_bar.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_samples/common/application.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/data/api/apis_service.dart';
import 'package:flutter_samples/data/model/article_model.dart';
import 'package:flutter_samples/event/refresh_share_event.dart';
import 'package:flutter_samples/utils/toast_util.dart';
import 'package:flutter_samples/widgets/item_article_list.dart';
import 'package:flutter_samples/widgets/refresh_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'base_widget.dart';

///广场
class SquareScreen extends BaseWidget {

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return SquareScreenState();
  }

}

class SquareScreenState extends BaseWidgetState<SquareScreen> {

  /// 首页文章列表数据
  List<ArticleBean> _articleList = new List();

  /// 是否显示悬浮按钮
  bool _isShowFAB = false;

  /// listview 控制器
  ScrollController _scrollController = new ScrollController();

  /// 页码，从0开始
  int _page = 0;
  RefreshController _refreshController = new RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    setAppBarVisible(false);
    registerRefreshEvent();
  }

  void registerRefreshEvent() {
    Application.eventBus.on<RefreshShareEvent>().listen((event) {
      showLoading().then((value) => {
        getSquareList()
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showLoading().then((value) => {
      getSquareList()
    });

    _scrollController.addListener(() {
      if (_scrollController.offset < 200 && _isShowFAB) {
        setState(() {
          _isShowFAB = false;
        });
      } else if (_scrollController.offset >= 200 && !_isShowFAB) {
        setState(() {
          _isShowFAB = true;
        });
      }
    });

  }

  /// 获取文章列表数据
  Future getSquareList() async {
    _page = 0;
    apiService.getSquareList((ArticleModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent().then((value) {
            _refreshController.refreshCompleted(resetFooterState: true);
            setState(() {
              _articleList.addAll(model.data.datas);
            });
          });
        } else {
          showEmpty();
        }
      } else {
        showError();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      showError();
    }, _page);
  }

  /// 获取更多文章列表数据
  Future getMoreSquareList() async {
    _page++;
    apiService.getSquareList((ArticleModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _articleList.addAll(model.data.datas);
          });
        } else {
          _refreshController.loadNoData();
        }
      } else {
        _refreshController.loadFailed();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      _refreshController.loadFailed();
    }, _page);
  }

  @override
  AppBar attachAppBar() {
    return AppBar(title: Text(""),);
  }

  @override
  Widget attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        controller: _refreshController,
        onRefresh: getSquareList,
        onLoading: getMoreSquareList,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _articleList.length,
        ),
      ),
      floatingActionButton: !_isShowFAB ? null : FloatingActionButton(
        onPressed: () {
          /// 回到顶部时要执行的动画
          _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 2000),
              curve: Curves.ease,
          );
        },
        heroTag: "square",
        child: Icon(Icons.arrow_upward),
      ),
    );
  }

  Widget itemView(BuildContext context, int index) {
    if (index > _articleList.length) {
      return null;
    }
    ArticleBean item = _articleList[index];
    return ItemArticleList(item: item,);
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) => {
      getSquareList()
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

}