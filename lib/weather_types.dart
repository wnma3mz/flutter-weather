// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

enum WeatherMode { optimistic, pessimistic }
enum BackupMode { enabled, disabled }

class WeatherConfiguration {
  WeatherConfiguration({
    @required this.weatherMode,
    @required this.backupMode,
    @required this.debugShowGrid,
    @required this.debugShowSizes,
    @required this.debugShowBaselines,
    @required this.debugShowLayers,
    @required this.debugShowPointers,
    @required this.debugShowRainbow,
    @required this.showPerformanceOverlay,
    @required this.showSemanticsDebugger
  }) : assert(weatherMode != null),
       assert(backupMode != null),
       assert(debugShowGrid != null),
       assert(debugShowSizes != null),
       assert(debugShowBaselines != null),
       assert(debugShowLayers != null),
       assert(debugShowPointers != null),
       assert(debugShowRainbow != null),
       assert(showPerformanceOverlay != null),
       assert(showSemanticsDebugger != null);

  final WeatherMode weatherMode;
  final BackupMode backupMode;
  final bool debugShowGrid;
  final bool debugShowSizes;
  final bool debugShowBaselines;
  final bool debugShowLayers;
  final bool debugShowPointers;
  final bool debugShowRainbow;
  final bool showPerformanceOverlay;
  final bool showSemanticsDebugger;

  WeatherConfiguration copyWith({
    WeatherMode weatherMode,
    BackupMode backupMode,
    bool debugShowGrid,
    bool debugShowSizes,
    bool debugShowBaselines,
    bool debugShowLayers,
    bool debugShowPointers,
    bool debugShowRainbow,
    bool showPerformanceOverlay,
    bool showSemanticsDebugger
  }) {
    return WeatherConfiguration(
      weatherMode: weatherMode ?? this.weatherMode,
      backupMode: backupMode ?? this.backupMode,
      debugShowGrid: debugShowGrid ?? this.debugShowGrid,
      debugShowSizes: debugShowSizes ?? this.debugShowSizes,
      debugShowBaselines: debugShowBaselines ?? this.debugShowBaselines,
      debugShowLayers: debugShowLayers ?? this.debugShowLayers,
      debugShowPointers: debugShowPointers ?? this.debugShowPointers,
      debugShowRainbow: debugShowRainbow ?? this.debugShowRainbow,
      showPerformanceOverlay: showPerformanceOverlay ?? this.showPerformanceOverlay,
      showSemanticsDebugger: showSemanticsDebugger ?? this.showSemanticsDebugger
    );
  }
}
