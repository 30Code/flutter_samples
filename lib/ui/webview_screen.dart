import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/utils/route_util.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';

/// WebView 加载网页页面
class WebViewScreen extends StatefulWidget {

  /// 标题
  String title;
  /// 链接
  String url;

  WebViewScreen({Key key, @required this.title, @required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new WebViewScreenState();
  }
}

class WebViewScreenState extends State<WebViewScreen> {

  bool isLoad = true;

  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.onStateChanged.listen((event) {
      if (event.type == WebViewState.finishLoad) {
        setState(() {
          isLoad = false;
        });
      } else if (event.type == WebViewState.startLoad) {
        setState(() {
          isLoad = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url,
      appBar: new AppBar(
        elevation: 0.4,
        title: new Text(widget.title),
        bottom: new PreferredSize(
            child: SizedBox(
              height: 2,
              child: isLoad ? new LinearProgressIndicator() : Container(),
            ),
            preferredSize: Size.fromHeight(2)
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                RouteUtil.launchInBrowser(widget.url, title: widget.title);
              },
              icon: Icon(Icons.language, size: 20,)
          ),
          IconButton(
              onPressed: () {
                Share.share('${widget.title} : ${widget.url}');
              },
              icon: Icon(Icons.share, size: 20,)
          ),
        ],
      ),
      withZoom: false,
      withLocalStorage: true,
      withJavascript: true,
      hidden: true,
    );
  }

  @override
  void dispose() {
    flutterWebViewPlugin.dispose();
    super.dispose();
  }
}