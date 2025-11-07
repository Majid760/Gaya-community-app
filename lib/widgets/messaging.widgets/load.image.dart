import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/message.controller.dart';
import '../../utils/const.dart';

class LoadImage extends StatelessWidget {
  const LoadImage({super.key});

  @override
  Widget build(BuildContext context) {
     
    final controller = Provider.of<MessageController>(context, listen: false);

    return (controller.messageImage != null && controller.percentage != null)
        ? Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 150, maxHeight: 150),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius_8),
                        child: Image(
                          image: FileImage(controller.messageImage!),
                          fit: BoxFit.cover,
                        )),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: Center(
                          child: CircularProgressIndicator(
                        color: kprimaryColor,
                        value: controller.percentage,
                      )),
                    ),
                  )
                ],
              ),
            ),
          )
        : const SizedBox();
  }

  }
