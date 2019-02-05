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

class Stock {
  Stock(this.symbol, this.name, this.lastSale, this.marketCap,
      this.percentChange);

  Stock.fromFields(Map<String, dynamic> data, Map<String, dynamic> realtime) {
    // FIXME: This class should only have static data, not lastSale, etc.
    // "Symbol","Name","LastSale","MarketCap","IPOyear","Sector","industry","Summary Quote",

    lastSale = realtime['weather'];
    symbol = data['city'];
    name = data['provinceName'];
    marketCap = realtime['time'];
    percentChange = realtime['wD'] + realtime['wS'];

//    print(lastSale);
//    print(symbol);
//    print(name);
//    print(marketCap);
//    print(percentChange);
  }

  String symbol;
  String name;
  String lastSale;
  String marketCap;
  String percentChange;
}

class StockData extends ChangeNotifier {
  StockData() {
    if (actuallyFetchData) {
      _httpClient = http.Client();
      _fetchNextChunk();
    }
  }

  final List<String> _symbols = <String>[];
  final Map<String, Stock> _stocks = <String, Stock>{};

  Iterable<String> get allSymbols => _symbols;

  Stock operator [](String symbol) => _stocks[symbol];

  bool get loading => _httpClient != null;

  void add(Map<String, dynamic> data) {
    final Stock stock = Stock.fromFields(data, data['realtime']);
    _symbols.add(stock.symbol);
    _stocks[stock.symbol] = stock;

    _symbols.sort();
    notifyListeners();
  }

  static const int _chunkCount = 101240110;
  int _nextChunk = 101240101;

  String _urlToFetch(int chunk) {
    return 'http://aider.meizu.com/app/weather/listWeather?cityIds=$chunk';
  }

  http.Client _httpClient;

  static bool actuallyFetchData = true;

  void _fetchNextChunk() {
    _httpClient
        .get(_urlToFetch(_nextChunk++))
        .then<void>((http.Response response) {
      final String json = response.body;
      const JsonDecoder decoder = JsonDecoder();
      final _data = decoder.convert(json)["value"][0];
      add(_data);
      if (_nextChunk < _chunkCount) {
        _fetchNextChunk();
      } else {
        _end();
      }
    });
//    _httpClient.get(_urlToFetch(_nextChunk++)).then<void>((http.Response response) {
//      final String json = response.body;
//      if (json == null) {
//        debugPrint('Failed to load stock data chunk ${_nextChunk - 1}');
//        _end();
//        return;
//      }
//      const JsonDecoder decoder = JsonDecoder();
//      add(decoder.convert(json));
//      if (_nextChunk < _chunkCount) {
//        _fetchNextChunk();
//      } else {
//        _end();
//      }
//    });
  }

  void _end() {
    _httpClient?.close();
    _httpClient = null;
  }
}
