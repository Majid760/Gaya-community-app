import 'dart:ui';

import '../../../../utils/const.dart';

class CommunityThemeModel {
  bool? isThemeSelected;
  String? color;

  CommunityThemeModel({this.isThemeSelected, this.color});

  // to copyWith mehto
  CommunityThemeModel copyWith({
    bool? isThemeSelected,
    String? color,
  }) {
    return CommunityThemeModel(isThemeSelected: isThemeSelected ?? this.isThemeSelected, color: color ?? this.color);
  }

  CommunityThemeModel.fromMap(Map<String, dynamic> map) {
    isThemeSelected = map['isThemeSelected'] ?? false;
    color = map['color'];
  }

  Map<String, dynamic> toMap() {
    return {
      'isThemeSelected': isThemeSelected,
      'color': color,
    };
  }

  factory CommunityThemeModel.defaultTheme() {
    // getColorFromHex(communityModel?.communityThemeModel?.color ?? 'FFD28AFF')
    return CommunityThemeModel(isThemeSelected: false, color: 'FFD28AFF');
  }

  Color get toColor => getColorFromHex(color ?? 'FFD28AFF');
}
