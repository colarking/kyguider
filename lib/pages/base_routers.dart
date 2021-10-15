
import 'package:guider/pages/page_citys.dart';
import 'package:guider/pages/page_guider.dart';
import 'package:guider/pages/page_guiders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef BaseCallback = Function(dynamic);
class ARouters{

  static const page_guider = 'app://guider';
  static const page_citys = 'app://citys';
  static const page_guiders = 'app://guiders';
  static const page_web = 'app://web';
  ARouters.push(BuildContext context, String url,
      { dynamic params,BaseCallback? callback}) {
    Future<dynamic> future =
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return _dispatchPage(url, params);
    }));
    if (callback != null) {
      future.then((value) => callback.call(value));
    }
  }

  Widget _dispatchPage(String url, params) {

      switch (url) {
        case page_guiders:
          return PageGuiders(params);
        case page_citys:
          return PageCitys(params);
        case page_guider:
          return PageGuider(params);
      }
    return Container(color: Colors.grey,child: const Text("未知页面"),);
  }
}