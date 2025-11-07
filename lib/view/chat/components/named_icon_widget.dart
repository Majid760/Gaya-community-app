import 'package:flutter/material.dart';

class NamedIconWidget {
  final String assetPath;
  final String nameOfIcon;
  Function(BuildContext buildContext) onPressed;

  NamedIconWidget({required this.onPressed, required this.assetPath, required this.nameOfIcon});
}
