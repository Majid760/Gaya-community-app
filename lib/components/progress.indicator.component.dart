import 'package:flutter/material.dart';

import '../utils/const.dart';

class PrimaryCircularProgressIndicator extends StatelessWidget {
  final bool centered;

  const PrimaryCircularProgressIndicator.centered({Key? key})
      : centered = true,
        super(key: key);

  const PrimaryCircularProgressIndicator({Key? key})
      :centered = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (centered) {
      return const Center(child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(kprimaryColor)
      ));
    }
    return const CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(kprimaryColor)
    );
  }
}
  progressIndicator({
    required Color? color,
    VoidCallback ? ontap,
  }) {
  return Expanded(

        child: GestureDetector(
          onTap: ontap,
          child: Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius_4),
              color: color,
            ),
          ),
        ),
      );
  }
