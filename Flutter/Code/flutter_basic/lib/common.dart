import 'package:flutter/material.dart';

class Page {
  String name;
  WidgetBuilder builder;

  Page(this.name, this.builder);
}

buildListBody(String title, BuildContext context, List<Page> pages) {
  return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return RaisedButton(
              child: Text(pages[index].name, style: TextStyle(fontSize: 10)),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: pages[index].builder));
                print(
                    "clicked-----------------------------------${pages[index].builder}");
              });
        },
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      ));
}
