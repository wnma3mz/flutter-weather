// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'weather_data.dart';
import 'weather_row.dart';

class WeatherList extends StatelessWidget {
  const WeatherList({ Key key, this.weathers, this.onOpen, this.onShow, this.onAction }) : super(key: key);

  final List<Weather> weathers;
  final WeatherRowActionCallback onOpen;
  final WeatherRowActionCallback onShow;
  final WeatherRowActionCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const ValueKey<String>('stock-list'),
      itemExtent: WeatherRow.kHeight,
      itemCount: weathers.length,
      itemBuilder: (BuildContext context, int index) {
        return WeatherRow(
          weather: weathers[index],
          onPressed: onOpen,
          onDoubleTap: onShow,
          onLongPressed: onAction
        );
      },
    );
  }
}
