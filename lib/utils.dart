import 'dart:math';

import 'package:flutter/material.dart';

num degToRad(num deg) => deg * (pi / 180.0);
num radToDeg(num rad) => rad * (180.0 / pi);

/// 通过角度半径,计算其画布中的位置
Offset getOffset(radius, deg) {
  double x = sin(degToRad(deg)) * radius;
  double y = radius - cos(degToRad(deg));

  return Offset(x, y);
}

