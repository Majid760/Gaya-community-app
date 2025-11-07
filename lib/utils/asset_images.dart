import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/utils/theme/app_colors.dart';

class ImageAssetsUtils {
  ImageAssetsUtils._();

  // nav bar icons
  static const String _navBarPath = 'Assets/icons/navbar_icons/';
  static const String _icon = 'Assets/icons/';
  static const String homeSelectedIconPath = '${_navBarPath}selected_home.svg';
  static const String homeUnselectedIconPath = '${_navBarPath}unselected_home.svg';
  static const String addPostIconPath = '${_navBarPath}add_post.svg';
  static const String addIconPath = '${_icon}add_icon.svg';

  static const String messageSelectedIconPath = '${_navBarPath}selected_message.svg';
  static const String messageUnselectedIconPath = '${_navBarPath}unselected_message.svg';

  static const String communitySelectedIconPath = '${_navBarPath}selected_communities.svg';
  static const String communityUnselectedIconPath = '${_navBarPath}unselected_communities.svg';
  static const String notificationSelectedIconPath = '${_navBarPath}selected_notification.svg';
  static const String notificationUnselectedIconPath = '${_navBarPath}unselected_notification.svg';
  static const String profileSelectedIconPath = '${_navBarPath}selected_profile.svg';
  static const String profileUnselectedIconPath = '${_navBarPath}unselected_profile.svg';
  static const String whiteInstagramLogo = "Assets/icons/white_instagram.png";
  static const String watches = "Assets/icons/notification_icon/watches.png";

  // app icons
  static const String _appImagesPath = 'Assets/images/';
  static const String crownFilled = '${_appImagesPath}filled_crown.svg';
  static const String arrows = '${_appImagesPath}arrows.svg';
  static const String gayaLogoWithText = '${_appImagesPath}gaya_logo_with_text.svg';
  static const String pasteYourLink = '${_appImagesPath}paste_your_link.svg';
  static const String crownGreyed = '${_appImagesPath}grey_crown.svg';
  static const String messageIcon = 'Assets/icons/common/message_icon.svg';

  //default URLS
  static const String anonymousUserOldNetworkUrl =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/images%2Fanonymous_user.png?alt=media&token=24138a42-0847-433b-9336-e65ad571d0ae';
  static const String anonymousBoyNetworkUrl =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/assets%2Fanonymous_boy.png?alt=media&token=05bcc5f2-70bb-475e-9e48-0fbec80283b7';
  static const String anonymousGirlNetworkUrl =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/assets%2Fanonymous_girl.png?alt=media&token=d190de10-5c77-4d13-8607-806bd5846a1f';
  static const String anonymousUserNetworkUrl =
      'https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/assets%2Fanonymous_user.png?alt=media&token=edab1ce2-6ee3-4421-8747-8314bb16037c';

  // done by mak, all Svg's icon paths

  // done by mak
  static const String filledPath = "Assets/icons/filled/";
  static const String outlinePath = "Assets/icons/outline/";

  // filled icons getters
  static String get annotationFilled => '${filledPath}annotation-dots_fill.svg';

  static String get bellFilled => '${filledPath}bell_fill.svg';

  static String get bookmarkFilled => '${filledPath}bookmark_fill.svg';

  static String get calendarDateFilled => '${filledPath}calendar-date_fill.svg';

  static String get cameraFilled => '${filledPath}camera_fill.svg';

  static String get checkVerifiedFilled => '${filledPath}check-verified_fill.svg';

  static String get clockFilled => '${filledPath}clock_fill.svg';

  static String get crownFilledd => '${filledPath}crown_fill.svg';

  static String get editFilled => '${filledPath}edit_fill.svg';

  static String get eyeOffFilled => '${filledPath}eye-off_fill.svg';

  static String get eyeFilled => '${filledPath}eye_fill.svg';

  static String get faceSmileFilled => '${filledPath}face-smile_fill.svg';

  static String get fileFilled => '${filledPath}file_fill.svg';

  static String get heartFilled => '${filledPath}heart_fill.svg';

  static String get homeLineFilled => '${filledPath}home-line_fill.svg';

  static String get infoCircleFilled => '${filledPath}info-circle_fill.svg';

  static String get lockUnlockedFilled => '${filledPath}lock-unlocked_fill.svg';

  static String get lockFilled => '${filledPath}lock_fill.svg';

  static String get logoutFilled => '${filledPath}log-out_fill.svg';

