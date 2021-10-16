import 'dart:convert';
import 'dart:math';

import 'package:guider/dio_util/dio_url.dart';
import 'package:guider/dio_util/dio_util.dart';
import 'package:guider/pages/base_routers.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:url_launcher/url_launcher.dart';

class PageTabGuiders extends StatefulWidget {
  @override
  State<PageTabGuiders> createState() => _PageTabGuiderState();
}

class _PageTabGuiderState extends State<PageTabGuiders> {
  bool _loading = false;
  var _list = [];
  var _cityList = [];
  bool _haveCity = false;

  var cityCallback;
  var itemCallback;

  @override
  void initState() {
    super.initState();
    _initData();
    cityCallback =  (item) async {
      //{cover: https://najiuzou-1256768961.file.myqcloud.com/upload/20191230/224144191bc9a0.jpg,
      // gid: 382,
      // gTitle: 【春日相约｜四川全境+周边游】专业中级中英文导游+成都市-熊猫基地-都江堰-青城山-峨眉山-乐山大佛-九寨沟-稻城亚丁等},
      // ARouters.push(
      //     context, ARouters.page_detail, params: {"accountId": item['accountId']});
      // var aRouters = ARouters.push(context, ARouters.page_guider,params: {"gId":gid});
    };
    itemCallback =  (gid) async {
      //{cover: https://najiuzou-1256768961.file.myqcloud.com/upload/20191230/224144191bc9a0.jpg,
      // gid: 382,
      // gTitle: 【春日相约｜四川全境+周边游】专业中级中英文导游+成都市-熊猫基地-都江堰-青城山-峨眉山-乐山大佛-九寨沟-稻城亚丁等},
      // ARouters.push(
      //     context, ARouters.page_detail, params: {"accountId": item['accountId']});
      // var aRouters = ARouters.push(context, ARouters.page_guider,params: {"gId":gid});
      var aRouters = ARouters.push(context, ARouters.page_guiders,
          params: {"cityMode":false,"guideId":gid.toString()});
    };
  }
  @override
  void dispose() {
    super.dispose();
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    var fullWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: _list.isEmpty
          ? Center(
        child: TextButton(
          onPressed: () {
            _initData();
            setState(() {

            });
          },
          child: Text(_loading?"正在加载...":"暂无数据,点击重试",style: const TextStyle(fontSize: 25),),
        ),
      )
          :
      CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  buildCityItem(),
                ],
              ),
            ),
            SliverGrid(
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              delegate: SliverChildListDelegate(
                _buildGridItems(),
              ),
            ),
          ]),
    );
  }


  void _initData() async {
    if (_loading) {
      return;
    }
    _loading = true;
    Response response =
        await DioUtil.instance.get(URL.BASE_URL + URL.BASE_TAB_GUIDERS,);
    if (response.statusCode != 200 ||
        response.data == null ||
        response.data["code"] != 0 ||
        response.data["data"] == null ||response.data["data"] =="") {
    } else {
      var data = response.data["data"];
      if (data["cityList"] != null) {
        _cityList = data["cityList"];
        _haveCity = _cityList.isNotEmpty;
      }
      // "guideId" -> 10653
      //"guideImg" -> "https://najiuzou-1256768961.file.myqcloud.com/upload/20181219/1732173188dc8e.png"
      //"guideName" -> "朱海波"

      _list.addAll(response.data["data"]["guideList"]);
    }
    _loading = false;
    if (mounted) {
      setState(() {});
    }

  }

  Widget buildCityItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            const Expanded(child: Text("热门城市")),
            GestureDetector(
                onTap: () {
                  ARouters.push(context, ARouters.page_citys,
                      params: {"citys": _cityList});
                },
                child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: const Text("查看全部"))),
          ],
        ),
        Row(
          children: _buildCityItem(),
        ),
      ],
    );
  }
  _buildCityItem() {
    var fullWidth = MediaQuery.of(context).size.width;
    List<Widget> wids = [];
    double itemWidth = (fullWidth - (4) * 10) / 3;
    var maxSize = _cityList.length > 3 ? 3 : _cityList.length;
    var itemCallback = (value) {
      var aRouters = ARouters.push(context, ARouters.page_guiders,
          params: {"cityMode":false,"guideId":value});
    };
    for (var i = 0; i < maxSize; i++) {
      var item = _cityList[i];
      var title = item["guideName"] ?? "";
      var imgUrl = item["guideImg"] ??
          "http://img02.sogoucdn.com/app/a/100520021/199075a69e82debad565c070093484ca";
      wids.add(_buildItemWidget(imgUrl, title,item["guideId"], itemCallback,itemWidth: itemWidth));
    }
    return wids;
  }
  Widget _buildItemWidget(imgUrl,title,gid,callback,{itemWidth = 250.0,itemHeight = 150.0}) {
    return GestureDetector(
      onTap: ()=>callback.call(gid),
      child: Container(
        margin: EdgeInsets.only(left: 10, top: 10,right: (itemWidth==250?10.0:0.0)),
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
            Container(
                padding: const EdgeInsets.only(left: 10,top: 10, right: 10,bottom: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  maxLines:  1,
                )),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGridItems() {
    List<Widget> wids = [];
    _list.forEach((item) {
      wids.add(_buildItemWidget(item["guideImg"],item["guideName"],item["guideId"],itemCallback));
    });
    return wids;

  }


}
