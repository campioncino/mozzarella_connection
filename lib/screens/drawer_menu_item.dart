import 'package:bufalabuona/screens/drawer_item.dart';
import 'package:flutter/material.dart';

class DrawerMenuItem extends DrawerItem {
  String title;
  String? subtitle;
  Icon icon;
  int? id;

  DrawerMenuItem(
      this.id,
      this.title,
      this.icon,
      {this.subtitle}):super();


}