import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/create.post.controller.dart';

class PickedDocumentFile extends StatelessWidget {
  final CreatePostController controller;
  const PickedDocumentFile({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostController>(builder: (_, postController, __) {
      return const SizedBox(
        height: 270,
        child: Center(child: Text('Documet picked')),
      );
    });
  }
}
