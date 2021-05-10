import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/common/user.dart';
import 'package:flutter_samples/data/api/apis_service.dart';
import 'package:flutter_samples/data/model/base_model.dart';
import 'package:flutter_samples/data/model/project_article_model.dart';
import 'package:flutter_samples/utils/route_util.dart';
import 'package:flutter_samples/utils/toast_util.dart';
import 'package:flutter_samples/widgets/custom_cached_image.dart';

import 'like_button_widget.dart';

class ItemProjectArticleList extends StatefulWidget {

  ProjectArticleBean item;

  ItemProjectArticleList({this.item});

  @override
  State<StatefulWidget> createState() {
    return ItemProjectArticleListState();
  }

}

class ItemProjectArticleListState extends State<ItemProjectArticleList> {
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
              Container(
                padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Container(
                  width: 80,
                  height: 130,
                  child: CustomCachedImage(
                    imageUrl: item.envelopePic,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Text(
                          item.title,
                          style: TextStyle(fontSize: 16),
                          maxLines: 2,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(0, 0, 8, 8),
                        child: Text(
                          item.desc,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.left,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(0, 0, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              item.author.isNotEmpty
                                  ? item.author
                                  : item.shareUser,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              item.niceDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.fromLTRB(0, 0, 8, 8),
                        child: LikeButtonWidget(
                          isLike: item.collect,
                          onClick: () {
                            addOrCancelCollect(item);
                          },
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

  /// 添加收藏或者取消收藏
  void addOrCancelCollect(item) {
    List<String> cookies = User.singleton.cookie;
    if (cookies == null || cookies.length == 0) {
      T.show(msg: '请先登录~');
    } else {
      if (item.collect) {
        apiService.cancelCollection((BaseModel model) {
          if (model.errorCode == Constants.STATUS_SUCCESS) {
            T.show(msg: '已取消收藏~');
            setState(() {
              item.collect = false;
            });
          } else {
            T.show(msg: '取消收藏失败~');
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      } else {
        apiService.addCollection((BaseModel model) {
          if (model.errorCode == Constants.STATUS_SUCCESS) {
            T.show(msg: '收藏成功~');
            setState(() {
              item.collect = true;
            });
          } else {
            T.show(msg: '收藏失败~');
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      }
    }
  }
}