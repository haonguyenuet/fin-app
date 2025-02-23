import 'package:flutter/material.dart';

extension GlobalKeyExt on GlobalKey {
  double get height {
    final renderBox = currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    return size.height;
  }
}