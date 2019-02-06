// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'weather_arrow.dart';
import 'weather_data.dart';

typedef WeatherRowActionCallback = void Function(Weather weather);

class WeatherRow extends StatelessWidget {
  WeatherRow(
      {this.weather, this.onPressed, this.onDoubleTap, this.onLongPressed})
      : super(key: ObjectKey(weather));

  final Weather weather;
  final WeatherRowActionCallback onPressed;
  final WeatherRowActionCallback onDoubleTap;
  final WeatherRowActionCallback onLongPressed;
  final Weathersaved = new List<String>();

  static const double kHeight = 65;

  GestureTapCallback _getHandler(WeatherRowActionCallback callback) {
    return callback == null ? null : () => callback(weather);
  }

  @override
  Widget build(BuildContext context) {
    final String weathers = weather.weathers;
//    final alreadySaved = weather.city.contains(Weathersaved[0]);
    String wDwS = weather.wDwS;

    return InkWell(
        onTap: _getHandler(onPressed),
        onDoubleTap: _getHandler(onDoubleTap),
        onLongPress: _getHandler(onLongPressed),
        child: Container(
            padding: const EdgeInsets.fromLTRB(5.0, 14.0, 30.0, 35.0),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor))),
            child: Row(children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(right: 5.0),
                  child: Hero(
                      tag: weather, child: WeatherArrow(wDwS: weather.wDwS))),
              Expanded(
                  child: Row(
                      children: <Widget>[
                    Expanded(flex: 2, child: Text(weather.city)),
                    Expanded(child: Text(weathers, textAlign: TextAlign.right)),
                    Expanded(child: Text(wDwS, textAlign: TextAlign.right)),
                  ],
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline:
                          DefaultTextStyle.of(context).style.textBaseline)),
            ])));
  }
}
