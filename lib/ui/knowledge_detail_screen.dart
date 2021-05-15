import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/data/api/apis_service.dart';
import 'package:flutter_samples/data/model/knowledge_detail_model.dart';
import 'package:flutter_samples/data/model/knowledge_tree_model.dart';
import 'package:flutter_samples/ui/base_widget.dart';
import 'package:flutter_samples/utils/toast_util.dart';
import 'package:flutter_samples/widgets/item_knowledge_detail_list.dart';
import 'package:flutter_samples/widgets/refresh_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class KnowledgeDetailScreen extends StatefulWidget {

  KnowledgeTreeBean bean;

  KnowledgeDetailScreen(ValueKey<KnowledgeTreeBean> key) {
    this.bean = key.value;
  }

  @override
  State<StatefulWidget> createState() {
    return KnowledgeDetailScreenState();
  }
}

class KnowledgeDetailScreenState extends State<KnowledgeDetailScreen> with TickerProviderStateMixin {

  KnowledgeTreeBean bean;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    bean = widget.bean;
  }

  @override
  Widget build(BuildContext context) {
    _tabController = new TabController(length: bean.children.length, vsync: this);
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.4,
        title: Text(bean.name),
        bottom: new TabBar(
          indicatorColor: Colors.white,
          labelStyle: TextStyle(fontSize: 16),
          unselectedLabelStyle: TextStyle(fontSize: 16),
          controller: _tabController,
          isScrollable: true,
          tabs: bean.children.map((item) {
            return Tab(text: item.name,);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: bean.children.map((item) {
          return KnowledgeArticleScreen(item.id);
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class KnowledgeArticleScreen extends BaseWidget {

  final int id;

  KnowledgeArticleScreen(this.id);

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return KnowledgeArticleScreenState();
  }
}

class KnowledgeArticleScreenState extends BaseWidgetState<KnowledgeArticleScreen> {

  List<KnowledgeDetailChild> _list = new List();

  ScrollController _scrollController = new ScrollController();

  int _page = 0;
  /// 是否显示悬浮按钮
  bool _isShowFAB = false;

  RefreshController _refreshController = new RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    setAppBarVisible(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showLoading().then((value) {
      getKnowledgeDetailList();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // getMoreKnowledgeDetailList();
      }
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

  Future getKnowledgeDetailList() async {
    _page = 0;
    int _id = widget.id;
    apiService.getKnowledgeDetailList((KnowledgeDetailModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent();
          _refreshController.refreshCompleted(resetFooterState: true);
          setState(() {
            _list.clear();
            _list.addAll(model.data.datas);
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
    }, _page, _id);
  }

  Future getMoreKnowledgeDetailList() async {
    _page++;
    int _id = widget.id;
    apiService.getKnowledgeDetailList((KnowledgeDetailModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _list.addAll(model.data.datas);
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
    }, _page, _id);
  }

  @override
  AppBar attachAppBar() {
    return AppBar(title: Text(""),);
  }

  @override
  Widget attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        controller: _refreshController,
        onRefresh: getKnowledgeDetailList,
        onLoading: getMoreKnowledgeDetailList,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _list.length,
        ),
      ),
      floatingActionButton: !_isShowFAB
          ? null
          : FloatingActionButton(
        heroTag: "knowledge_detail",
        child: Icon(Icons.arrow_upward),
        onPressed: () {
          /// 回到顶部时要执行的动画
          _scrollController.animateTo(0,
              duration: Duration(milliseconds: 2000), curve: Curves.ease);
        },
      ),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getKnowledgeDetailList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Widget itemView(BuildContext context, int index) {
    KnowledgeDetailChild item = _list[index];
    return ItemKnowledgeDetailList(item: item);
  }
}