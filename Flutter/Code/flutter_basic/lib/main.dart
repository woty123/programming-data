import 'package:flutter/material.dart';

//基础组件
import 'package:flutter_basic/widget/00_hello_world.dart';
import 'package:flutter_basic/widget/01_basic_widget.dart';
import 'package:flutter_basic/widget/02_material_widget.dart';
import 'package:flutter_basic/widget/03_process_gesture.dart';
import 'package:flutter_basic/widget/04_stateful_widget.dart';
import 'package:flutter_basic/widget/05_shopping_cart.dart';
import 'package:flutter_basic/widget/06_inherited_widget.dart';

//图片展示
import 'package:flutter_basic/image/01_display_images.dart';

//列表
import 'package:flutter_basic/list/01_simple_listview.dart';
import 'package:flutter_basic/list/02_horizontal_listview.dart';
import 'package:flutter_basic/list/03_long_listview.dart';
import 'package:flutter_basic/list/04_multi_type_listview.dart';
import 'package:flutter_basic/list/05_grid.dart';
import 'package:flutter_basic/list/06_load_more_list.dart';
import 'package:flutter_basic/list/07_sliver_scroll.dart';
import 'package:flutter_basic/list/08_notification_listener.dart';

//手势
import 'package:flutter_basic/gesture/01_GestureDetector.dart';
import 'package:flutter_basic/gesture/02_InkWell.dart';
import 'package:flutter_basic/gesture/03_dismissible-item.dart';
import 'package:flutter_basic/gesture/04_draw-signature.dart';
import 'package:flutter_basic/gesture/05_listener.dart';
import 'package:flutter_basic/gesture/06-dragable.dart';
import 'package:flutter_basic/gesture/07-RawGestureDetector.dart';

//布局
import 'package:flutter_basic/layout/01_layout.dart';
import 'package:flutter_basic/layout/02_layout.dart';
import 'package:flutter_basic/layout/03_constrained_box.dart';
import 'package:flutter_basic/layout/04_material_pager1.dart';
import 'package:flutter_basic/layout/05_material_pager2.dart';
import 'package:flutter_basic/layout/06_update-item.dart';

//动画
import 'package:flutter_basic/animation/01_zoomin_logo.dart';
import 'package:flutter_basic/animation/02_animated_widget.dart';

//自定义View
import 'package:flutter_basic/custom-view/draw-cake.dart';

//导航
import 'package:flutter_basic/navigator/01_simple_navigator.dart';
import 'package:flutter_basic/navigator/02_pass_values.dart';
import 'package:flutter_basic/navigator/03_return_values.dart';

//网络
import 'package:flutter_basic/network/01_http.dart';
import 'package:flutter_basic/network/02_web_socket.dart';
import 'package:flutter_basic/network/03_loading_status.dart';

//生命周期
import 'package:flutter_basic/lifecycle/LifecyclePage.dart';

import 'common.dart';

void main() => runApp(new FlutterBasicWidget());

List<Page> _buildRoutes() {
  return [
    //basic widget
    Page("Text", (context) => buildHelloWorldApp()),
    Page("Basic", (context) => buildBasicWidgetApp()),
    Page("Material", (context) => buildMaterialWidget()),
    Page("TapAbleButton", (context) => buildTapAbleButton()),
    Page("Stateful", (context) => buildStatefulWidget()),
    Page("ShoppingCartList", (context) => buildShoppingCartList()),
    Page("Inherited", (context) => buildInheritedWidget()),
    //basic image
    Page("ImageList", (context) => buildImageList()),
    //basic list
    Page("SimpleList", (context) => buildSimpleList()),
    Page("HorizontalListView", (context) => buildHorizontalListView()),
    Page("LongListView", (context) => buildLongListView()),
    Page("MultiListView", (context) => buildMultiListView()),
    Page("GridView", (context) => buildGridViewWidget()),
    Page("InfiniteListView", (context) => buildInfiniteListView()),
    Page("CustomScrollView", (context) => buildCustomScrollView()),
    Page("ScrollNotification", (context) => buildScrollNotificationWidget()),
    //basic gesture
    Page("Tapable", (context) => buildTapAbleWidget()),
    Page("InkWell", (context) => buildInkWellWidget()),
    Page("Dismissible", (context) => buildDismissibleWidget()),
    Page("Drawable", (context) => buildDrawableWidget()),
    Page("TouchEventListener", (context) => buildTouchEventListenerWidget()),
    Page("Dragable", (context) => buildDragableWidget()),
    Page("RawGestureDetector", (context) => buildDoubleGestureWidget()),
    //layout
    Page("LayoutDemo", (context) => buildLayoutWidget()),
    Page("LayoutDemoInteractive", (context) => buildLayoutInteractiveWidget()),
    Page("ConstrainedBox", (context) => buildConstrainedBoxWidget()),
    Page("MaterialPager1", (context) => buildMaterialPagerWidget1()),
    Page("MaterialPager2", (context) => buildMaterialPagerWidget2()),
    Page("UpdateItem", (context) => buildUpdateItemWidget()),
    //Animation
    Page("ZoomInLogo", (context) => buildZoomInLogoWidget()),
    Page("ZoomInLogoAnimated", (context) => buildZoomInLogoAnimatedWidget()),
    //Custom View
    Page("CakeView", (context) => buildCustomCakeView()),
    //basic navigator
    Page("SimpleNavigator", (context) => buildSimpleNavigatorWidget()),
    Page("PassValuesNavigator", (context) => buildPassValuesNavigatorWidget()),
    Page("ReturningValues", (context) => buildReturningValuesWidget()),
    //net work
    Page("HttpRequesting", (context) => buildHttpRequestingWidget()),
    Page("WebSocket", (context) => buildWebSocketWidget()),
    Page("LoadingStatus", (context) => buildLoadingStatusWidget()),
    //Lifecycle
    Page("Lifecycle", (context) => buildLifecyclePageWidget())
  ];
}

class FlutterBasicWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Flutter Basic",
      home: buildListBody("Flutter Basic", context, _buildRoutes()),
    );
  }
}
