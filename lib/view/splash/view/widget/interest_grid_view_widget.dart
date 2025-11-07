/*
import 'package:flutter/material.dart';

import '../../../../model/topic.model.dart';
import 'interest_widget.dart';

class InterestGridViewWidget extends StatelessWidget {
  final List<TopicsModel> interests;
  final bool isSelected;
  final Function(TopicsModel) onTap;

  const InterestGridViewWidget({Key? key, required this.interests, required this.isSelected, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: interests.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          childAspectRatio: 1,
          crossAxisSpacing: 13,
          mainAxisSpacing: 13,
        ),
        itemBuilder: (context, index) {
          final interest = interests[index];
          return InterestWidget(
            onTap: () => onTap(interest),
            isSelected: isSelected,
            imageUrl: interest.url ?? "",
            title: interest.title,
          );
        });
  }
}
*/
