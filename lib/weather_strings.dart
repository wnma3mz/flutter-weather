// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

import 'i18n/stock_messages_all.dart';

// Information about how this file relates to i18n/stock_messages_all.dart and how the i18n files
// were generated can be found in i18n/regenerate.md.

class WeatherStrings {
  WeatherStrings(Locale locale) : _localeName = locale.toString();

  final String _localeName;

  static Future<WeatherStrings> load(Locale locale) {
    return initializeMessages(locale.toString())
      .then<WeatherStrings>((Object _) {
        return WeatherStrings(locale);
      });
  }

  static WeatherStrings of(BuildContext context) {
    return Localizations.of<WeatherStrings>(context, WeatherStrings);
  }

  String title() {
    return Intl.message(
      'Weather',
      name: 'title-Weather',
      desc: 'Title for the Weathers application',
      locale: _localeName,
    );
  }

  String market() => Intl.message(
    'CITYS',
    name: 'citys',
    desc: 'Label for the citys tab',
    locale: _localeName,
  );

  String portfolio() => Intl.message(
    'NOTES',
    name: 'notes',
    desc: 'Label for the notes tab',
    locale: _localeName,
  );
}
