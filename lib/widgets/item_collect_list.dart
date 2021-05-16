import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/common/user.dart';
import 'package:flutter_samples/data/api/apis_service.dart';
import 'package:flutter_samples/data/model/base_model.dart';
import 'package:flutter_samples/data/model/collection_model.dart';
import 'package:flutter_samples/utils/route_util.dart';
import 'package:flutter_samples/utils/toast_util.dart';
import 'package:flutter_samples/widgets/custom_cached_image.dart';
import 'package:flutter_samples/widgets/like_button_widget.dart';

class ItemCollectList extends StatefulWidget {

  CollectionBean item;

  /// 收藏的回调函数
  Function onCollectCallback;

  ItemCollectList({this.item, this.onCollectCallback});

  @override
  State<StatefulWidget> createState() {
    return ItemCollectListState();
  }

}

class ItemCollectListState extends State<ItemCollectList> {
  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    return InkWell(
      onTap: () {
        RouteUtil.toWebView(context, item.title, item.link);
      },
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Offstage(
                offstage: item.envelopePic == '',
                child: Container(
                  width: 100,
                  height: 80,
                  padding: EdgeInsets.fromLTRB(16, 10, 8, 10),
                  child: CustomCachedImage(imageUrl: item.envelopePic, fit: BoxFit.fill ,),
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: item.envelopePic.isNotEmpty ? EdgeInsets.fromLTRB(8, 10, 16, 10) : EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            item.author,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            textAlign: TextAlign.left,
                          ),
                          Expanded(
                            child: Text(
                              item.niceDate,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600],),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: item.envelopePic.isNotEmpty ? EdgeInsets.fromLTRB(8, 10, 16, 10) : EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 2,
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: item.envelopePic.isNotEmpty ? EdgeInsets.fromLTRB(8, 10, 16, 10) : EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(
                                item.chapterName,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600],),
                                textAlign: TextAlign.left,
                              ),
                          ),
                          LikeButtonWidget(
                            isLike: true,
                            onClick: () {
                              cancelCollect(item);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1,),
        ],
      ),
    );
  }

  /// 取消收藏
  void cancelCollect(item) {
    List<String> cookies = User.singleton.cookie;
    if (cookies == null || cookies.length == 0) {
      T.show(msg: '请先登录~');
    } else {
      apiService.cancelCollection((BaseModel model) {
        if (model.errorCode == Constants.STATUS_SUCCESS) {
          T.show(msg: '已取消收藏~');
          widget.onCollectCallback(true);
        } else {
          T.show(msg: '取消收藏失败~');
          widget.onCollectCallback(false);
        }
      }, (DioError error) {
        print(error.response);
      }, item.originId);
    }
  }
}