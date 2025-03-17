import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cola_weather/model/weather_info.dart';
import 'package:cola_weather/page_home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cities extends StatefulWidget {
  const Cities({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CitiesState();
  }
}

class CitiesState extends State<Cities> {
  static String idSelected = "";
  late Map<String, WeatherInfo> cityMap;
  int count = 0;
  final searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    cityMap = <String, WeatherInfo>{};

    _getCitiesId().then((list) {
      for (String id in list) {
        _fetchWeatherInfo(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: FloatingActionButton.extended(
          tooltip: 'Show textfield',
          icon: const Icon(Icons.add),
          label: const Text("城市"),
          onPressed: _showCityTextField,
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 2.0,
          backgroundColor: Colors.white,
          title: const Text("城市", style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          child: Center(
            child: ListView(children: _buildCitiesWeather(cityMap)),
          ),
        ),
      ),
    );
  }

  void _showCityTextField() {
    _scaffoldKey.currentState!.showBottomSheet((BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (String name) {
              searchController.clear();
              Navigator.pop(context);
              _setCitiesId(HomePageState.getIdByName(name)).then((_) {
                _refreshIndicatorKey.currentState?.show();
              });
            },
            maxLines: 1,
            style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            //输入文本的样式
            decoration: const InputDecoration(
              hintText: '查询其他城市',
              hintStyle: TextStyle(fontSize: 14.0, color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.0),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _handleRefresh() async {
    print("_handleRefresh");

    _getCitiesId().then((list) {
      for (String id in list) {
        _fetchWeatherInfo(id);
      }
    });

    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 1), () {
      completer.complete(null);
    });
    return completer.future.then((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('刷新成功')));
    });
  }

  Future<List<String>> _getCitiesId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ids = prefs.getStringList("citiesids");
    if (kDebugMode) {
      print("_getCitiesId ======" + ids.toString());
    }
    if (ids != null && ids.isNotEmpty) {
      count = ids.length;
      return ids;
    }
    return [];
  }

  _fetchWeatherInfo(String id) async {
    var httpClient = HttpClient();
    var uri = Uri.http('aider.meizu.com', '/app/weather/listWeather', {
      'cityIds': id,
    });
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    try {
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(const Utf8Decoder()).join();
        Map map = jsonDecode(json);
        print(map["value"][0].toString());
        cityMap[id] = WeatherInfo.fromJson(map["value"][0]);
        if (cityMap.length == count) {
          setState(() {
            cityMap;
          });
        }
      } else {
        print("============data is empty==============");
      }
    } catch (exception) {
      print("=============" + exception.toString() + "===============");
    }
  }

  Future<void> _setCitiesId(String id) async {
    print("id ： " + id);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> ids = prefs.getStringList("citiesids") ?? [];

    if (!ids.contains(id)) {
      ids.add(id);
    }
    print("ids ： " + ids.toString());

    await prefs.setStringList("citiesids", ids);
  }

  List<Widget> _buildCitiesWeather(Map<String, WeatherInfo> maps) {
    print("_buildCitiesWeather============" + maps.values.length.toString());
    List<Widget> list = [];
    for (WeatherInfo weatherInfo in maps.values) {
      list.add(_buildCityWeatherItem(weatherInfo));
    }
    return list;
  }

  Widget _buildCityWeatherItem(WeatherInfo weatherInfo) {
    String image = "images/bg_dy.png";
    String weather = weatherInfo.realtime.weather;
    if (weather.contains("多云")) {
      image = "images/bg_dy.png";
    } else if (weather.contains("晴")) {
      image = "images/sun.png";
    } else if (weather.contains("阴")) {
      image = "images/cloudy.png";
    } else if (weather.contains("雨")) {
      image = "images/rain.png";
    } else if (weather.contains("雷")) {
      image = "images/lightning.png";
    }
    if (kDebugMode) {
      print("_buildCityWeatherItem============ " + weatherInfo.city);
    }

    return InkWell(
      onTap: () {
        idSelected = weatherInfo.cityid.toString();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        height: 200.0,
        alignment: Alignment.center,
        child: Card(
          child: Stack(
            children: <Widget>[
              SizedBox(
                child: Image.asset(image, fit: BoxFit.fill),
                height: 200.0,
                width: double.infinity,
              ),
              Container(
                decoration: const BoxDecoration(color: Color(0x33000000)),
                child: Container(
                  padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      Text(
                        weatherInfo.city,
                        style: const TextStyle(fontSize: 22.0),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10.0)),
                      Text(
                        weatherInfo.realtime.weather,
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10.0)),
                      Text(
                        weatherInfo.realtime.temp + "℃",
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
