import 'package:flutter/cupertino.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:get/get.dart';

class GayaBackButton extends StatelessWidget {
  final VoidCallback? onPop;
  final bool? isLight;

  const GayaBackButton({Key? key, this.onPop, this.isLight = false}) : super(key: key);

  const GayaBackButton.light({Key? key, this.onPop})
      : isLight = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => (onPop != null) ? onPop!() : Get.back(),
      child: SvgIconWidget.leftArrowIcon(isLight: isLight ?? false),
    );
  }
}
