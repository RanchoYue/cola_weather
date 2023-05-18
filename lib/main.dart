import 'package:cola_weather/page_cities.dart';
import 'package:cola_weather/page_home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => HomePage(),
      },
      home: HomePage(),
    );
  }
}
