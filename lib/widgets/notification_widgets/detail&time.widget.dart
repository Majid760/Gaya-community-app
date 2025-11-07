
import 'package:flutter/material.dart';

import '../../utils/const.dart';
import '../../utils/textstyles.dart';

class NotificationDetailandTimeWidget extends StatelessWidget {
  final String notificationText;
  final String timePosted;
  const NotificationDetailandTimeWidget({
    Key? key,
    required this.notificationText,
    required this.timePosted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: distance_80),
          child: Text(
            notificationText,
            style: CustomTypography.body4Style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          height: distance_5,
        ),
        Text(
          timePosted.toString(),
          style: CustomTypography.body3Style,
        )
      ],
    );
  }
}
