import 'dart:math';

import 'package:guider/dio_util/dio_url.dart';
import 'package:guider/dio_util/dio_util.dart';
import 'package:guider/pages/base_routers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 667),
      builder: () {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(
            title: '找导游',
          ),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _list = [];
  var _cityList = [];
  var _page = 0;
  var _loading = false;
  double itemWidth = 0.0;

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  var _tabIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Future.delayed(const Duration(milliseconds: 2000),() {
    //   Navigator.of(context).pop();
    //   ARouters.push(context, ARouters.page_detail);
    // });

    _initData();
  }

  _initPop() async {
    Response response = await DioUtil.instance.get(URL.BASE_URL + URL.BASE_POP);
    if (response.statusCode != 200 ||
        response.data == null ||
        response.data["code"] != 0 ||
        response.data["data"] == null) {
    } else {
      // print("_initPop()...${response.data["data"]}");
      var iosUrl = response.data["data"]["iosUrl"];
      var iosImg = response.data["data"]["iosImg"];
      var needDisplay = response.data["data"]["needDisplay"];
      if (needDisplay == 1 && !isEmpty(iosImg) && !isEmpty(iosUrl)) {
        _showPopDialog(iosImg, iosUrl, needDisplay);
      } else if (needDisplay == 2 && !isEmpty(iosUrl)) {
        Navigator.of(context).pop();
        ARouters.push(context, ARouters.page_web,
            params: {"title": "网页", "url": iosUrl});
      }
    }
  }

  isEmpty(String? text) {
    return text == null || text.isEmpty;
  }

  void _showPopDialog(iosImg, iosUrl, needDisplay) {
    AwesomeDialog(
      dismissOnTouchOutside: false,
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      padding: EdgeInsets.zero,
      showCloseIcon: false,
      body: Center(
        child: GestureDetector(
          onTap: () {
            launch(iosUrl);
          },
          child: ExtendedImage(
            width: 300,
            height: 500,
            image: ExtendedResizeImage(
              ExtendedNetworkImageProvider(
                iosImg,
              ),
              compressionRatio: 0.1,
              maxBytes: 1000 << 10,
              width: null,
              height: null,
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
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                  );
              }
            },
          ),
        ),
      ),
    ).show();
  }

  _initData() async {
    EasyLoading.show(status: 'loading...');
    Response response =
    await DioUtil.instance.get(URL.BASE_URL + URL.BASE_LIST, params: {
      "page": _page,
    });
    if (_page == 0) {
      _initPop();
    }
    if (response.statusCode != 200 ||
        response.data == null ||
        response.data["code"] != 0) {
      EasyLoading.showError(
        "获取数据失败,请重试",
      );
    } else if (response.data["data"] == null) {
      _refreshController.refreshCompleted();
      _refreshController.loadNoData();
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
      if (data["cityObj"] != null) {
        _cityList = data["cityObj"];
      }
      _refreshController.loadComplete();
      _refreshController.refreshCompleted();
    }
    EasyLoading.dismiss();
    if (mounted) {
      setState(() {});
    }
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: _list.isEmpty
                ? Container()
                : SmartRefresher(
              controller: _refreshController,
              onLoading: _initData,
              enablePullUp: true,
              onRefresh: () {
                _page = 0;
                _initData();
              },
              child: ListView.builder(
                itemCount: _list.length + (_cityList.isEmpty ? 0 : 1),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0 && _cityList.isNotEmpty) {
                    return buildCityItem();
                  }
                  var item = _list[index];
                  return PageItem(item);
                },
              ),
              // GridView.builder(
              //   // controller: _scrollController,
              //     itemCount: _list.length,
              //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 1,
              //       mainAxisSpacing: 10,
              //       childAspectRatio: 0.75,
              //     ),
              //     itemBuilder: (context, index) {
              //       var item = _list[index];
              //       return PageItem(item);
              //     }),
            ),
          ),
          _buildGuidersPage(),
          _buildMinePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabIndex,
          fixedColor: Colors.blue,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            buildBottomNavigationBarItem(Icons.supervised_user_circle, "旅游"),
            buildBottomNavigationBarItem(Icons.account_circle_outlined, "导游"),
            buildBottomNavigationBarItem(Icons.workspaces_outline, "我的"),
          ]),
    );
  }

  void _onItemTapped(int value) {
    if (_tabIndex != value) {
      _tabIndex = value;
      setState(() {});
    }
  }
  BottomNavigationBarItem buildBottomNavigationBarItem(
      IconData icon, String label) {
    return BottomNavigationBarItem(
        icon: Icon(
          icon,
          size: 32,
        ),
        activeIcon: Icon(
          icon,
          color: Colors.blue,
          size: 32,
        ),
        label: label);
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
                    margin: EdgeInsets.only(right: 10),
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
          params: {"city": value});
    };
    for (var i = 0; i < maxSize; i++) {
      var item = _cityList[i];
      var title = item["city"] ?? "";
      var imgUrl = item["img"] ??
          "http://img02.sogoucdn.com/app/a/100520021/199075a69e82debad565c070093484ca";
      wids.add(_buildItemWidget(
          fullWidth, itemWidth, 3, title, imgUrl, title, itemCallback, 18.0));
    }
    return wids;
  }

  _buildGuidersPage() {
    return Container(
      color: Colors.orange,
    );
  }

  _buildMinePage() {
    return Container(
      color: Colors.purple,
    );
  }
}

class PageItem extends StatelessWidget {
  List list;

  PageItem(this.list);

  @override
  Widget build(BuildContext context) {
    var fullWidth = MediaQuery.of(context).size.width;
    return Row(
      children: _buildItem(context, list, list.length, fullWidth),
    );
  }

  List<Widget> _buildItem(
      context, List itemList, int length, double fullWidth) {
    List<Widget> wids = [];
    double itemWidth = (fullWidth - (length + 1) * 10) / length;
    var itemCallback = (value) =>
        ARouters.push(context, ARouters.page_guider, params: {"gId": value});
    itemList.forEach((item) {
      var title = item["gTitle"] ?? "";
      var imgUrl = item["cover"] ??
          "http://img02.sogoucdn.com/app/a/100520021/199075a69e82debad565c070093484ca";
      double size = length == 1
          ? 14
          : length == 2
          ? 12
          : 10;
      wids.add(_buildItemWidget(fullWidth, itemWidth, length, title, imgUrl,
          item["gid"], itemCallback, size));
    });
    return wids;
  }
}

Widget _buildItemWidget(fullWidth, itemWidth, length, title, imgUrl, id,
    itemCallback, double fontSize) {
  var itemHeight = length == 1 ? itemWidth / 2 : itemWidth;
  return GestureDetector(
    onTap: () async {
      //{cover: https://najiuzou-1256768961.file.myqcloud.com/upload/20191230/224144191bc9a0.jpg,
      // gid: 382,
      // gTitle: 【春日相约｜四川全境+周边游】专业中级中英文导游+成都市-熊猫基地-都江堰-青城山-峨眉山-乐山大佛-九寨沟-稻城亚丁等},
      // ARouters.push(
      //     context, ARouters.page_detail, params: {"accountId": item['accountId']});
      itemCallback.call(id);
    },
    child: Container(
      constraints: BoxConstraints(
          maxHeight: itemHeight + 60,
          minHeight: itemHeight + 40,
          maxWidth: itemWidth),
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
                    ExtendedNetworkImageProvider(imgUrl),
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
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                maxLines: length == 3 ? 3 : 2,
              )),
        ],
      ),
    ),
  );
}
