import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/common/application.dart';
import 'package:flutter_samples/event/refresh_todo_event.dart';
import 'package:flutter_samples/ui/todo_complete_screen.dart';
import 'package:flutter_samples/ui/todo_list_screen.dart';
import 'package:flutter_samples/utils/theme_util.dart';

/// TODO 页面
class TodoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoScreenState();
  }
}

class TodoScreenState extends State<TodoScreen> with AutomaticKeepAliveClientMixin {

  int _selectedIndex = 0;

  final bottomBarTitles = ["待办", "已完成"];

  int _todoSelectedIndex = 0;

  final todoTypeList = ["只用这一个", "工作", "学习", "生活"];

  PageController _pageController = PageController();

  var pages = <Widget>[TodoListScreen(), TodoCompleteScreen()];

  selectView(String text, int index) => new PopupMenuItem(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
              color: index == _todoSelectedIndex ? Colors.cyan : ThemeUtils.dark ? Colors.white : Colors.black,
          ),
        ),
      ],
    ),
    value: index,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(todoTypeList[_todoSelectedIndex]),
        bottom: null,
        elevation: 0.4,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) => <PopupMenuItem<int>>[
              this.selectView(todoTypeList[0], 0),
              this.selectView(todoTypeList[1], 1),
              this.selectView(todoTypeList[2], 2),
              this.selectView(todoTypeList[3], 3),
            ],
            onSelected: (index) {
              setState(() {
                _todoSelectedIndex = index;
              });
              Application.eventBus.fire(RefreshTodoEvent(index));
            },
          ),
        ],
      ),
      body: PageView.builder(
        itemBuilder: (context, index) => pages[index],
        itemCount: pages.length,
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.description),
              title: Text(bottomBarTitles[0]),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            title: Text(bottomBarTitles[1]),
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}