  static String get messageTextSquare1Filled => '${filledPath}message-text-square-1_fill.svg';

  static String get messageTextSquareFilled => '${filledPath}message-text-square_fill.svg';

  static String get microphoneFilled => '${filledPath}microphone_fill.svg';

  static String get minusCircleFilled => '${filledPath}minus-circle_fill.svg';

  static String get musicNoteFilled => '${filledPath}music-note_fill.svg';

  static String get paletteFilled => '${filledPath}palette_fill.svg';

  static String get pinFilled => '${filledPath}pin_fill.svg';

  static String get playFilled => '${filledPath}play_fill.svg';

  static String get plusCircleFilled => '${filledPath}plus-circle_fill.svg';

  static String get send1Filled => '${filledPath}send-01_fill.svg';

  static String get settingsFilled => '${filledPath}settings_fill.svg';

  static String get shareFilled => '${filledPath}share_fill.svg';

  static String get trashFilled => '${filledPath}trash_fill.svg';

  static String get userCheckFilled => '${filledPath}user-check_fill.svg';

  static String get userCircleFilled => '${filledPath}user-circle_fill.svg';

  static String get userMinusFilled => '${filledPath}user-minus_fill.svg';

  static String get userPlusFilled => '${filledPath}user-plus_fill.svg';

  static String get userRightFilled => '${filledPath}user-right_fill.svg';

  static String get userFilled => '${filledPath}user_fill.svg';

  static String get usersCheckFilled => '${filledPath}users-check_fill.svg';

  static String get usersMinusFilled => '${filledPath}users-minus_fill.svg';

  static String get usersFilled => '${filledPath}users_fill.svg';

  // end of filled icons getters

  // outlined icons getters
  static String get bellOutline => '${outlinePath}bell_outline.svg';

  static String get bookmarkOutline => '${outlinePath}bookmark_outline.svg';

  static String get calendarDateOutline => '${outlinePath}calendar-date_outline.svg';

  static String get cameraOutline => '${outlinePath}camera_outline.svg';

  static String get checkVerifiedOutline => '${outlinePath}check-verified_outline.svg';

  static String get checkOutline => '${outlinePath}check_outline.svg';

  static String get chevronDownOutline => '${outlinePath}chevron-down_outline.svg';

  static String get chevronLeftOutline => '${outlinePath}chevron-left_outline.svg';

  static String get clockOutline => '${outlinePath}clock_outline.svg';

  static String get commentOutline => '${outlinePath}comment_outline.svg';

  static String get cropOutline => '${outlinePath}crop_outline.svg';

  static String get crownOutline => '${outlinePath}crown_outline.svg';

  static String get dotsHorizontalOutline => '${outlinePath}dots-horizontal_outline.svg';

  static String get editOutline => '${outlinePath}edit_outline.svg';

  static String get eyeOffOutline => '${outlinePath}eye-off_outline.svg';

  static String get eyeOutline => '${outlinePath}eye_outline.svg';

  static String get faceSmileOutline => '${outlinePath}face-smile_outline.svg';

  static String get fileOutline => '${outlinePath}file_outline.svg';

  static String get heartOutline => '${outlinePath}heart_outline.svg';

  static String get homeLineOutline => '${outlinePath}home-line_outline.svg';

  static String get imageOutline => '${outlinePath}image_outline.svg';

  static String get infoCircleOutline => '${outlinePath}info-circle_outline.svg';

  static String get linkOutline => '${outlinePath}link_outline.svg';

  static String get loadingOutline => '${outlinePath}loading_outline.svg';

  static String get lockUnlockedOutline => '${outlinePath}lock-unlocked_outline.svg';

  static String get lockOutline => '${outlinePath}lock_outline.svg';

  static String get logoutOutline => '${outlinePath}log-out_outline.svg';

  static String get menuOutline => '${outlinePath}menu_outline.svg';

  static String get messageTextSquareOutline => '${outlinePath}message-text-square_outline.svg';

  static String get messagesOutline => '${outlinePath}messages_outline.svg';

  static String get microphoneOutline => '${outlinePath}microphone_outline.svg';

  static String get minusCircleOutline => '${outlinePath}minus-circle_outline.svg';

  static String get musicNoteOutline => '${outlinePath}music-note_outline.svg';

  static String get paletteOutline => '${outlinePath}palette_outline.svg';

