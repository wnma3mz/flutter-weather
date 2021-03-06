// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library weathers;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show
  debugPaintSizeEnabled,
  debugPaintBaselinesEnabled,
  debugPaintLayerBordersEnabled,
  debugPaintPointersEnabled,
  debugRepaintRainbowEnabled;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'weather_data.dart';
import 'weather_home.dart';
import 'weather_settings.dart';
import 'weather_strings.dart';
import 'weather_symbol_viewer.dart';
import 'weather_types.dart';

class _WeathersLocalizationsDelegate extends LocalizationsDelegate<WeatherStrings> {
  @override
  Future<WeatherStrings> load(Locale locale) => WeatherStrings.load(locale);

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'es' || locale.languageCode == 'en';

  @override
  bool shouldReload(_WeathersLocalizationsDelegate old) => false;
}

class WeathersApp extends StatefulWidget {
  @override
  WeathersAppState createState() => WeathersAppState();
}

class WeathersAppState extends State<WeathersApp> {
  WeatherData weathers;

  WeatherConfiguration _configuration = WeatherConfiguration(
    weatherMode: WeatherMode.optimistic,
    backupMode: BackupMode.enabled,
    debugShowGrid: false,
    debugShowSizes: false,
    debugShowBaselines: false,
    debugShowLayers: false,
    debugShowPointers: false,
    debugShowRainbow: false,
    showPerformanceOverlay: false,
    showSemanticsDebugger: false
  );

  @override
  void initState() {
    super.initState();
//    var cityids = ['101050201'];
    List<String> cityids;
    weathers = WeatherData(cityids);
  }

  void configurationUpdater(WeatherConfiguration value) {
    setState(() {
      _configuration = value;
    });
  }

  ThemeData get theme {
    switch (_configuration.weatherMode) {
      case WeatherMode.optimistic:
        return ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.purple
        );
      case WeatherMode.pessimistic:
        return ThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.redAccent
        );
    }
    assert(_configuration.weatherMode != null);
    return null;
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    // Routes, by convention, are split on slashes, like filesystem paths.
//    print(settings);
    final List<String> path = settings.name.split('/');
    // We only support paths that start with a slash, so bail if
    // the first component is not empty:
    if (path[0] != '')
      return null;
    // If the path is "/stock:..." then show a stock page for the
    // specified stock symbol.
    if (path[1].startsWith('stock:')) {
      // We don't yet support subpages of a stock, so bail if there's
      // any more path components.
      if (path.length != 2)
        return null;
      // Extract the symbol part of "stock:..." and return a route
      // for that symbol.
      final String symbol = path[1].substring(6);
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => WeatherSymbolPage(symbol: symbol, weathers: weathers),
      );
    }
    // The other paths we support are in the routes table.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPaintSizeEnabled = _configuration.debugShowSizes;
      debugPaintBaselinesEnabled = _configuration.debugShowBaselines;
      debugPaintLayerBordersEnabled = _configuration.debugShowLayers;
      debugPaintPointersEnabled = _configuration.debugShowPointers;
      debugRepaintRainbowEnabled = _configuration.debugShowRainbow;
      return true;
    }());
    return MaterialApp(
      title: 'Weather-Test',
      theme: theme,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        _WeathersLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      // 去除右上角的Debug
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: _configuration.debugShowGrid,
      showPerformanceOverlay: _configuration.showPerformanceOverlay,
      showSemanticsDebugger: _configuration.showSemanticsDebugger,
      routes: <String, WidgetBuilder>{
         '/':         (BuildContext context) => WeatherHome(weathers, _configuration, configurationUpdater),
         '/settings': (BuildContext context) => WeatherSettings(_configuration, configurationUpdater)
      },
      onGenerateRoute: _getRoute,
    );
  }
}

void main() {
  runApp(WeathersApp());
}
