import 'dart:async';

import 'package:flutter/services.dart';

class HelloPlugin {

  static const MethodChannel _channel = const MethodChannel('hello_plugin');

  static void init() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  // 注册原生反向回调方法，让原生代码宿主可以执行 onOpenNotification 方法
  static Future<Null> _handleMethod(MethodCall call) {
    switch (call.method) {
      case "callFlutter":
        return Future(() {
          return null;
        });
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

}
