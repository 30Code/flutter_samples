import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/common/common.dart';
import 'package:flutter_samples/common/user.dart';
import 'package:flutter_samples/data/api/apis_service.dart';
import 'package:flutter_samples/data/model/base_model.dart';
import 'package:flutter_samples/data/model/knowledge_detail_model.dart';
import 'package:flutter_samples/utils/route_util.dart';
import 'package:flutter_samples/utils/toast_util.dart';
import 'package:flutter_samples/widgets/custom_cached_image.dart';
import 'package:flutter_samples/widgets/like_button_widget.dart';

class ItemKnowledgeDetailList extends StatefulWidget {

  KnowledgeDetailChild item;

  ItemKnowledgeDetailList({this.item});

  @override
  State<StatefulWidget> createState() {
    return new ItemKnowledgeDetailListState();
  }

}

class ItemKnowledgeDetailListState extends State<ItemKnowledgeDetailList> {
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
                offstage: item.envelopePic == "",
                child: Container(
                  width: 100,
                  height: 80,
                  padding: EdgeInsets.fromLTRB(16, 10, 8, 10),
                  child: CustomCachedImage(imageUrl: item.envelopePic,),
                ),
              ),
              Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Row(
                          children: <Widget>[
                            Text(
                              item.author.isNotEmpty ? item.author : item.shareUser,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              textAlign: TextAlign.left,
                            ),
                            Expanded(
                                child: Text(
                                  item.niceDate,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  textAlign: TextAlign.right,
                                ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 2,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text(
                                  item.chapterName,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  textAlign: TextAlign.left,
                                ),
                            ),
                            LikeButtonWidget(
                              isLike: item.collect,
                              onClick: () {
                                addOrCancelCollect(item);
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

  /// ??????????????????????????????
  void addOrCancelCollect(item) {
    List<String> cookies = User.singleton.cookie;
    if (cookies == null || cookies.length == 0) {
      T.show(msg: '????????????~');
    } else {
      if (item.collect) {
        apiService.cancelCollection((BaseModel model) {
          if (model.errorCode == Constants.STATUS_SUCCESS) {
            T.show(msg: '???????????????~');
            setState(() {
              item.collect = false;
            });
          } else {
            T.show(msg: '??????????????????~');
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      } else {
        apiService.addCollection((BaseModel model) {
          if (model.errorCode == Constants.STATUS_SUCCESS) {
            T.show(msg: '????????????~');
            setState(() {
              item.collect = true;
            });
          } else {
            T.show(msg: '????????????~');
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      }
    }
  }
}