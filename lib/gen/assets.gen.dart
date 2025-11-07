/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************
import 'package:flutter/widgets.dart';

class $AssetsGen {
  const $AssetsGen();

  $AssetsIconsGen get icons => const $AssetsIconsGen();
  $AssetsImagesGen get images => const $AssetsImagesGen();
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: Assets/icons/Union.svg
  String get union => 'Assets/icons/Union.svg';

  /// File path: Assets/icons/groups.svg
  String get groups => 'Assets/icons/groups.svg';

  String get user_solid => "Assets/icons/user_solid.svg";
  String get send => "Assets/icons/send.svg";

  /// File path: Assets/icons/home.svg
  String get home => 'Assets/icons/home.png';

  String get problem => 'Assets/icons/problem.svg';

  /// File path: Assets/icons/messages.svg
  String get messages => 'Assets/icons/messages.svg';

  String get galleryIcon => "Assets/icons/gallery_icon.svg";
  String get picturePickerIcon => "Assets/icons/picture_picker.svg";
  String get videoPickerIcon => "Assets/icons/video_picker.svg";
  String get documentIcon => "Assets/icons/document_icon.svg";
  String get postApproval => "Assets/icons/post_approval.svg";

  /// File path: Assets/icons/notification.svg
  String get notification => 'Assets/icons/notification.svg';

  String get write => "Assets/icons/write.svg";

  /// File path: Assets/icons/profile.svg
  String get profile => 'Assets/icons/profile.svg';

  String get communities => 'Assets/icons/community.svg';

  String get add_friends => 'Assets/icons/add_friend.svg';

  String get gallery => 'Assets/icons/gallery.svg';

  String get heartIcon => 'Assets/icons/heart_filled.svg';

  String get commentIcon => 'Assets/icons/comment_icon.svg';
  String get cameraIcon => 'Assets/icons/camera.svg';
  String get addIcon => 'Assets/icons/add_icon.svg';
  String get settingsIcon => "Assets/icons/settings.svg";
  String get editIcon => 'Assets/icons/common/edit_icon.svg';
  String get archive => 'Assets/icons/archive.svg';


  String get sendIcon => 'Assets/icons/send_icon.svg';
  String get microphone => 'Assets/icons/common/microphone.svg';
  String get groupImage => 'Assets/icons/common/group_image.svg';
  String get filledMicrophone => 'Assets/icons/common/filled_microphone.svg';
  String get audioTone => "Assets/music/Notification.mp3";
}

class $AssetsImagesGen {
  const $AssetsImagesGen();


  String get communityLogo => 'Assets/images/community_logo.png';
  String get onBoardingBrowse => 'Assets/images/splash_browse.svg';


  /// File path: Assets/images/Gaya_Logo.png
  AssetGenImage get gayaLogo => const AssetGenImage('Assets/images/Gaya_Logo.png');


  /// File path: Assets/images/flowers.svg
  String get flowers => 'Assets/images/flowers.svg';

  /// File path: Assets/images/hearts.svg
  String get hearts => 'Assets/images/hearts.svg';

  String get messageImage => 'Assets/images/message.png';

  String get notificationImage => 'Assets/images/notificationImage.png';
  String get flowerImage => 'Assets/images/flower1.svg';

  String get flowerImagePng => 'Assets/images/flower1.png';

  //post
  String get post => 'Assets/images/Post.svg';

  //comment
  String get reply => 'Assets/images/Reply.svg';

  String get userDefault => "Assets/images/user.png";
  String get maleImg => "Assets/images/maleImg.png";
  String get femaleImg => "Assets/images/femaleImg.png";
  String get nonBinaryImg => "Assets/images/nonBinaryImg.png";
  String get birthdayCake => "Assets/images/birthday_cake.png";
}

class Assets {
  Assets._();

  static const $AssetsGen assets = $AssetsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
