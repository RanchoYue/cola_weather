import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:cola_weather/model/weather_info.dart';
import 'package:cola_weather/page_cities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  double screenWidth = 0.0;
  File _image = File("null");

  final AMapFlutterLocation _amapLocation = AMapFlutterLocation();
  static List citiesMap = [];

  HomePageState();

  WeatherInfo weatherInfo = WeatherInfo(
    realtime: Realtime(wS: '', temp: '', wD: '', weather: '', time: ''),
    pm25: PM25(aqi: '', quality: ''),
    indexes: [],
    weathers: [],
    city: '',
    cityid: 1,
  );

  Future getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      String? path = "";
      if (image?.path != null) {
        path = image?.path;
      }
      _image = File(path!);
      _setImagePath(_image.path);
    });
  }

  @override
  void initState() {
    super.initState();
    startLocation();
    _getImagePath();
    _getCityId();
    _loadCities();
  }

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final theme = Theme.of(context);
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            SizedBox(
              child:
                  _image.path == "null"
                      ? Image.asset("images/bg.jpg", fit: BoxFit.fill)
                      : Image.file(_image, fit: BoxFit.fill),
              width: double.infinity,
              height: double.infinity,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.only(top: 30.0),
                decoration: const BoxDecoration(color: Color(0x66000000)),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        child: const Icon(Icons.list, color: Colors.white),
                        onTap: () {
                          Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return const Cities();
                              },
                            ),
                          );
                        },
                      ),
                      padding: const EdgeInsets.only(top: 5.0, right: 20.0),
                      alignment: Alignment.centerRight,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Theme(
                        data: theme.copyWith(primaryColor: Colors.white),
                        child: TextField(
                          controller: searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (String _) {
                            _fetchWeatherInfo(getIdByName(""));
                          },
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                          //输入文本的样式
                          decoration: const InputDecoration(
                            hintText: '查询其他城市',
                            hintStyle: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        weatherInfo.city,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        weatherInfo.realtime.time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        (weatherInfo.realtime.temp) + "℃",
                        style: const TextStyle(
                          fontSize: 80.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        weatherInfo.realtime.weather,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        (weatherInfo.realtime.wD) +
                            " " +
                            (weatherInfo.realtime.wS),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey,
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 5.0,
                            right: 5.0,
                            top: 2.0,
                            bottom: 2.0,
                          ),
                          child: Text(
                            (weatherInfo.pm25.aqi) +
                                " " +
                                (weatherInfo.pm25.quality),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      color: const Color(0x3399CCFF),
                      child: Row(
                        children: _buildFutureWeathers(weatherInfo.weathers),
                      ),
                    ),
                    Column(children: _buildLivingIndexes(weatherInfo.indexes)),
                    const Padding(padding: EdgeInsets.only(top: 20.0)),
                    InkWell(
                      onTap: () {
                        getImage();
                      },
                      child: const Text(
                        "自定义背景",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 20.0)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFutureWeathers(List<Weather> weathers) {
    List<Widget> widgets = [];
    if (weathers.isNotEmpty) {
      int index = 0;

      for (Weather weather in weathers) {
        widgets.add(
          _buildFutureWeather(
            index == 0 ? "今天" : weather.week,
            weather.weather,
            weather.temp_day_c + " ~ " + weather.temp_night_c,
          ),
        );
        index++;
        if (index == 5) {
          break;
        }
      }
    }
    return widgets;
  }

  Widget _buildFutureWeather(String week, String weather, String temp) {
    return Expanded(
      flex: 1,
      child: Column(
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          Text(week, style: const TextStyle(color: Colors.white)),
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          Text(temp + "℃", style: const TextStyle(color: Colors.white)),
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          Text(weather, style: const TextStyle(color: Colors.white)),
          const Padding(padding: EdgeInsets.only(top: 10.0)),
        ],
      ),
    );
  }

  List<Widget> _buildLivingIndexes(List<Index> indexes) {
    List<Widget> widgets = [];
    if (indexes.isNotEmpty) {
      for (Index index in indexes) {
        widgets.add(_buildLivingIndex(index));
      }
    }
    return widgets;
  }

  Widget _buildLivingIndex(Index index) {
    return Container(
      color: const Color(0x3399CCFF),
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
        bottom: 10.0,
      ),
      child: Row(
        children: <Widget>[
          Image.asset(
            "images/" + index.abbreviation + ".png",
            width: 40.0,
            fit: BoxFit.fitWidth,
          ),
          const Padding(padding: EdgeInsets.only(right: 10.0)),
          Column(
            children: <Widget>[
              SizedBox(
                child: Text(
                  index.name + " " + index.level,
                  style: const TextStyle(color: Colors.white),
                ),
                width: 280.0,
              ),
              const Padding(padding: EdgeInsets.only(top: 10.0)),
              SizedBox(
                child: Text(
                  index.content,
                  style: const TextStyle(color: Colors.white, fontSize: 12.0),
                ),
                width: 280.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> _loadCitiesAsset() async {
    return await rootBundle.loadString('data/cities.json');
  }

  Future _loadCities() async {
    String jsonString = await _loadCitiesAsset();
    citiesMap = json.decode(jsonString)['cities'];
  }

  _setImagePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("bg_path", path);
  }

  _getImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String path = prefs.get("bg_path").toString();
    setState(() {
      _image = File(path);
    });
  }

  _setCityId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("city_id", id);
  }

  _getCityId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cityId = prefs.get("city_id").toString();
    if (cityId == "null") {
      _fetchWeatherInfo("101270101");
    } else {
      _fetchWeatherInfo(cityId);
    }
  }

  Future<void> startLocation() async {
    _amapLocation.startLocation;
  }

  Future<void> stopLocation() async {
    _amapLocation.stopLocation;
  }

  static String getIdByName(String name) {
    if (citiesMap.isNotEmpty) {
      for (Map map in citiesMap) {
        if (map['city'] == name) {
          return map['cityid'];
        }
      }
    }
    return "101270101";
  }

  @override
  void dispose() {
    super.dispose();
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
        _setCityId(id);
        var json = await response.transform(const Utf8Decoder()).join();
        Map map = jsonDecode(json);
        if (kDebugMode) {
          print(map["value"][0].toString());
        }
        setState(() {
          weatherInfo = WeatherInfo.fromJson(map["value"][0]);
        });
        if (kDebugMode) {
          print(weatherInfo.city);
        }
      } else {
        if (kDebugMode) {
          print("============data is empty==============");
        }
      }
    } catch (exception) {
      if (kDebugMode) {
        print("=============" + exception.toString() + "===============");
      }
    }
  }

  Future<String> getLocation() async {
    String location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      location = "北京";
      Map<String, dynamic> jsonMap = json.decode(location);
      String city = jsonMap['city'];
      if (kDebugMode) {
        print("getLocation----------" + city);
      }
      return city;
    } on PlatformException {
      return 'Failed to get location.';
    }
  }
}
