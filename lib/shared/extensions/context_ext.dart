import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  EdgeInsets get viewPadding => MediaQuery.of(this).padding;

  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}
