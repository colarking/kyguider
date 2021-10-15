
import 'dart:math';

import 'package:guider/dio_util/dio_url.dart';
import 'package:guider/dio_util/dio_util.dart';
import 'package:guider/pages/base_routers.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PageGuiders extends StatefulWidget{

  String cityName = "";

  PageGuiders(Map params, {Key? key}) : super(key: key){
    cityName = params["city"]??"";
  }

  @override
  State<PageGuiders> createState() => _PageGuidersState();
}

class _PageGuidersState extends State<PageGuiders> {
  var _page = 0;
  var _list = [];

  bool _loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initData();
  }

  _initData() async {
    if(_loading){
      return;
    }
    _loading = true;
    EasyLoading.show(status: 'loading...');
    Response response =
    await DioUtil.instance.get(URL.BASE_URL + URL.BASE_LIST, params: {
      "page": _page,
      "cityName":widget.cityName,
    });
    if (response.statusCode != 200 ||
        response.data == null ||
        response.data["code"] != 0 ||
        response.data["data"] == null
    ) {
      EasyLoading.showError(
        "获取数据失败,请重试",
      );
      // List tList = [];
      // for (int i = 0; i < 100; i++) {
      //   tList.add({"name": "name$i", "desc": "desc_$i"});
      // }
      // doRandomList(tList);
    } else {
      Map<String, dynamic> data = response.data["data"];
      if (data["guideObj"] != null) {
        if (_page == 0) {
          _list.clear();
        }
        doRandomList(data["guideObj"]);
        _page++;
      }
      // _refreshController.loadComplete();
      // _refreshController.refreshCompleted();
    }
    EasyLoading.dismiss();
    if (mounted) {
      setState(() {});
    }
    _loading = false;
  }

  void doRandomList(List<dynamic> tList) {
    var random = Random();
    for (int i = 0; i < tList.length;) {
      var showItemCount = random.nextInt(10000) % 3 + 1;
      if (showItemCount == 2 && i >= tList.length - 1) {
        showItemCount = 1;
      } else if (showItemCount == 3 && i >= tList.length - 2) {
        showItemCount = 1;
      }
      switch (showItemCount) {
        case 1:
          _list.add([tList[i]]);
          i++;
          break;
        case 2:
          _list.add([tList[i], tList[i + 1]]);
          i += 2;
          break;
        case 3:
          _list.add([tList[i], tList[i + 1], tList[i + 2]]);
          i += 3;
          break;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    var fullWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.cityName}导游列表"),
      ),
      body:
      ListView.builder(
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          var item = _list[index];
          return  Row(
            children: _buildItem(context, item, item.length, fullWidth),
          );
        },
      ),


    );
  }

  List<Widget> _buildItem(
      context, List itemList, int length, double fullWidth) {
    List<Widget> wids = [];
    double itemWidth = (fullWidth - (length + 1) * 10) / length;
    itemList.forEach((item) {
      var title = item["gTitle"] ?? "";
      var imgUrl = item["cover"] ??
          "http://img02.sogoucdn.com/app/a/100520021/199075a69e82debad565c070093484ca";
      wids.add(_buildItemWidget(fullWidth,itemWidth,length,title,item["gid"],imgUrl));
    });
    return wids;
  }

  Widget _buildItemWidget(fullWidth,itemWidth,length,title,gid, imgUrl) {
    var itemHeight = length == 1?itemWidth/2:itemWidth;
    return GestureDetector(
      onTap: () async {
        //{cover: https://najiuzou-1256768961.file.myqcloud.com/upload/20191230/224144191bc9a0.jpg,
        // gid: 382,
        // gTitle: 【春日相约｜四川全境+周边游】专业中级中英文导游+成都市-熊猫基地-都江堰-青城山-峨眉山-乐山大佛-九寨沟-稻城亚丁等},
        // ARouters.push(
        //     context, ARouters.page_detail, params: {"accountId": item['accountId']});
        var aRouters = ARouters.push(context, ARouters.page_guider,params: {"gId":gid});
      },
      child: Container(
        height: itemHeight + 50,
        constraints:
        BoxConstraints(maxHeight: itemHeight + 50, maxWidth: itemWidth),
        margin: const EdgeInsets.only(left: 10, top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 1,
              spreadRadius: 1,
            ),
            const BoxShadow(
              offset: Offset(1.5, 1.5),
              color: Colors.black12,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: itemHeight,
              child: Stack(
                children: [
                  ExtendedImage(
                    width: itemWidth,
                    height: itemHeight,
                    fit: BoxFit.fill,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    image: ExtendedResizeImage(
                      ExtendedNetworkImageProvider(imgUrl
                      ),
                      compressionRatio: 0.1,
                      maxBytes: 1000 << 10,
                      width: itemWidth.toInt(),
                      height: itemHeight.toInt(),
                    ),
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.failed:
                          return LinearProgressIndicator();
                        case LoadState.loading:
                          return LinearProgressIndicator();
                        case LoadState.completed:
                          return ExtendedRawImage(
                            image: state.extendedImageInfo?.image,
                            width: itemWidth,
                            height: itemHeight,
                            fit: BoxFit.cover,
                          );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                      fontSize: length == 1
                          ? 14
                          : length == 2
                          ? 12
                          : 10),
                  maxLines: length == 3 ? 3 : 2,
                )),
          ],
        ),
      ),
    );
  }
}