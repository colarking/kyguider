import 'dart:convert';

import 'package:guider/dio_util/dio_url.dart';
import 'package:guider/dio_util/dio_util.dart';
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

class PageGuider extends StatefulWidget {
  var gId = 0;

  PageGuider(Map map) {
    gId = map["gId"];
  }

  @override
  State<PageGuider> createState() => _PageGuiderState();
}

class _PageGuiderState extends State<PageGuider> {
  bool _loading = false;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }
  @override
  void dispose() {
    super.dispose();
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    String? htmlStr = _data["detailService"];
    return Scaffold(
      appBar: AppBar(
        title: const Text("导游详情"),
      ),
      body: _data.isEmpty
          ? Container()
          : Stack(
          fit: StackFit.expand,
          children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200.h,
                      child: Swiper(
                          itemBuilder: (BuildContext context, int index) {
                            return _getItemWidget(index);
                          },
                          itemCount: _data["coverArray"].length,
                          outer: false,
                          scrollDirection: Axis.horizontal,
                          loop: true,
                          duration: 2000,
                          autoplay: false,
                          onIndexChanged: (index) {},
                          onTap: (index) {},
                          pagination: const SwiperPagination(
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.only(bottom: 15),
                              builder: DotSwiperPaginationBuilder(
                                color: Colors.grey,
                                activeColor: Colors.white,
                              )),
                          autoplayDisableOnInteraction: true),
                    ),
                    Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _data["gTitle"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                              color: Colors.black, fontSize: 20),
                        )),
                    Row(
                      children: [
                        const SizedBox(width: 10,height: 10,),
                        const Icon(
                          Icons.gps_fixed_rounded,
                          size: 20,
                        ),
                        Text("${_data["city"]}"),
                      ],
                    ),
                    const SizedBox(width: 10,height: 10,),
                    _buildGuiderInfo(),
                    htmlStr != null && htmlStr.isNotEmpty?Html(
                      data: htmlStr,
                    ):const SizedBox(),
                    const SizedBox(height: 50,),
                  ],
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: (){
                      launch("tel:${_data["phone"]}");
                    },
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10,bottom: 10),
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.orange, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              // mainAxisAlignment:MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.call,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Text("电话联系",style: TextStyle(color: Colors.orange,fontSize: 20),),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
            ]),
    );
  }


  void _initData() async {
    if (_loading) {
      return;
    }
    _loading = true;
    EasyLoading.show(status: 'loading...');
    Response response =
        await DioUtil.instance.get(URL.BASE_URL + URL.BASE_DETAIL, params: {
      "gid": widget.gId.toString(),
    });
    if (response.statusCode != 200 ||
        response.data == null ||
        response.data["code"] != 0 ||
        response.data["data"] == null) {
      EasyLoading.showError(
        "获取数据失败,请重试",
      );
      // List tList = [];
      // for (int i = 0; i < 100; i++) {
      //   tList.add({"name": "name$i", "desc": "desc_$i"});
      // }
      //0 = {map entry} "cover" -> "https://najiuzou-1256768961.file.myqcloud.com/upload/20190419/1503173031ec8.png"
      // 1 = {map entry} "detailService" -> "<p>本人对成都的景点和小吃，特产等都熟悉，欢迎要来成都玩的朋友找我<img src=\"https://najiuzou-1256768961.file.myqcloud.com/upload/201..."
      // 2 = {map entry} "serviceValue" -> 5
      // 3 = {map entry} "phone" -> "18224046032"
      // 4 = {map entry} "gTitle" -> "成都向导，都江堰"
      // 5 = {map entry} "city" -> "成都"
      // 6 = {map entry} "tourImg" -> "https://najiuzou-1256768961.file.myqcloud.com/upload/20190306/103451405f954f.jpg"
      // 7 = {map entry} "speak" -> "中文"
      // 8 = {map entry} "workYear" -> "3年"
      // 9 = {map entry} "tourName" -> "邓安安"
      // 10 = {map entry} "labels" -> "[\"熟悉当地\",\"会开车\",\"热情\"]"
      // doRandomList(tList);
    } else {
      _data.addAll(response.data["data"]);
      // _refreshController.loadComplete();
      // _refreshController.refreshCompleted();
    }
    EasyLoading.dismiss();
    if (mounted) {
      setState(() {});
    }
    _loading = false;
  }


  Widget _getItemWidget(int index) {
    var itemWidth = MediaQuery.of(context).size.width;
    return ExtendedImage(
      width: itemWidth,
      height: itemWidth / 2,
      fit: BoxFit.fill,
      shape: BoxShape.rectangle,
      image: ExtendedResizeImage(
        ExtendedNetworkImageProvider(_data["coverArray"]?[index] ??
            "http://img02.sogoucdn.com/app/a/100520021/6c75534cd8e4556515a68e0e8e02e3de"),
        compressionRatio: 0.1,
        maxBytes: 1000 << 10,
        width: itemWidth.toInt(),
        height: itemWidth ~/ 2,
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
              height: itemWidth,
              fit: BoxFit.cover,
            );
        }
      },
    );
  }

  _buildGuiderInfo() {
    var itemWidth = 100.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 10,
        ),
        ExtendedImage(
          width: itemWidth,
          height: itemWidth,
          fit: BoxFit.fill,
          shape: BoxShape.circle,
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          image: ExtendedResizeImage(
            ExtendedNetworkImageProvider(_data["tourImg"]),
            compressionRatio: 0.1,
            maxBytes: 1000 << 10,
            width: itemWidth.toInt(),
            height: itemWidth ~/ 2,
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
                  height: itemWidth,
                  fit: BoxFit.cover,
                );
            }
          },
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _data["tourName"],
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            Wrap(
              children: _buildTags(_data["labels"]),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              width: 250.0.w,
              child: Text("${_data["workYear"]}|${_data["speak"]}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:const TextStyle(
                    fontSize: 14.0,
                  )
              )),
          ],
        ),
      ],
    );
  }

  _buildTags(dataStr) {
    var data = jsonDecode(dataStr);
    List<Widget> wids = [];
    for (var item in data) {
      wids.add(Container(
        margin: const EdgeInsets.only(right: 10, top: 5),
        padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey, width: 0.5),
        ),
        child: Text(item),
      ));
    }
    return wids;
  }
}
