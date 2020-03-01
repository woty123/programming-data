import 'package:flutter/material.dart';
import 'common.dart';

import 'package:flutter_basic/animation/animation_pages.dart';
import 'package:flutter_basic/storage/storage_pages.dart';
import 'package:flutter_basic/platform-interact/platform_interact_pages.dart';
import 'package:flutter_basic/state-managing/state-managing-pages.dart';
import 'package:flutter_basic/state-managing/counter_model.dart';
import 'package:provider/provider.dart';

void main() => runApp(new FlutterBasicWidget());

List<Page> _buildModulePages() {
  return [
    Page("动画", (context) => buildAnimationPagesWidget(context)),
    Page("存储", (context) => buildStoragePagesWidget(context)),
    Page("平台交互", (context) => buildPlatformInteractPagesWidget(context)),
    Page("状态管理", (context) => buildStateManagingPagesWidget(context)),
  ];
}

class FlutterBasicWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //for demonstrate provider
        providers: [
          Provider.value(value: 30.0),
          ChangeNotifierProvider.value(value: CounterModel())
        ],
        child: MaterialApp(
          title: "Flutter 基础示例",
          home: buildListBody("Flutter 基础示例", context, _buildModulePages()),
        ));
  }
}
