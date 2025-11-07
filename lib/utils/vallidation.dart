import 'package:form_field_validator/form_field_validator.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

class FormValidation {
  //Register form validation
  //{
  // final register = RegisterController();
  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: GayaStrings.password_required.tr),
    MinLengthValidator(8, errorText: GayaStrings.enter_password_characters.tr),
    PatternValidator(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$', errorText: GayaStrings.password_upper_lower_case.tr)
  ]);

  final verifyDob = MultiValidator([
    RequiredValidator(errorText: GayaStrings.enter_dob.tr),
  ]);

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: GayaStrings.email_required.tr),
    PatternValidator(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+", errorText: GayaStrings.enter_valid_email.tr)
    // PatternValidator(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+", errorText: 'Please insert a valid email address')
  ]);

  final fullNameValidator = MultiValidator([RequiredValidator(errorText: GayaStrings.name_please.tr)]);

  final firstNameValidator = MultiValidator([
    RequiredValidator(errorText: GayaStrings.first_name_required.tr),
  ]);

  final fieldNotEmptyValidator = MultiValidator([
    RequiredValidator(errorText: GayaStrings.field_empty.tr),
  ]);

  final lastNameValidator = MultiValidator([
    RequiredValidator(errorText: GayaStrings.last_required.tr),
  ]);

  final phoneNumberValidator = MultiValidator([
    RequiredValidator(errorText: GayaStrings.phone_no_required.tr),
    PatternValidator(r'(^(?:[+0]9)?[0-9]{9,12}$)', errorText: GayaStrings.not_valid_phone_no.tr),
  ]);

  final verifyPhone = MultiValidator([
    RequiredValidator(errorText: GayaStrings.verification_code_required.tr),
    MinLengthValidator(6, errorText: GayaStrings.enter_digit_code_sent.tr),
  ]);

  //}

  //login form validation
  final loginEmailValidation = MultiValidator([RequiredValidator(errorText: GayaStrings.email_required.tr)]);
  final passwordDoesnotMatch = MultiValidator([RequiredValidator(errorText: GayaStrings.passwords_confirm_password_not_same.tr)]);
  final loginPasswordValidation = MultiValidator([
    RequiredValidator(errorText: GayaStrings.password_required.tr),
  ]);

  static String? checkEmpty(String? value) {
    if (value != null && value.isEmpty) {
      return GayaStrings.field_empty.tr;
    }
    return null;
  }

  static String? validateName(String? value) {
    if ((value?.length ?? 0) < 5) {
      return GayaStrings.name_five_character.tr;
    }

    return null;
  }

  static String? validateCommunityName(String? value) {
    if ((value?.length ?? 0) < 10 || (value?.length ?? 0) > 30) {
      return GayaStrings.valid_community_name.tr;
    }
    return null;
  }

  static String? validateCommunityDescription(String? value) {
    if ((value?.length ?? 0) < 10) {
      return GayaStrings.description_ten_character.tr;
    }
    return null;
  }

  static String? messageValidate(String? value) {
    if ((value?.length ?? 0) > 10000) {
      return GayaStrings.description_ten_character.tr;
    }
    return null;
  }

  static String? validateEndDate(String value, DateTime? endDate, String frequency, bool isRecurring) {
    print('endDate: ' + endDate.toString());
    /*   if (endDate == null || value.length == 0) {
      return "Please select a date";
    } else*/
    if (frequency == 'Weekly' && !isRecurring) {
      //next week date
      DateTime now = DateTime.now();
      DateTime nextWeekDate = DateTime(now.year, now.month, now.day + 7);
      print('nextWeekDate: ' + nextWeekDate.toString());
      if (endDate?.isBefore(nextWeekDate) ?? false) return "Can't select this date";
    } else if (frequency == 'Bi-Weekly' && !isRecurring) {
      //next week date
      DateTime now = DateTime.now();
      DateTime nextBiWeekDate = DateTime(now.year, now.month, now.day + 14);
      print('nextBi-WeeklyDate: ' + nextBiWeekDate.toString());
      if (endDate?.isBefore(nextBiWeekDate) ?? false) return "Can't select this date";
    } else if (frequency == 'Monthly' && !isRecurring) {
      //next week date
      DateTime now = DateTime.now();
      DateTime nextMonthDate = DateTime(now.year, now.month, now.day + 30);
      print('nextMonthlyDate: ' + nextMonthDate.toString());
      if (endDate?.isBefore(nextMonthDate) ?? false) return "Can't select this date";
    }
    return null;
  }

  static String? validateStartAndEndDate(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        return "Start date should be less than end date";
      }

      /// check if
    } else if (startDate == null) {
      return "Please select start date";
    } else if (endDate == null) {
      return "Please select end date";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return GayaStrings.email_required.tr;
    } else if (!GetUtils.isEmail(value)) {
      return GayaStrings.enter_valid_email.tr;
    }
    return null;
  }

  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return GayaStrings.type_message.tr;
    }
    return null;
  }
}
