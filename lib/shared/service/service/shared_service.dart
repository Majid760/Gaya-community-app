import 'dart:developer';

import 'package:gaya/utils/language/translation.dart';

enum Gender {
  male,
  female,
  nonBinary,
}

class SharedService {
  // gender list
  static List<Gender> genderStringList = [Gender.male, Gender.female, Gender.nonBinary];

  static String genderString(Gender gender) => Gender.nonBinary == gender ? GayaStrings.non_binary : gender.name;

  static int daysInYear = 365;

  //// this function is just for calculating and validating the age of uer entered age
  static bool isEnteredAgeValid(DateTime dateTime, int age) {
    try {
      DateTime currentDate = DateTime.now();
      DateTime minDate = DateTime(currentDate.year - age, currentDate.month, currentDate.day);
      return !dateTime.isAfter(minDate);
    } catch (e) {
      return false;
    }
  }
}
