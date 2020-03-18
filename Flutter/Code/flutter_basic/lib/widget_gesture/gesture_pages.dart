import 'package:flutter/material.dart';
import 'package:flutter_basic/common.dart';

//手势
import 'package:flutter_basic/widget_gesture/01_GestureDetector.dart';
import 'package:flutter_basic/widget_gesture/02_InkWell.dart';
import 'package:flutter_basic/widget_gesture/03_dismissible-item.dart';
import 'package:flutter_basic/widget_gesture/04_draw-signature.dart';
import 'package:flutter_basic/widget_gesture/05_listener.dart';
import 'package:flutter_basic/widget_gesture/06-dragable.dart';
import 'package:flutter_basic/widget_gesture/07-RawGestureDetector.dart';


List<Page> _buildRoutes() {
  return [
    //basic gesture
    Page("Tapable", (context) => buildTapAbleWidget()),
    Page("InkWell", (context) => buildInkWellWidget()),
    Page("Dismissible", (context) => buildDismissibleWidget()),
    Page("Drawable", (context) => buildDrawableWidget()),
    Page("TouchEventListener", (context) => buildTouchEventListenerWidget()),
    Page("Dragable", (context) => buildDragableWidget()),
    Page("RawGestureDetector", (context) => buildDoubleGestureWidget()),
  ];
}

Widget buildGesturePagesWidget(BuildContext context) =>
    buildListBody("手势", context, _buildRoutes());