import 'package:flutter/material.dart';

var theme = ThemeData(
  bottomNavigationBarTheme:
      BottomNavigationBarThemeData(selectedItemColor: Colors.black),
  iconTheme: IconThemeData(color: Colors.black),
  appBarTheme: AppBarTheme(
      color: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 25),
      actionsIconTheme: IconThemeData(color: Colors.black)),
  textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black)),
);
