import 'package:flutter/material.dart';
import 'package:flutter_basic/common.dart';

//导航
import 'package:flutter_basic/navigator/01_base-router.dart';
import 'package:flutter_basic/navigator/02_base-roter-pass.dart';
import 'package:flutter_basic/navigator/03_base-router-return.dart';
import 'package:flutter_basic/navigator/04-named-router.dart';

List<Page> _buildRoutes() {
  return [
    //basic navigator
    Page("BaseRouter", (context) => buildBaseRouterWidget()),
    Page("BaseRouter PassValue", (context) => buildBaseRouterPassWidget()),
    Page("BaseRouter ReturnValue", (context) => buildBaseRouterGetWidget()),
    Page("NamedRouter", (context) => buildNamedRouterWidget()),
  ];
}

Widget buildNavigationPagesWidget(BuildContext context) =>
    buildListBody("导航", context, _buildRoutes());