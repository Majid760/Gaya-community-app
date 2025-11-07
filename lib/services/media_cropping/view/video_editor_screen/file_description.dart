import 'package:flutter/material.dart';

import '../../../../utils/theme/app_colors.dart';

class FileDescription extends StatelessWidget {
  const FileDescription({super.key, required this.description});

  final Map<String, String> description;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 11),
      child: Container(
        width: MediaQuery.sizeOf(context).width - 60,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: description.entries
              .map(
                (entry) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${entry.key}: ', style: const TextStyle(fontSize: 11, color: Colors.white)),
                      TextSpan(text: entry.value, style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
