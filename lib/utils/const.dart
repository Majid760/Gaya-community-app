import 'package:flutter/material.dart';
import 'package:gaya/utils/theme/app_colors.dart';

//Colors
const Color kprimaryColor = Color(0xFF7A24FF);

const Color kTransparentColor = Color(0x00000000);
const Color kprimaryColorLight = Color(0xFFEFE6FD);
const Color kSecondaryColor = Color(0xFF8E8E93);
const Color kSecondaryLightColor = Color(0xFFEBEBF0);
const Color kBlackColor = Color(0xFF000000);
const Color kRedColor = Color(0xFFFF3B30);
const Color kYellowColor = Color(0xFFFFCC00);
const Color kBaseGrey = Color(0XFFEBEBF0);
const Color kWhiteColor = Colors.white;
const Color kDimWhiteColor = Color(0XFFF5F5F5);
const Color borderColor = Color(0xFFD1D2D6);
const Color disableColor = Color(0xFFC7C7CC);
const Color lightPurple = Color(0xFFD7B7EA);
const Color greenColor = Color(0xFF34C759);
const Color gayaLogoColor = kprimaryColor;
const Color blueColor = Color(0xFF00A3FF);
const Color socialMediaButtonBackgroundColor = Color(0xFFF2F2F2);
const Color socialMediaButtonBorderColor = Color(0xFFD1D2D6);
const Color kLinkColor = Color(0xFF007AFF);
const Color kHashTagColor = Color(0xFF007AFF);
const Color kPrimaryBackgroundBtnColor = Color(0XFF8133F1);
const Color kLightPink = Color(0XFFEFE6FD);
const Color kpurpleColor = Color(0xFF8500D6);
// String d = 0XFFFFF3F2.toString();
// int integ = int.parse(d);
// Color aaa = Color(integ);

//padding , margin , sizedbox heights and width (distances)
const double distance_5 = 5;
const double distance_8 = 8;
const double distance_10 = 10;
const double distance_3 = 3;
const double distance_12 = 12;
const double distance_20 = 20;
const double distance_16 = 16;

const double distance_15 = 15;
const double distance_18 = 18;
const double distance_24 = 24;
const double distance_25 = 25;
const double distance_30 = 30;
const double distance_40 = 40;
const double distance_50 = 50;
const double distance_60 = 60;
const double distance_70 = 70;
const double distance_80 = 80;

//border Radius
const double borderRadius_4 = 4;
const double borderRadius_8 = 8;
//dummy images url
const profileImage =
    'https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZSUyMGltbWFnZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60';
const recipeImage1 =
    'https://images.unsplash.com/photo-1466637574441-749b8f19452f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cmVjaXBlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=800&q=60';
const profileImage1 =
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60';
const profileImage4 =
    'https://images.unsplash.com/photo-1533636721434-0e2d61030955?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHByb2ZpbGUlMjBpbW1hZ2V8ZW58MHx8MHx8&auto=format&fit=crop&w=800&q=60';
const profileImage2 =
    'https://images.unsplash.com/photo-1474552226712-ac0f0961a954?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60';
const recipeimage2 =
    'https://images.unsplash.com/photo-1490818387583-1baba5e638af?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHJlY2lwZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60';
const recipeImage3 =
    'https://media.istockphoto.com/photos/fresh-vegetables-picture-id638859932?b=1&k=20&m=638859932&s=170667a&w=0&h=_SgZB5umT0OA_UV_oUA12kEZtSr9wzZkIly6yGrA4iE=';

//urls
const APP_STORE_URL = 'https://apps.apple.com/app/gaya-communities/id1662332476';
const PLAY_REDIRECT_STORE_URL = 'market://details?id=com.gaya.android';
const PLAY_STORE_URL = 'https://play.google.com/store/apps/details?id=com.gaya.android';

Color getColorFromHex(String? hexColor) {
  /// assign default color if null - Pinkish
  hexColor ??= moderatortagColors[4];
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }

  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }

  return AppColors.chipLightPink;
}

List<String> moderatortagColors = [

  "#A2C3C8",
  "#C7D8F2",
  "#B1E5F2",
  "#9FC5E9",
  "#CEB0FA",
  "#DD7E6C",
  "#FFC0BE",
  "#E99998",
  "#F9CA9C",
  "#FCB07E",
  "#EAC5D8",
  "#F7B2BD",
  "#EBEBF0",
  "#F4FFF8",
  "#FFE59A",
  "#FFF9A5",
  "#B6D7A8",
  "#AAFCB8",
  "#E6E4CE",
  "#DFEFCA"

  
  // "DD7E6C",
  // "EA9999",
  // "F9CB9C",
  // "FFE599",
  // "B6D7A8",
  // "A2C4C9",
  // "C7D8F3",
  // "9FC5E8",
  // "B4A7D6",
  // "741B47",

  // // previous colors
  // 'FFEBEBF0',
  // 'FF8500D6',
  // 'FF34C759',
  // 'FFD28AFF',
  // 'FFFFCC00',
  // 'FF0094FF',
  // 'FFE27FD2',
];
