import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/app_bar.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_samples/common/application.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/data/api/apis_service.dart';
import 'package:flutter_samples/data/model/base_model.dart';
import 'package:flutter_samples/data/model/todo_list_model.dart';
import 'package:flutter_samples/event/refresh_todo_event.dart';
import 'package:flutter_samples/ui/todo_add_screen.dart';
import 'package:flutter_samples/utils/route_util.dart';
import 'package:flutter_samples/utils/toast_util.dart';
import 'package:flutter_samples/widgets/item_todo_list.dart';
import 'package:flutter_samples/widgets/loading_dialog.dart';
import 'package:flutter_samples/widgets/refresh_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'base_widget.dart';

/// TODO 待完成列表页面
class TodoListScreen extends BaseWidget {

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return TodoListScreenState();
  }

}

class TodoListScreenState extends BaseWidgetState<TodoListScreen> {

  /// 待办类型：0:只用这一个  1:工作  2:学习  3:生活
  int todoType = 0;
  int _page = 1;
  List<TodoBean> _todoBeanList = new List();

  ScrollController _scrollController = new ScrollController();

  /// 是否显示悬浮按钮
  bool _isShowFAB = false;

  SlidableController slidableController = SlidableController();

  /// 重新构建的数据集合
  Map<String, List<TodoBean>> map = Map();

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    setAppBarVisible(false);
    this.registerRefreshEvent();
  }

  /// 注册刷新TODO事件
  void registerRefreshEvent() {
    Application.eventBus.on<RefreshTodoEvent>().listen((event) {
      todoType = event.todoType;
      _todoBeanList.clear();
      showLoading().then((value) {
        getNoTodoList();
      });
    });
  }

  @override
  AppBar attachAppBar() {
    return AppBar(title: Text(''),);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showLoading().then((value) {
      getNoTodoList();
    });

    _scrollController.addListener(() {
      /// 滑动到底部，加载更多
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // getMoreNoTodoList();
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

  /// 获取待办TODO列表数据
  Future getNoTodoList() async {
    _page = 1;
    apiService.getNoTodoList((TodoListModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent();
          _refreshController.refreshCompleted(resetFooterState: true);
          setState(() {
            _todoBeanList.clear();
            _todoBeanList.addAll(model.data.datas);
          });
          rebuildData();
        } else {
          showEmpty();
        }
      } else {
        showError();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      showError();
    }, todoType, _page);
  }

  /// 获取更多待办TODO列表数据
  Future getMoreNoTodoList() async {
    _page++;
    apiService.getNoTodoList((TodoListModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _todoBeanList.addAll(model.data.datas);
          });
          rebuildData();
        } else {
          _refreshController.loadNoData();
        }
      } else {
        _refreshController.loadFailed();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      _refreshController.loadFailed();
    }, todoType, _page);
  }

  /// 重新构建数据
  void rebuildData() {
    map.clear();
    Set<String> set = new Set();
    _todoBeanList.forEach((element) {
      set.add(element.dateStr);
    });

    set.forEach((element) {
      List<TodoBean> list = new List();
      map.putIfAbsent(element, () => list);
    });

    _todoBeanList.forEach((element) {
      map[element.dateStr].add(element);
    });
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
        onRefresh: getNoTodoList,
        onLoading: getMoreNoTodoList,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _todoBeanList.length,
        ),
      ),
    );
  }

  Widget itemView(BuildContext context, int index) {
    TodoBean item = _todoBeanList[index];
    bool isShowSuspension = false;
    if (map.containsKey(item.dateStr)) {
      if (map[item.dateStr].length > 0) {
        if (map[item.dateStr][0].id == item.id) {
          isShowSuspension = true;
        }
      }
    }

    return ItemTodoList(
      isTodo: true,
      item: item,
      slidableController: slidableController,
      isShowSuspension: isShowSuspension,
      todoType: todoType,
      updateTodoCallback: (_id) {
        this.updateTodoState(_id, index);
      },
      deleteItemCallback: (_id) {
        this.deleteTodoById(_id, index);
      },
    );
  }

  /// 仅更新完成状态Todo
  Future updateTodoState(int _id, int index) async {
    // status: 0或1，传1代表未完成到已完成，反之则反之。
    var params = {"status" : 1};
    _showLoading(context);
    apiService.updateTodoState((BaseModel model) {
      _dismissLoading(context);
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        T.show(msg: "更新成功");
        setState(() {
          _todoBeanList.removeAt(index);
        });
        rebuildData();
      } else {
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      _dismissLoading(context);
    }, _id, params);
  }

  /// 根据ID删除TODO
  Future deleteTodoById(int _id, int index) async {
    _showLoading(context);
    apiService.deleteTodoById((BaseModel model) {
      _dismissLoading(context);
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        T.show(msg: "删除成功");
        setState(() {
          _todoBeanList.removeAt(index);
        });
        rebuildData();
      } else {
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      _dismissLoading(context);
    }, _id);
  }

  @override
  Widget fabWidget() {
    return _isShowFAB ? null : FloatingActionButton(
      onPressed: () {
        RouteUtil.push(context, TodoAddScreen(todoType: this.todoType, editKey: 0,));
      },
      heroTag: "todo_list",
      child: Icon(Icons.edit, color: Colors.white,),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getNoTodoList();
    });
  }

  /// 显示Loading
  _showLoading(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return new LoadingDialog(
            outsideDismiss: false,
            loadingText: "loading...",
          );
        });
  }

  /// 隐藏Loading
  _dismissLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}