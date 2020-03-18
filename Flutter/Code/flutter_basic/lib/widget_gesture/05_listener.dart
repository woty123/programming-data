import 'package:flutter/material.dart';

Widget buildTouchEventListenerWidget() => TouchEventListenerWidget();

class TouchEventListenerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        print("down $event");
      },
      onPointerMove: (event) {
        print("move $event");
      },
      onPointerUp: (event) {
        print("up $event");
      },
      onPointerCancel: (event) {
        print("cancel $event");
      },
      child: Container(
        color: Colors.red,
        width: 300,
        height: 300,
      ),
    );
  }
}
