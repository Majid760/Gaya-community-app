import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/logger.dart';

abstract class IPhoneMessage {
  Future<String> sendSMS({required String phone, required String message});

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToSentMessage({required String docId});

  Future<PermissionStatus> contactPermissionStatus();

  Future<List<Contact>> getAllContacts();

  Future<void> storeContacts(List<Contact> contacts);
}

class PhoneMessageServices implements IPhoneMessage {
  final twillioRef = FirebaseFirestore.instance.collection('twillioMessages');

  final _logger = MyLoggerServices.to;

  @override
  Future<String> sendSMS({required String phone, required String message}) async {
    _logger.print('Sending message to $phone');
    return (await twillioRef.add({'to': phone, 'body': message})).id;
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToSentMessage({required String docId}) {
    return twillioRef.doc(docId).snapshots();
  }

  /// Get permission status
  @override
  Future<PermissionStatus> contactPermissionStatus() async => await Permission.contacts.request();

  /// Get all contacts from device
  @override
  Future<List<Contact>> getAllContacts() async {
    _logger.print('Getting all contacts');
    final List<Contact> contacts = await FastContacts.getAllContacts();
    return contacts;
  }

  /// Store contacts into firestore as BatchWrite
  @override
  Future<void> storeContacts(List<Contact> contacts) async {
    if (contacts.isEmpty) return;
    _logger.print('Storing contacts');

    /// splitting and storing contacts
    await _splitAndStore(contacts: contacts);
  }

  ///configured for large items
  ///split into 500, then do batch store of contacts
  Future<void> _splitAndStore({required List<Contact> contacts}) async {
    _logger.print('Splitting and storing contacts ');
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      final totalDocsLength = contacts.length;

      /// if less than 499 then store as is
      if (totalDocsLength <= 499) {
        final ref =
            FirebaseFirestore.instance.collection('userContacts').doc(FirebaseAuth.instance.currentUser!.uid).collection('contacts');

        for (var contact in contacts) {
          print(contact.displayName);
          try {
            batch.set(ref.doc(contact.id), {
              contact.displayName: contact.phones.map((e) => {"number": e.number, "label": e.label}).toSet(),
              "email": contact.emails.map((e) => {"address": e.address, "label": e.label}).toSet(),
            });
          } catch (_) {
            debugPrint("Error in split and store $_");
          }
        }
        debugPrint("Batch commit for $totalDocsLength");
        await batch.commit();
        return;
      }

      /// split into 500 - 500 chunks
      final totalDocsSplit = totalDocsLength ~/ 499;
      final totalDocsRemainder = totalDocsLength % 499;
      final totalDocsSplitList = List.generate(totalDocsSplit, (index) => 499);

      final ref = FirebaseFirestore.instance.collection('userContacts').doc(FirebaseAuth.instance.currentUser!.uid);
      if (totalDocsRemainder > 0) {
        totalDocsSplitList.add(totalDocsRemainder);
      }

      for (int index in totalDocsSplitList) {
        batch = FirebaseFirestore.instance.batch();
        final contactChunk = contacts.sublist(0, index);
        for (var contact in contactChunk) {
          try {
            batch.set(ref, {"phone": contact.phones.map((e) => e.number).toList()});
          } catch (_) {
            debugPrint("Error in split and store $_");
          }
        }

        debugPrint("Batch commit for $index");
        await batch.commit();
      }
    } catch (_) {
      debugPrint("Error in split and store");
    }
  }
}
