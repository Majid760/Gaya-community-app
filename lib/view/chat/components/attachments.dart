import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/gen/assets.gen.dart';

class AttachmentsBottomSheet extends StatelessWidget {
  AttachmentsBottomSheet({super.key});
  final List<String> iconData = [
    Assets.assets.icons.cameraIcon,
    Assets.assets.icons.cameraIcon,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     Colors.black.withOpacity(0.2), // Top opacity 0.2
            //     Colors.white.withOpacity(0), // Bottom opacity 0
            //   ],
            // ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: iconData.length, // The number of icons you want to display
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // The number of columns
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return SvgPicture.asset(
                iconData[index],
                width: 16,
                height: 16,
                fit: BoxFit.scaleDown,
              );
            },
          ),
        ));
    
  }
}
