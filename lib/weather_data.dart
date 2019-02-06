// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Snapshot from http://www.nasdaq.com/screening/company-list.aspx
// Fetched 2/23/2014.
// "Symbol","Name","LastSale","MarketCap","IPOyear","Sector","industry","Summary Quote",
// Data in stock_data.json

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Weather {
  Weather(this.city, this.provinceName, this.weathers, this.time, this.wDwS);

  Weather.fromFields(Map<String, dynamic> data, Map<String, dynamic> realtime) {
    weathers = realtime['weather'];
    city = data['city'];
    provinceName = data['provinceName'];
    time = realtime['time'];
    wDwS = realtime['wD'] + realtime['wS'];
  }

  String city;
  String provinceName;
  String weathers;
  String time;
  String wDwS;
}

class WeatherData extends ChangeNotifier {

  WeatherData(List<String> cityids) {
    if (actuallyFetchData) {
      _httpClient = http.Client();
      if (cityids == null)
        cityids = ['101010100', '101020100', '101030100', '101280101', '101280601'];
      else
        // 列表相加，不确定能不能这么写。。。
        cityids.addAll(cityids);
      _fetchNextChunk(cityids);
    }
  }

  final List<String> _symbols = <String>[];
  final Map<String, Weather> _weathers = <String, Weather>{};

  Iterable<String> get allSymbols => _symbols;

  Weather operator [](String symbol) => _weathers[symbol];

  bool get loading => _httpClient != null;

  void add(Map<String, dynamic> data) {
    final Weather weather = Weather.fromFields(data, data['realtime']);
    _symbols.add(weather.city);
    _weathers[weather.city] = weather;
    _symbols.sort();
    notifyListeners();
  }

  String _urlToFetch(var _cityids) {
    var url = 'http://aider.meizu.com/app/weather/listWeather?';
    for (var _ids in _cityids) {
      url += 'cityIds=' + _ids + '&';
    }
    return url;
  }

  http.Client _httpClient;

  static bool actuallyFetchData = true;

  void _fetchNextChunk(var cityids) {
    _httpClient.get(_urlToFetch(cityids)).then<void>((http.Response response) {
      final String json = response.body;
      const JsonDecoder decoder = JsonDecoder();
      final _data = decoder.convert(json)["value"];
      for (var _d in _data) {
        add(_d);
      }
    });

    _end();

  }

  void _end() {
    _httpClient?.close();
    _httpClient = null;
  }
}
