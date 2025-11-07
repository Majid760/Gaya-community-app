import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:encrypt/encrypt.dart';

class EncryptData {
  static String encryptData({required final password}) {
    final key = Key.fromUtf8("12345678912345678912345678912345");
    final iv = IV.fromLength(16);
    final encryptor = Encrypter(AES(key));
    final encryptedPassword = encryptor.encrypt(password, iv: iv);
    // log("Encrypted Password Is with base 64 : ${encryptedPassword.base64}");
    // log("Encrypted Password Is without base 64: ${encryptedPassword.toString()}");
    return encryptedPassword.base64;
  }

  static dynamic decryptData({required final encryptedPassword}) {
    // log("<--------Encrypted Password----------->");
    // log(encryptedPassword.toString());
    final key = Key.fromUtf8("12345678912345678912345678912345");
    final iv = IV.fromLength(16);
    final encryptor = Encrypter(AES(key));
    final decryptedPassword = encryptor.decrypt(Encrypted.from64(encryptedPassword), iv: iv);
    // log("descrypted Password Is : ${decryptedPassword}");
    return decryptedPassword;
  }

///////////////////////////////////// Messages encription decription ///////////////////////////////////
  static String encryption({required final data}) {
    String encryptedData = data;
    try {
      final key = Key.fromUtf8("12345678912345678912345678912345");
      final iv = IV.fromLength(16);
      final encryptor = Encrypter(AES(key));
      final encryptedPassword = encryptor.encrypt(data, iv: iv);
      encryptedData = encryptedPassword.base64;
    } catch (_) {}
    return encryptedData;
  }

  static dynamic decryption({required final data}) {
    try {
      final key = Key.fromUtf8("12345678912345678912345678912345");
      final iv = IV.fromLength(16);
      final encryptor = Encrypter(AES(key));
      final decryptedPassword = encryptor.decrypt(Encrypted.from64(data), iv: iv);
      return decryptedPassword;
    } catch (_) {
      return "";
    }
  }

  static dynamic decryptionOfLastMessage({required final data}) {
    try {
      final key = Key.fromUtf8("12345678912345678912345678912345");
      final iv = IV.fromLength(16);
      final encryptor = Encrypter(AES(key));
      final decryptedPassword = encryptor.decrypt(Encrypted.from64(data), iv: iv);
      return decryptedPassword;
    } catch (_) {
      return data;
    }
  }

  static List<CubeMessage> decryptListOfMessages({required List<CubeMessage> messages}) {
    List<CubeMessage> decryptedMessages = [];
    for (var message in messages) {
      if (message.body != null) {
        message.body = EncryptData.decryptionOfLastMessage(data: message.body);
        decryptedMessages.add(message);
      }
    }
    return decryptedMessages;
  }
}
