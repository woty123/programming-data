import 'dart:async';

import 'package:flutter/material.dart';
import 'common.dart';

import 'package:flutter_basic/widget_animation/animation_pages.dart';
import 'package:flutter_basic/storage/storage_pages.dart';
import 'package:flutter_basic/platform-interact/platform_interact_pages.dart';
import 'package:flutter_basic/state-managing/state-managing-pages.dart';
import 'package:flutter_basic/state-managing/counter_model.dart';

import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/i18n.dart';

void main() {
  //重写错误处理
  FlutterError.onError = (FlutterErrorDetails details) async {
    // 转发至 Zone 中
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };

    //自定义错误界面
  /*ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails){
    print(flutterErrorDetails.toString());
    return Scaffold(
        body: Center(
          child: Text("Custom Error Widget"),
        )
    );
  };*/

  //以沙盒机制运行 app
  runZoned(() async {
    runApp(new FlutterBasicWidget());
  }, onError: (error) async {
    print("error: $error");
  });
}

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
          //国际化翻译代理
          localizationsDelegates: [
            S.delegate,
            // ... app-specific localization delegate[s] here
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          //设置支持的语言
          supportedLocales: S.delegate.supportedLocales,
          //动态的设置title，便于国际化
          onGenerateTitle: (context) {
            return S
                .of(context)
                .app_title;
          },
          //性能检测开关
          checkerboardOffscreenLayers: false,
          checkerboardRasterCacheImages: false,
          //首页
          home: buildListBody("Flutter", context, _buildModulePages()),
        ));
  }
}
