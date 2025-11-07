import 'package:flutter_test/flutter_test.dart';
import 'package:gaya/shared/service/message_service/message_service.dart';

void main() {
  Matcher yes = isNull;
  Matcher no = isNotNull;
  group('Send Message to unknown check', () {
    test('User is a friend', () {
      bool isFriend = true;
      bool isAgeValid = true;
      bool isDMDisabled = true;

      String? result = checkFriendship(isFriend, isAgeValid, isDMDisabled);

      expect(result, yes);
    });

    test('User is not a friend, message is not disabled, and age is not valid', () {
      bool isFriend = false;
      bool isAgeValid = false;
      bool isDMDisabled = false;

      String? result = checkFriendship(isFriend, isAgeValid, isDMDisabled);

      expect(result, yes);
    });

    test('User is not a friend, message is disabled, but age is valid', () {
      bool isFriend = false;
      bool isAgeValid = true;
      bool isDMDisabled = false;

      String? result = checkFriendship(isFriend, isAgeValid, isDMDisabled);

      expect(result, yes);
    });

    test('User is not a friend, message is not disabled, and age is not valid', () {
      bool isFriend = false;
      bool isAgeValid = false;
      bool isDMDisabled = true;

      String? result = checkFriendship(isFriend, isAgeValid, isDMDisabled);

      expect(result, no);
    });

    test('User is not a friend, message is not disabled, and age is valid', () {
      bool isFriend = false;
      bool isAgeValid = true;
      bool isDMDisabled = true;

      String? result = checkFriendship(isFriend, isAgeValid, isDMDisabled);

      expect(result, no);
    });

    test('User is a friend, but message is disabled', () {
      bool isFriend = true;
      bool isAgeValid = true;
      bool isDMDisabled = false;

      String? result = checkFriendship(isFriend, isAgeValid, isDMDisabled);

      expect(result, yes);
    });

    test('User is a friend, message is not disabled, but age is not valid', () {
      bool isFriend = true;
      bool isAgeValid = false;
      bool isDMDisabled = true;

      String? result = checkFriendship(isFriend, isAgeValid, isDMDisabled);

      expect(result, yes);
    });

    test('User is not a friend, message is not disabled, and age is valid', () {
      bool isFriend = false;
      bool isAgeValid = true;
      bool isDMDisabled = true;

      String? result = checkFriendship(isFriend, isAgeValid, isDMDisabled);

      expect(result, no);
    });

    test('User is not a friend, message is disabled, and age is valid', () {
      bool isFriend = false;
      bool isAgeValid = true;
      bool isDMDisabled = false;

      String? result = checkFriendship(isFriend, isAgeValid, isDMDisabled);

      expect(result, yes);
    });
  });
}

String? checkFriendship(bool _isFriend, bool _isAgeValid, bool _isDMDisabled) {
  return MessageUtils.canSendMessage(_isFriend, _isAgeValid, _isDMDisabled);
}