  static String get pinOutlinee => '${outlinePath}pin_outline.svg';

  static String get playCircleOutline => '${outlinePath}play-circle_outline.svg';

  static String get playOutline => '${outlinePath}play_outline.svg';

  static String get plusCircleOutline => '${outlinePath}plus-circle_outline.svg';

  static String get plusOutline => '${outlinePath}plus_outline.svg';

  static String get searchLgOutline => '${outlinePath}search-lg_outline.svg';

  static String get sendOutline => '${outlinePath}send_outline.svg';

  static String get settingsOutline => '${outlinePath}settings_outline.svg';

  static String get shareOutline => '${outlinePath}share_outline.svg';

  static String get trash1Outline => '${outlinePath}trash-1_outline.svg';

  static String get trashOutline => '${outlinePath}trash_outline.svg';

  static String get userCheckOutline => '${outlinePath}user-check_outline.svg';

  static String get userCircleOutline => '${outlinePath}user-circle_outline.svg';

  static String get userMinusOutline => '${outlinePath}user-minus_outline.svg';

  static String get userPlusOutline => '${outlinePath}user-plus_outline.svg';

  static String get userRightOutline => '${outlinePath}user-right_outline.svg';

  static String get userShieldTickOutline => '${outlinePath}user-shield-tick_outline.svg';

  static String get userOutline => '${outlinePath}user_outline.svg';

  static String get usersCheckOutline => '${outlinePath}users-check_outline.svg';

  static String get usersMinusOutline => '${outlinePath}users-minus_outline.svg';

  static String get usersPlusOutline => '${outlinePath}users-plus_outline.svg';

  static String get usersRightOutline => '${outlinePath}users-right_outline.svg';

  static String get usersOutline => '${outlinePath}users_outline.svg';

  static String get xCloseOutline => '${outlinePath}x-close_outline.svg';
}

class SvgIcons {
  static const String _appImagesPath = 'Assets/images/';
  static const String _appIconsPath = 'Assets/icons/';
  static const String _commonIconsPath = '${_appIconsPath}common/';
  static SvgPicture crownGreyOutSmall = SvgPicture.asset(ImageAssetsUtils.crownGreyed, height: 10.r, width: 12.r);
  static SvgPicture crownFilledSmall = SvgPicture.asset(ImageAssetsUtils.crownFilled, height: 10.r, width: 12.r);
  static SvgPicture arrows = SvgPicture.asset(
    ImageAssetsUtils.arrows,
  );
  static SvgPicture gayaLogoWithText = SvgPicture.asset(
    ImageAssetsUtils.gayaLogoWithText,
  );

  static SvgPicture shareIcon = SvgPicture.asset('${_appIconsPath}share.svg');
  static SvgPicture moreIcon = SvgPicture.asset('${_appIconsPath}more.svg');
  static SvgPicture moreIconBlack = SvgPicture.asset('${_appIconsPath}more.svg', color: AppColors.black, height: 24.r, width: 24.r);
  static Widget searchIcon = SvgPicture.asset('${_appIconsPath}search.svg');
  static Widget addPerson = SvgPicture.asset('${_appIconsPath}add.svg');

  static Widget leftArrowIcon({required bool isLight}) =>
      SvgPicture.asset('${_appIconsPath}left_arrow.svg', color: isLight ? AppColors.white : AppColors.black);

  //snackbars icon
  static Widget communitiesIcon({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}communities.svg', height: height, width: width, color: color);

  // more on post
  static Widget bellOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}bell_outline.svg', height: height, width: width, color: color);

