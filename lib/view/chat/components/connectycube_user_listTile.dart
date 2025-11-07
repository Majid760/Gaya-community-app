import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';

class ConnectyCubeUserListTile extends StatelessWidget {
  final CubeUser user;
  final VoidCallback onUserTap;
  final ConversationController? conversationController;
  final ChatController? chatController;

  const ConnectyCubeUserListTile({Key? key, required this.user, required this.onUserTap, this.chatController, this.conversationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero, //const EdgeInsets.only(left: 20, right: 20).r,
      onTap: () => onUserTap(),
      leading: user.avatar == ''
          ? CircleAvatar(radius: 20.r, backgroundImage: AssetImage(Assets.assets.images.userDefault))
          : CircleAvatar(
              radius: 20.r,
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
      title: Text(user.fullName ?? '', style: GayaTypography.titleMedium.copyWith(fontWeight: FontWeight.w500, fontSize: 14.sp)),
      trailing: Checkbox(
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        checkColor: kWhiteColor,
        activeColor: kprimaryColor,
        fillColor: MaterialStateProperty.resolveWith((Set states) {
          if (states.contains(MaterialState.disabled)) {
            return kprimaryColor;
          }
          return kprimaryColor;
        }),
        value: (chatController != null)
            ? chatController!.isUserSelected(user)
            : (conversationController != null)
                ? conversationController!.isUserSelected(user)
                : false,
        side: BorderSide(
          color: kBlackColor.withOpacity(0.2),
          width: 1.0,
          style: BorderStyle.solid,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        // we need it on gesture detector
        onChanged: null,
      ),
    );
  }
}

class ConnectyCubeUserListTileWithoutCheckBox extends StatelessWidget {
  final CubeUser user;
  final VoidCallback onUserTap;
  final VoidCallback onUserLongTap;
  final String? trailingText;

  const ConnectyCubeUserListTileWithoutCheckBox(
      {Key? key, required this.user, required this.onUserTap, required this.onUserLongTap, this.trailingText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero, //const EdgeInsets.only(left: 20, right: 20).r,
        onTap: () => onUserTap(),
        onLongPress: () => onUserLongTap(),
        leading: user.avatar == ''
            ? CircleAvatar(radius: 20.r, backgroundImage: AssetImage(Assets.assets.images.userDefault))
            : CircleAvatar(
                radius: 20.r,
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
        title: Text(user.fullName ?? '', style: GayaTypography.titleMedium.copyWith(fontWeight: FontWeight.w500, fontSize: 14.sp)),
        trailing: trailingText == null
            ? Container(
                width: 20.r,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kBlackColor)),
                child: Icon(Icons.keyboard_arrow_right_outlined, size: 16.r),
              )
            : Text(
                trailingText!,
                style: TextStyle(color: AppColors.secondary2),
              ));
  }
}
