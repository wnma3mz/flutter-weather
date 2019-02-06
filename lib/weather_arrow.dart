// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class WeatherArrowPainter extends CustomPainter {
  WeatherArrowPainter({this.color, this.percentChange});

  final Color color;
  final String percentChange;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    paint.strokeWidth = 1.0;
    const double padding = 2.0;
    assert(padding >
        paint.strokeWidth / 2.0); // make sure the circle remains inside the box
    final double r =
        (size.shortestSide - padding) / 2.0; // radius of the circle
    final double centerX = padding + r;
    final double centerY = padding + r;

    // Draw the arrow.
    const double w = 8.0;
    double h = 5.0;
    double arrowY;
//    if (percentChange < 0.0) {
//      h = -h;
//      arrowY = centerX + 1.0;
//    } else {
//      arrowY = centerX - 1.0;
//    }
    final Path path = Path();
    path.moveTo(centerX, arrowY - h); // top of the arrow
    path.lineTo(centerX + w, arrowY + h);
    path.lineTo(centerX - w, arrowY + h);
    path.close();
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Draw a circle that circumscribes the arrow.
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerX, centerY), r, paint);
  }

  @override
  bool shouldRepaint(WeatherArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.percentChange != percentChange;
  }
}

class WeatherArrow extends StatelessWidget {
  const WeatherArrow({Key key, this.wDwS}) : super(key: key);

  final String wDwS;

  int _colorIndexForPercentChange(String percentChange) {
//    const double maxPercent = 10.0;
//    final double normalizedPercentChange = math.min(percentChange.abs(), maxPercent) / maxPercent;
//    return 100 + (normalizedPercentChange * 8.0).floor() * 100;
    return 1000;
  }

  Color _colorForPercentChange(String percentChange) {
//    if (percentChange > 0)
//      return Colors.green[_colorIndexForPercentChange(percentChange)];
    return Colors.red[_colorIndexForPercentChange(percentChange)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 10.0,
        height: 50.0,
        margin: const EdgeInsets.symmetric(horizontal: 1.0),
        child: CustomPaint(
            painter: WeatherArrowPainter(
                // TODO(jackson): This should change colors with the theme
                color: _colorForPercentChange(wDwS),
                percentChange: wDwS)));
  }
}
