import 'package:flutter/material.dart';

class DotWidget extends StatelessWidget {
  final Color color;
  final double size;

  const DotWidget({Key? key, required this.color, this.size = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: size, backgroundColor: color);
  }
}
