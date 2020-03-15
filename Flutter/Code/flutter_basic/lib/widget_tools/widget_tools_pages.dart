import 'package:flutter/material.dart';
import 'package:flutter_basic/common.dart';
import 'package:flutter_basic/widget_tools/understand_provider.dart';

import 'inherited_widget.dart';
import 'will_pop_scope_widget.dart';

List<Page> _buildRoutes() {
  return [
    Page("WillPopScope", (context) => buildWillPopScopeWidgetSample()),
    Page("Inherited", (context) => buildInheritedWidget()),
    Page("Understad Provider", (context) => buildProviderUnderstandingWidget()),
  ];
}

Widget buildToolsPagesWidget(BuildContext context) =>
    buildListBody("Tools", context, _buildRoutes());