import 'package:flutter/material.dart';

//入门
import 'package:flutter_basic/getting-started/00_hello_world.dart';
import 'package:flutter_basic/getting-started/01_basic_widget.dart';
import 'package:flutter_basic/getting-started/02_material_widget.dart';
import 'package:flutter_basic/getting-started/03_process_gesture.dart';
import 'package:flutter_basic/getting-started/04_stateful_widget.dart';
import 'package:flutter_basic/getting-started/05_shopping_cart.dart';
import 'package:flutter_basic/getting-started/06_inherited_widget.dart';

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
import 'package:flutter_basic/animation/01_tween_zoomin_logo.dart';
import 'package:flutter_basic/animation/02_curve_animation.dart';
import 'package:flutter_basic/animation/03_animated_widget.dart';
import 'package:flutter_basic/animation/04_animation_builder.dart';
import 'package:flutter_basic/animation/05_hero_animation.dart';

//自定义View
import 'package:flutter_basic/custom-view/draw-cake.dart';

//导航
import 'package:flutter_basic/navigator/01_base-router.dart';
import 'package:flutter_basic/navigator/02_base-roter-pass.dart';
import 'package:flutter_basic/navigator/03_base-router-return.dart';
import 'package:flutter_basic/navigator/04-named-router.dart';

//传递数据
import 'package:flutter_basic/passing-value/01-passing-value-by-inherrited.dart';
import 'package:flutter_basic/passing-value/02-passing-value-by-notification.dart';
import 'package:flutter_basic/passing-value/03-passing-value-by-eventbus.dart';

//网络
import 'package:flutter_basic/network/01_httpclient.dart';
import 'package:flutter_basic/network/02_http_sample1.dart';
import 'package:flutter_basic/network/02_http_sample2.dart';
import 'package:flutter_basic/network/03-dio.dart';
import 'package:flutter_basic/network/04-json-convert.dart';
import 'package:flutter_basic/network/07_web_socket.dart';

//生命周期
import 'package:flutter_basic/lifecycle/LifecyclePage.dart';

//基础库
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
    Page("TweenAnimation", (context) => buildTweenAnimationWidget()),
    Page("CurveAnimate", (context) => buildCurveAnimateWidget()),
    Page("AnimatedWidget", (context) => buildAnimatedWidgetDemo()),
    Page("Animated Builder", (context) => buildAnimationBuilderWidget()),
    Page("HeroAnimation", (context) => buildHeroAnimation()),

    //Custom View
    Page("CakeView", (context) => buildCustomCakeView()),

    //Lifecycle
    Page("Lifecycle", (context) => buildLifecyclePageWidget()),

    //basic navigator
    Page("BaseRouter", (context) => buildBaseRouterWidget()),
    Page("BaseRouter PassValue", (context) => buildBaseRouterPassWidget()),
    Page("BaseRouter ReturnValue", (context) => buildBaseRouterGetWidget()),
    Page("NamedRouter", (context) => buildNamedRouterWidget()),

    //passing value
    Page("PassValue-Inherited", (context) => buildPassValueByInheritedWidget()),
    Page("PassValue-Notification", (context) => buildPassValueByNotification()),
    Page("PassValue-EventBus", (context) => buildPassValueByEventBus()),

    //net work
    Page("HttpClient", (context) => buildHttpClientWidget()),
    Page("Http Sampe1", (context) => buildHttpSample1Widget()),
    Page("Http Sampe2", (context) => buildHttpSample2Widget()),
    Page("Dio Sampe", (context) => buildDioDemoWidget()),
    Page("Json Parse", (context) => buildJsonParsingDemo()),
  ];
}

class FlutterBasicWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Flutter 基础示例",
      home: buildListBody("Flutter 基础示例", context, _buildRoutes()),
    );
  }
}
