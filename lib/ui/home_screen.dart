import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/app_bar.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/data/api/apis_service.dart';
import 'package:flutter_samples/data/model/article_model.dart';
import 'package:flutter_samples/data/model/banner_model.dart';
import 'package:flutter_samples/utils/route_util.dart';
import 'package:flutter_samples/utils/toast_util.dart';
import 'package:flutter_samples/widgets/custom_cached_image.dart';
import 'package:flutter_samples/widgets/item_article_list.dart';
import 'package:flutter_samples/widgets/refresh_helper.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'base_widget.dart';

///首页
class HomeScreen extends BaseWidget {

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return HomeScreenState();
  }

}

class HomeScreenState extends BaseWidgetState<HomeScreen> {

  /// 首页轮播图数据
  List<BannerBean> _bannerList = new List();

  /// 首页文章列表数据
  List<ArticleBean> _articlesList = new List();

  /// listview 控制器
  ScrollController _scrollController = new ScrollController();

  /// 是否显示悬浮按钮
  bool _isShowFAB = false;

  /// 页码，从0开始
  int _page = 0;

  RefreshController _refreshController = new RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    setAppBarVisible(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bannerList.add(null);

    showLoading().then((value) {
      getBannerList();
      getTopArticleList();
    });

    _scrollController.addListener(() {
      /// 滑动到底部，加载更多
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {

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

  /// 获取轮播数据
  Future getBannerList() async {
    apiService.getBannerList((BannerModel bannerModel) {
      if (bannerModel.data.length > 0) {
        setState(() {
          _bannerList = bannerModel.data;
        });
      }
    });
  }

  /// 获取置顶文章数据
  Future getTopArticleList() async {
    apiService.getTopArticleList((TopArticleModel topArticleModel) {
      if (topArticleModel.errorCode == Constants.STATUS_SUCCESS) {
        topArticleModel.data.forEach((element) {
          element.top = 1;
        });

        _articlesList.clear();
        _articlesList.addAll(topArticleModel.data);
      }

      getArticleList();
    }, (DioError error) {
      showError();
    });
  }

  /// 获取文章列表数据
  Future getArticleList() async {
    _page = 0;
    apiService.getArticleList((ArticleModel articleModel) {
      if (articleModel.errorCode == Constants.STATUS_SUCCESS) {
        if (articleModel.data.datas.length > 0) {
          showContent().then((value) {
            _refreshController.refreshCompleted(resetFooterState: true);
            setState(() {
              _articlesList.addAll(articleModel.data.datas);
            });
          });
        } else {
          showEmpty();
        }
      } else {
        showError();
        T.show(msg: articleModel.errorMsg);
      }
    }, (DioError error) {
      showError();
    }, _page);
  }

  /// 获取更多文章列表数据
  Future getMoreArticleList() async {
    _page++;
    apiService.getArticleList((ArticleModel articleModel) {
      if (articleModel.errorCode == Constants.STATUS_SUCCESS) {
        if (articleModel.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _articlesList.addAll(articleModel.data.datas);
          });
        } else {
          _refreshController.loadNoData();
        }
      } else {
        _refreshController.loadFailed();
        T.show(msg: articleModel.errorMsg);
      }
    }, (DioError error) {
      _refreshController.loadFailed();
    }, _page);
  }

  @override
  AppBar attachAppBar() {
    return AppBar(title: Text(''),);
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
        onRefresh: getTopArticleList,
        onLoading: getMoreArticleList,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _articlesList.length + 1,
        ),
      ),
      floatingActionButton: !_isShowFAB ? null : FloatingActionButton(
        onPressed: () {
          /// 回到顶部时要执行的动画
          _scrollController.animateTo(0, duration: Duration(
              milliseconds: 2000),
              curve: Curves.ease
          );
        },
        heroTag: "home",
        child: Icon(Icons.arrow_upward),
      ),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getBannerList();
      getTopArticleList();
    });
  }

  /// ListView 中每一行的视图
  Widget itemView(BuildContext context, int index) {
    if (index == 0) {
      return Container(
        height: 200,
        color: Colors.transparent,
        child: _buildBannerWidget(),
      );
    }

    ArticleBean item = _articlesList[index - 1];
    return ItemArticleList(item: item);
  }

  /// 构建轮播视图
  Widget _buildBannerWidget() {
    return Offstage(
      offstage: _bannerList.length == 0,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          if (index >= _bannerList.length
              || _bannerList[index] == null
              || _bannerList[index].imagePath == null) {
            return new Container(height: 0,);
          } else {
            return InkWell(
              child: new Container(
                child: CustomCachedImage(imageUrl: _bannerList[index].imagePath,),
              ),
              onTap: () {
                RouteUtil.toWebView(context, _bannerList[index].title, _bannerList[index].url);
              },
            );
          }
        },
        itemCount: _bannerList.length,
        autoplay: true,
        pagination: new SwiperPagination(),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}