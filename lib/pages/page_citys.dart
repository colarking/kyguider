import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guider/pages/base_routers.dart';

class PageCitys extends StatelessWidget{
  late List _citys;
  PageCitys(Map map, {Key? key}) : super(key: key){
    _citys = map["citys"];
  }

  @override
  Widget build(BuildContext context) {
    var itemWidth = MediaQuery.of(context).size.width-20;
    return  Scaffold(
      appBar: AppBar(title: const Text("城市列表"),),
      body: ListView.builder(
        itemCount: _citys.length ,
        itemBuilder: (BuildContext context, int index) {
          var item = _citys[index];
          return GestureDetector(
            onTap: () {
              ARouters.push(context, ARouters.page_guiders,
                  params: {"city": item["city"]});
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10,top: 10,bottom: 10),
              child: Stack(
                children: [
                  ExtendedImage(
                    width: itemWidth,
                    height: itemWidth/2,
                    fit: BoxFit.fill,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),

                    ),
                    image: ExtendedResizeImage(
                      ExtendedNetworkImageProvider(item["img"]
                      ),
                      compressionRatio: 0.1,
                      maxBytes: 1000 << 10,
                      width: itemWidth.toInt(),
                      height: itemWidth.toInt(),
                    ),
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.failed:
                          return const LinearProgressIndicator();
                        case LoadState.loading:
                          return const LinearProgressIndicator();
                        case LoadState.completed:
                          return ExtendedRawImage(
                            image: state.extendedImageInfo?.image,
                            width: itemWidth,
                            height: itemWidth/2,
                            fit: BoxFit.cover,
                          );
                      }
                    },
                  ),
                  Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(child: Text(item["city"],style: const TextStyle(fontSize: 26,color: Colors.white),))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}