  static Widget bellSolid({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}bell_solid.svg', height: height, width: width, color: color);

  static Widget hide({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}hide.svg', height: height, width: width, color: color);

  static Widget leave({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}leave.svg', height: height, width: width, color: color);

  static Widget linkOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}link_outline.svg', height: height, width: width, color: color);

  static Widget pinOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}pin_outline.svg', height: height, width: width, color: color);

  static Widget pinSolid({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}pin_solid.svg', height: height, width: width, color: color);

  static Widget saveOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}save_outline.svg', height: height, width: width, color: color);

  static Widget saveSolid({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}save_solid.svg', height: height, width: width, color: color);

  static Widget problem({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}problem.svg', height: height, width: width, color: color);

  static Widget postOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}post_outline.svg', height: height, width: width, color: color);

  static Widget deleteOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}delete_outline.svg', height: height, width: width, color: color);

  /// NOT FOUND ICON
  static Widget notFoundSolid({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}not_found.svg', height: height, width: width, color: color);

  static Widget adminWhite({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}admin.svg', height: height, width: width, color: color);

  static Widget settings({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}setting.svg', height: height, width: width, color: color);

  static Widget information({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}information.svg', height: height, width: width, color: color);

  static Widget lockOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset('${_commonIconsPath}lock_outline.svg', height: height, width: width, color: color);

  // done by mak (filled icons widgets)
  static Widget annotationFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.annotationFilled, height: height, width: width, color: color);

  static Widget bellFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.bellFilled, height: height, width: width, color: color);

  static Widget bookmarkFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.bookmarkFilled, height: height, width: width, color: color);

  static Widget calendarDateFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.calendarDateFilled, height: height, width: width, color: color);

  static Widget cameraFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.cameraFilled, height: height, width: width, color: color);

