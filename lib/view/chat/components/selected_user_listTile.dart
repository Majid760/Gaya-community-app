import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectedUserListTile extends StatelessWidget {
  final CubeUser user;
  final VoidCallback onUserTap;

  const SelectedUserListTile({Key? key, required this.user, required this.onUserTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.r,
      width: 58.r,
      child: Stack(
        children: [
          Container(
            height: 58.r,
            width: 58.r,
            decoration: BoxDecoration(
              color: const Color(0xFFECF0F3),
              borderRadius: BorderRadius.circular(1000),
            ),
          ),
          user.avatar == ''
              ? CircleAvatar(radius: 29.r, backgroundImage: AssetImage(Assets.assets.images.userDefault))
              : CircleAvatar(
                  radius: 29.r,
                  child: CachedNetworkImage(
                    memCacheHeight: 100,
                    memCacheWidth: 100,
                    imageUrl: user.avatar ?? '',
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                      );
                    },
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Image.asset(Assets.assets.images.userDefault),
                    placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
                  ),
                ),
          Positioned(
            top: -2,
            right: -2,
            child: InkWell(
              onTap: () => onUserTap(),
              child: Container(
                height: 23.r,
                width: 23.r,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(1000)),
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Icon(
                    Icons.cancel,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
