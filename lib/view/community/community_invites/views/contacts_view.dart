import 'dart:async';

import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/view/community/community_invites/components/contact_item_widget.dart';
import 'package:gaya/view/community/community_invites/controllers/community_invites_controller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  final CommunityInvitesController communityInvitesController = Get.find();
  List<Contact> _contacts = const [];
  String? _text;
  bool _isLoading = false;
  final _ctrl = ScrollController();

  Future<void> loadContacts() async {
    try {
      await Permission.contacts.request();
      _isLoading = true;
      if (mounted) setState(() {});
      final sw = Stopwatch()..start();
      _contacts = await FastContacts.getAllContacts();
      sw.stop();
      _text = 'Contacts: ${_contacts.length}\nTook: ${sw.elapsedMilliseconds}ms';
    } on PlatformException catch (e) {
      _text = 'Failed to get contacts:\n${e.details}';
    } finally {
      _isLoading = false;
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    communityInvitesController.loadContacts(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
          trackVisibility: MaterialStateProperty.all(true),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title:  Text(GayaStrings.fast_contact.tr),
          actions: [
            GestureDetector(
              onTap: () {
                // print(getInitials('Ben Bright'));
              },
              child: Text(GayaStrings.call_txt.tr),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: loadContacts,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.refresh),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(GayaStrings.load_contact.tr),
                ],
              ),
            ),
            Text(_text ?? GayaStrings.tap_load_contact.tr, textAlign: TextAlign.center),
            Expanded(
              child: ListView.builder(
                controller: _ctrl,
                itemCount: _contacts.length,
                itemExtent: ContactItem.height,
                itemBuilder: (_, index) => ContactItem(contact: _contacts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