  static Widget checkVerifiedFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.checkVerifiedFilled, height: height, width: width, color: color);

  static Widget clockFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.clockFilled, height: height, width: width, color: color);

  static Widget crownFilledd({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.crownFilledd, height: height, width: width, color: color);

  static Widget editFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.editFilled, height: height, width: width, color: color);

  static Widget eyeOffFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.eyeOffFilled, height: height, width: width, color: color);

  static Widget faceSmileFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.faceSmileFilled, height: height, width: width, color: color);

  static Widget fileFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.fileFilled, height: height, width: width, color: color);

  static Widget heartFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.heartFilled, height: height, width: width, color: color);

  static Widget homeLineFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.homeLineFilled, height: height, width: width, color: color);

  static Widget infoCircleFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.infoCircleFilled, height: height, width: width, color: color);

  static Widget lockUnlockedFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.lockUnlockedFilled, height: height, width: width, color: color);

  static Widget lockFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.lockFilled, height: height, width: width, color: color);

  static Widget logoutFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.logoutFilled, height: height, width: width, color: color);

  static Widget messageTextSquare1Filled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.messageTextSquare1Filled, height: height, width: width, color: color);

  static Widget messageTextSquareFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.messageTextSquareFilled, height: height, width: width, color: color);

  static Widget microphoneFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.microphoneFilled, height: height, width: width, color: color);

  static Widget minusCircleFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.minusCircleFilled, height: height, width: width, color: color);

  static Widget musicNoteFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.musicNoteFilled, height: height, width: width, color: color);

  static Widget paletteFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.paletteFilled, height: height, width: width, color: color);

  static Widget pinFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.pinFilled, height: height, width: width, color: color);

  static Widget playFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.playFilled, height: height, width: width, color: color);

  static Widget plusCircleFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.plusCircleFilled, height: height, width: width, color: color);

  static Widget send1Filled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.send1Filled, height: height, width: width, color: color);

  static Widget settingsFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.settingsFilled, height: height, width: width, color: color);

  static Widget shareFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.shareFilled, height: height, width: width, color: color);

  static Widget trashFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.trashFilled, height: height, width: width, color: color);

  static Widget userCheckFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userCheckFilled, height: height, width: width, color: color);

  static Widget userCircleFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userCircleFilled, height: height, width: width, color: color);

  static Widget userMinusFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userMinusFilled, height: height, width: width, color: color);

  static Widget userPlusFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userPlusFilled, height: height, width: width, color: color);

  static Widget userRightFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userRightFilled, height: height, width: width, color: color);

  static Widget userFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userFilled, height: height, width: width, color: color);

  static Widget usersCheckFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.usersCheckFilled, height: height, width: width, color: color);

  static Widget usersMinusFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.usersMinusFilled, height: height, width: width, color: color);

  static Widget usersFilled({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.usersFilled, height: height, width: width, color: color);

  //  outline icons widgets
  static Widget bellOutline1({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.bellOutline, height: height, width: width, color: color);

  static Widget bookmarkOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.bookmarkOutline, height: height, width: width, color: color);

  static Widget calendarDateOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.calendarDateOutline, height: height, width: width, color: color);

  static Widget cameraOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.cameraOutline, height: height, width: width, color: color);

  static Widget checkVerifiedOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.checkVerifiedOutline, height: height, width: width, color: color);

  static Widget checkOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.checkOutline, height: height, width: width, color: color);

  static Widget commentOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.commentOutline, height: height, width: width, color: color);

  static Widget cropOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.cropOutline, height: height, width: width, color: color);

  static Widget crownOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.crownOutline, height: height, width: width, color: color);

  static Widget dotsHorizontalOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.dotsHorizontalOutline, height: height, width: width, color: color);

  static Widget editOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.editOutline, height: height, width: width, color: color);

  static Widget eyeOffOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.eyeOffOutline, height: height, width: width, color: color);

  static Widget faceSmileOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.faceSmileOutline, height: height, width: width, color: color);

  static Widget fileOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.fileOutline, height: height, width: width, color: color);

  static Widget heartOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.heartOutline, height: height, width: width, color: color);

  static Widget homeLineOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.homeLineOutline, height: height, width: width, color: color);

  static Widget imageOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.imageOutline, height: height, width: width, color: color);

  static Widget infoCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.infoCircleOutline, height: height, width: width, color: color);

  static Widget linkOutline1({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.linkOutline, height: height, width: width, color: color);

  static Widget loadingOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.loadingOutline, height: height, width: width, color: color);

  static Widget lockUnlockedOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.lockUnlockedOutline, height: height, width: width, color: color);

  static Widget lockOutline1({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.lockOutline, height: height, width: width, color: color);

  static Widget logoutOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.logoutOutline, height: height, width: width, color: color);

  static Widget menuOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.menuOutline, height: height, width: width, color: color);

  static Widget messageTextSquareOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.messageTextSquareOutline, height: height, width: width, color: color);

  static Widget messagesOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.messagesOutline, height: height, width: width, color: color);

  static Widget microphoneOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.microphoneOutline, height: height, width: width, color: color);

  static Widget minusCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.minusCircleOutline, height: height, width: width, color: color);

  static Widget musicNoteOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.musicNoteOutline, height: height, width: width, color: color);

  static Widget paletteOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.paletteOutline, height: height, width: width, color: color);

  static Widget pinOutlinee({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.pinOutlinee, height: height, width: width, color: color);

  static Widget playCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.playCircleOutline, height: height, width: width, color: color);

  static Widget playOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.playOutline, height: height, width: width, color: color);

  static Widget plusCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.plusCircleOutline, height: height, width: width, color: color);

  static Widget plusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.plusOutline, height: height, width: width, color: color);

  static Widget searchLgOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.searchLgOutline, height: height, width: width, color: color);

  static Widget sendOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.sendOutline, height: height, width: width, color: color);

  static Widget settingsOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.settingsOutline, height: height, width: width, color: color);

  static Widget shareOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.shareOutline, height: height, width: width, color: color);

  static Widget trash1Outline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.trash1Outline, height: height, width: width, color: color);

  static Widget trashOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.trashOutline, height: height, width: width, color: color);

  static Widget userCheckOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userCheckOutline, height: height, width: width, color: color);

  static Widget userCircleOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userCircleOutline, height: height, width: width, color: color);

  static Widget userMinusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userMinusOutline, height: height, width: width, color: color);

  static Widget userPlusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userPlusOutline, height: height, width: width, color: color);

  static Widget userRightOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userRightOutline, height: height, width: width, color: color);

  static Widget userShieldTickOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userShieldTickOutline, height: height, width: width, color: color);

  static Widget userOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.userOutline, height: height, width: width, color: color);

  static Widget usersCheckOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.usersCheckOutline, height: height, width: width, color: color);

  static Widget usersMinusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.usersMinusOutline, height: height, width: width, color: color);

  static Widget usersPlusOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.usersPlusOutline, height: height, width: width, color: color);

  static Widget usersRightOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.usersRightOutline, height: height, width: width, color: color);

  static Widget usersOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.usersOutline, height: height, width: width, color: color);

  static Widget xCloseOutline({double? height, double? width, Color? color}) =>
      GayaSvgAsset(ImageAssetsUtils.xCloseOutline, height: height, width: width, color: color);

  /* ------------------------------ NOTIFICATION ------------------------------ */
  static Widget get watches => Image.asset(
        ImageAssetsUtils.watches,
        height: 24.0.h,
        fit: BoxFit.contain,
      );
}

class GayaSvgAsset extends StatelessWidget {
  final String assetPath;
  final double? height;
  final double? width;
  final Color? color;

  const GayaSvgAsset(
    this.assetPath, {
    Key? key,
    this.height = 16,
    this.width = 16,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(assetPath,
        height: height, width: width, colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null);
  }
}
