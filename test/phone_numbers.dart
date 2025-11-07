import 'package:flutter_test/flutter_test.dart';

void main() {
  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
  String getCountryCode(String phoneNumber) {
    String countryCode = '';

    for (int i = 0; i < phoneNumber.length; i++) {
      if (isNumeric(phoneNumber[i])) {
        countryCode += phoneNumber[i];
      } else {
        break;
      }
    }


    return countryCode;
  }

  String getLocalNumber(String phoneNumber, int countryCodeLength) {
    return phoneNumber.substring(countryCodeLength + 1); // Local number starts after the country code
  }


  test('Test getCountryCode function', () {
    expect(getCountryCode('+11234567890'), equals('1'));
    expect(getCountryCode('+441234567890'), equals('44'));
    expect(getCountryCode('+8612345678901'), equals('86'));
    expect(getCountryCode('+61312345678'), equals('61'));
    expect(getCountryCode('+912345678901'), equals('91'));
    expect(getCountryCode('+81312345678'), equals('81'));
    expect(getCountryCode('+551234567890'), equals('55'));
    expect(getCountryCode('+972523456789'), equals('972')); // Israeli phone number
  });

}