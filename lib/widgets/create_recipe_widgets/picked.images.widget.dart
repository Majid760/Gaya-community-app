
import 'package:flutter/material.dart';

import '../../controller/create.post.controller.dart';
import '../../utils/const.dart';

class PickedImagesWidget extends StatelessWidget {
  final CreatePostController controller;
  const PickedImagesWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: controller.images
            .map((e) => ClipRRect(
                  borderRadius: BorderRadius.circular(distance_5),
                  child: Image.file(
                    e,
                    height: 152,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ))
            .toList());
  }
}
