import "dart:io";

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatelessWidget {
  const CustomRefreshIndicator({super.key,
    required this.child,
    required this.onRefresh,
    // required this.refreshKey,
   
  });

  final Widget child;
 
  final Future Function() onRefresh;
  // final GlobalKey<RefreshIndicatorState> refreshKey;
  @override
  Widget build(BuildContext context) {
    return  buildIosWidget();
  }

  buildIosWidget() {
    return CustomScrollView(
      
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          // key: refreshKey,
        ),
        SliverToBoxAdapter(
          child: child,
        ),
      ],
    );
  }

  buildAndroidWidget() {
    return RefreshIndicator(
      
        onRefresh: onRefresh,

        child: child,
        //  key: refreshKey
        );
  }
}
