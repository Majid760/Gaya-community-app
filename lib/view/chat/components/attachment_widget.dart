import 'package:flutter/material.dart';

void showAttachments({required BuildContext context, required Offset offset, required List<PopupMenuItem<String>>? items}) async {
  double left = offset.dx;
  double top = offset.dy;

  await showMenu(
    context: context,
    position: RelativeRect.fromLTRB(left, top + 10, 0, 200),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(12),
      ),
    ),
    items: items!,
    elevation: 8.0,
  );
}
