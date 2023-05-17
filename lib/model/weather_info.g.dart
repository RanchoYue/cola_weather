// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherInfo _$WeatherInfoFromJson(Map<String, dynamic> json) => WeatherInfo(
      city: json['city'] as String,
      cityid: json['cityid'] as int,
      indexes: (json['indexes'] as List<dynamic>)
          .map((e) => Index.fromJson(e as Map<String, dynamic>))
          .toList(),
      pm25: PM25.fromJson(json['pm25'] as Map<String, dynamic>),
      realtime: Realtime.fromJson(json['realtime'] as Map<String, dynamic>),
      weathers: (json['weathers'] as List<dynamic>)
          .map((e) => Weather.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WeatherInfoToJson(WeatherInfo instance) =>
    <String, dynamic>{
      'city': instance.city,
      'cityid': instance.cityid,
      'indexes': instance.indexes,
      'pm25': instance.pm25,
      'realtime': instance.realtime,
      'weathers': instance.weathers,
    };

Index _$IndexFromJson(Map<String, dynamic> json) => Index(
      abbreviation: json['abbreviation'] as String,
      content: json['content'] as String,
      level: json['level'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$IndexToJson(Index instance) => <String, dynamic>{
      'abbreviation': instance.abbreviation,
      'content': instance.content,
      'level': instance.level,
      'name': instance.name,
    };

PM25 _$PM25FromJson(Map<String, dynamic> json) => PM25(
      aqi: json['aqi'] as String,
      quality: json['quality'] as String,
    );

Map<String, dynamic> _$PM25ToJson(PM25 instance) => <String, dynamic>{
      'aqi': instance.aqi,
      'quality': instance.quality,
    };

Realtime _$RealtimeFromJson(Map<String, dynamic> json) => Realtime(
      temp: json['temp'] as String,
      time: json['time'] as String,
      weather: json['weather'] as String,
      wS: json['wS'] as String,
      wD: json['wD'] as String,
    );

Map<String, dynamic> _$RealtimeToJson(Realtime instance) => <String, dynamic>{
      'temp': instance.temp,
      'time': instance.time,
      'weather': instance.weather,
      'wS': instance.wS,
      'wD': instance.wD,
    };

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
      date: json['date'] as String,
      temp_day_c: json['temp_day_c'] as String,
      temp_night_c: json['temp_night_c'] as String,
      weather: json['weather'] as String,
      week: json['week'] as String,
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'date': instance.date,
      'temp_day_c': instance.temp_day_c,
      'temp_night_c': instance.temp_night_c,
      'weather': instance.weather,
      'week': instance.week,
    };
