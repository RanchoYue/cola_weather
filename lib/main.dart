import 'package:cola/page_cities.dart';
import 'package:cola/page_home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => HomePage(CitiesState.idSelected),
      },
      home: HomePage("101270101"),
    );
  }
}
