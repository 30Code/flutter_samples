import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/app_bar.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/data/api/apis_service.dart';
import 'package:flutter_samples/data/model/wx_article_model.dart';
import 'package:flutter_samples/data/model/wx_chapters_model.dart';
import 'package:flutter_samples/ui/base_widget.dart';
import 'package:flutter_samples/utils/toast_util.dart';
import 'package:flutter_samples/widgets/item_article_wechat_list.dart';
import 'package:flutter_samples/widgets/refresh_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///公众号
class WeChatScreen extends BaseWidget {

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return WeChatScreenState();
  }

}

class WeChatScreenState extends BaseWidgetState<WeChatScreen>
    with TickerProviderStateMixin {

  List<WXChaptersBean> _chaptersList = new List();

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    setAppBarVisible(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showLoading().then((value) => {
      getWxChaptersList()
    });
  }

  Future getWxChaptersList() async {
    apiService.getWxChaptersList((WXChaptersModel wxChaptersModel) {
      if (wxChaptersModel.errorCode == Constants.STATUS_SUCCESS) {
        if (wxChaptersModel.data.length > 0) {
          showContent();
          setState(() {
            _chaptersList.clear();
            _chaptersList.addAll(wxChaptersModel.data);
          });
        } else {
          showEmpty();
        }
      } else {
        showError();
        T.show(msg: wxChaptersModel.errorMsg);
      }
    }, (DioError error) {
      showError();
    });
  }

  @override
  AppBar attachAppBar() {
    return AppBar(title: Text(""),);
  }

  @override
  Widget attachContentWidget(BuildContext context) {
    _tabController = new TabController(length: _chaptersList.length, vsync: this);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 50,
            color: Theme.of(context).primaryColor,
            child: TabBar(
              indicatorColor: Colors.white,
              labelStyle: TextStyle(fontSize: 16),
              unselectedLabelStyle: TextStyle(fontSize: 16),
              controller: _tabController,
              isScrollable: true,
              tabs: _chaptersList.map((WXChaptersBean item) {
                return Tab(text: item.name,);
              }).toList(),
            ),
          ),
          Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _chaptersList.map((item) {
                  return WXArticleScreen(item.id);
                }).toList(),
              ),
          ),
        ],
      ),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getWxChaptersList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

}

class WXArticleScreen extends StatefulWidget {
  final int id;

  WXArticleScreen(this.id);

  @override
  State<StatefulWidget> createState() {
    return WXArticleScreenState();
  }
}

class WXArticleScreenState extends State<WXArticleScreen>
    with AutomaticKeepAliveClientMixin {

  List<WXArticleBean> _wxArticleList = new List();

  /// listview 控制器
  ScrollController _scrollController = new ScrollController();

  /// 是否显示悬浮按钮
  bool _isShowFAB = false;
  int _page = 1;

  RefreshController _refreshController = new RefreshController(initialRefresh: true);

  Future getWxArticleList() async {
    _page = 1;
    int _id = widget.id;
    apiService.getWxArticleList((WXArticleModel wxArticleModel) {
      if (wxArticleModel.errorCode == Constants.STATUS_SUCCESS) {
        _refreshController.refreshCompleted(resetFooterState: true);
        setState(() {
          _wxArticleList.clear();
          _wxArticleList.addAll(wxArticleModel.data.datas);
        });
      } else {
        T.show(msg: wxArticleModel.errorMsg);
      }
    }, (DioError error) {

    }, _id, _page);
  }

  Future getMoreWxArticleList() async {
    _page++;
    int _id = widget.id;
    apiService.getWxArticleList((WXArticleModel wxArticleModel) {
      if (wxArticleModel.errorCode == Constants.STATUS_SUCCESS) {
        if (wxArticleModel.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _wxArticleList.addAll(wxArticleModel.data.datas);
          });
        } else {
          _refreshController.loadNoData();
        }
      } else {
        _refreshController.loadFailed();
        T.show(msg: wxArticleModel.errorMsg);
      }
    }, (DioError error) {
      _refreshController.loadFailed();
    }, _id, _page);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    getWxArticleList();

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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        controller: _refreshController,
        onRefresh: getWxArticleList,
        onLoading: getMoreWxArticleList,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _wxArticleList.length,
        ),
      ),
      floatingActionButton: !_isShowFAB ? null : FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 2000),
              curve: Curves.ease);
        },
        heroTag: "wechat",
        child: Icon(Icons.arrow_upward),
      ),
    );
  }

  Widget itemView(BuildContext context, int index) {
    WXArticleBean item = _wxArticleList[index];
    return ItemArticleWeChatList(item: item,);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

}