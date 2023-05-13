import 'package:bufalabuona/screens/drawer_item.dart';
import 'package:flutter/material.dart';

class DrawerMenuDivider extends DrawerItem {
  int? id;
  String title;
  String? subtitle;
  Color? color;

  DrawerMenuDivider(id,this.title,
      this.color,
      {this.subtitle}
      ) : super();

}