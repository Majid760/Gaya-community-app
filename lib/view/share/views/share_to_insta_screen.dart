import 'package:flutter/material.dart';

import '../../../shared/widgets/colorful_animation/color_animated_bg.dart';
import '../models/community_insta_share.dart';
import '../models/insta_share.dart';
import '../models/post_insta_share.dart';
import '../widgets/black_vignette.dart';
import '../widgets/cancel_icon.dart';
import '../widgets/community_insta_share_view/community_insta_share_view.dart';
import '../widgets/post_insta_share_view/post_insta_share_view.dart';

class ShareToInstaView extends StatelessWidget {
  const ShareToInstaView({
    Key? key,
    required this.isCommunityShare,
    required this.instaShare,
  }) : super(key: key);

  final bool isCommunityShare;
  final InstaShare instaShare;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const ColorfulAnimatedBackground(),
          const BlackVignette(),
          isCommunityShare
              ? CommunityInstaShareView(communityInstaShare: instaShare as CommunityInstaShare)
              : PostInstaShareView(postInstaShare: instaShare as PostInstaShare),
          const CancelIcon(),
        ],
      ),
    );
  }
}
