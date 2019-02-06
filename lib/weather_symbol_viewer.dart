// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'weather_arrow.dart';
import 'weather_data.dart';

class _WeatherSymbolView extends StatelessWidget {
  const _WeatherSymbolView({ this.weather, this.arrow });

  final Weather weather;
  final Widget arrow;

  @override
  Widget build(BuildContext context) {
    assert(weather != null);
    final String lastSale = weather.weathers;
    String changeInPrice = weather.wDwS;

    final TextStyle headings = Theme.of(context).textTheme.caption;
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '${weather.city}',
                style: Theme.of(context).textTheme.title
              ),
//              arrow,
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          Text('天气情况', style: headings),
          Text('$lastSale ($changeInPrice)'),
          Container(
            height: 8.0
          ),
          Text('时间', style: headings),
          Text('${weather.time}'),
          Container(
            height: 8.0
          ),
        ],
        mainAxisSize: MainAxisSize.min
      )
    );
  }
}

class WeatherSymbolPage extends StatelessWidget {
  const WeatherSymbolPage({ this.symbol, this.weathers });

  final String symbol;
  final WeatherData weathers;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: weathers,
      builder: (BuildContext context, Widget child) {
        final Weather weather = weathers[symbol];
        return Scaffold(
          appBar: AppBar(
            title: Text(weather?.provinceName ?? symbol)
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: Card(
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  secondChild: weather != null
                    ? _WeatherSymbolView(
                      weather: weather,
                      arrow: Hero(
                        tag: weather,
                        child: WeatherArrow(wDwS: weather.wDwS),
                      ),
                    ) : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(child: Text('$symbol not found')),
                    ),
                  crossFadeState: weather == null && weathers.loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                ),
              )
            )
          )
        );
      },
    );
  }
}

class WeatherSymbolBottomSheet extends StatelessWidget {
  const WeatherSymbolBottomSheet({ this.weather });

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black26))
      ),
      child: _WeatherSymbolView(
        weather: weather,
        arrow: WeatherArrow(wDwS: weather.wDwS)
      )
   );
  }
}
