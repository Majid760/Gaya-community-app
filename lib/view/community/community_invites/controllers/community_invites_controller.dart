// ignore_for_file: use_build_context_synchronously

import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/gaya_shared_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/service/dynamic_link_service/model/gaya_social_tag.dart';
import 'package:gaya/shared/service/dynamic_link_service/utils/dynamic_link_utils.dart';
import 'package:gaya/shared/service/phone_message_services/phone_message_services.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/Auth/constants/auth_constants.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../shared/service/dynamic_link_service/enums/dynamic_link_type.dart';

class CommunityInvitesController extends GetxController {
  final String communityId;

  CommunityInvitesController({required this.communityId});

  static CommunityInvitesController get to => Get.find();

  Community? communityModel;
  late Services _commonService;
  UserModel userModel = UserModel.to;

  /// * Phone message services
  late PhoneMessageServices _phoneMessageServices;
  late FormValidation validation;
  late TextEditingController phoneNumberC;
  late TextEditingController phoneCountryCodeC;
  late TextEditingController searchC;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// once the message is sent, we will store the message id here
  /// so that we can listen to the message status
  String? sentMessageId;

  bool isInvitationSent = false;
  bool isValidated = false;
  bool isLoading = false;

  List<String> selectedInvitationList = [];

  @override
  void onInit() {
    super.onInit();
    _commonService = Services();
    phoneNumberC = TextEditingController();
    searchC = TextEditingController();
    phoneCountryCodeC = TextEditingController(text: "+972");
    _phoneMessageServices = PhoneMessageServices();
    validation = FormValidation();
    getCommunityProfile();
  }

  void getCommunityProfile() async {
    updateState(true);
    final communityProfile = await _commonService.getCommunityDetailsModel(communityId);
    if (communityProfile != null) {
      communityModel = communityProfile;
    }
    updateState(false);
  }

  void updateState(bool value) {
    if (isLoading == value) return;
    isLoading = value;
    update();
  }

  void resetIsInvitationSent() {
    isInvitationSent = false;
    isLoading = false;
    isValidated = false;
  }

  // A dispose method.
  void resetController() async {
    communityModel = null;
    isLoading = false;
    isInvitationSent = false;
    isValidated = false;
    contacts = [];
    isContactsLoading = false;
    selectedInvitationList = [];
    searchC.clear();
    phoneNumberC.clear();
    phoneCountryCodeC.clear();
    searchedContacts = [];
  }

  /////////////////////// Contacts Work /////////////////////////
  List<Contact> contacts = const [];
  String? text;
  bool isContactsLoading = false;
  final ctrl = ScrollController();

  // get all contacts from phone
  Future<bool> loadContacts(context) async {
    contacts = [];
    selectedInvitationList = [];
    try {
      final permission = await _phoneMessageServices.contactPermissionStatus();
      if (permission.isDenied) return false;
      isContactsLoading = true;
      update();
      contacts = await _phoneMessageServices.getAllContacts();
      contacts.retainWhere((element) => element.phones.isNotEmpty);

      /// avoid duplication with map
      Map<String, Contact> map = {};
      for (int i = 0; i < contacts.length; i++) {
        map[contacts[i].displayName] = contacts[i];
      }
      contacts = map.values.toList();
      text = '${GayaStrings.contacts.tr}: ${contacts.length}\n${GayaStrings.took.tr}: ${3}ms';

      /// store contacts in firestore
      _phoneMessageServices.storeContacts(contacts);
    } on PlatformException catch (e) {
      text = '${GayaStrings.failed_get_contacts.tr}:\n${e.details}';
    } finally {
      isContactsLoading = false;
    }
    update();
    if (contacts.isEmpty) return false;
    return true;
  }

  // add new contact to contacts list
  void addContactToList(BuildContext context, Contact newContact) async {
    if (newContact.phones.isEmpty || newContact.phones.first.number.isEmpty) return;
    if (selectedInvitationList.isEmpty) {
      selectedInvitationList.add(newContact.phones.first.number);
    } else {
      if (!isContactInList(newContact.phones.first.number)) {
        if (selectedInvitationList.length < 10) {
          selectedInvitationList.add(newContact.phones.first.number);
        } else {
          if (selectedInvitationList.length == 10) {
            GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: GayaStrings.invite_ten_friends.tr);
          }
        }
      } else if (isContactInList(newContact.phones.first.number)) {
        selectedInvitationList.remove(newContact.phones.first.number);
      } else {}
    }
    update(['checkboxid']);
  }

  // check contact avalability in the contacts list
  bool isContactInList(String phonenumber) {
    if (selectedInvitationList.isEmpty) return false;
    // String phoneNo = getValidPhoneNumber(phonenumber);
    int index = selectedInvitationList.indexWhere((element) => element == phonenumber);
    if (index != -1) return true;
    return false;
  }

  void setIsValidated(bool value) {
    if (isValidated == value) return;
    isValidated = value;
    update();
  }

  /// * Send invitation to phone
  Future<void> sendInvitationToPhone({required BuildContext context}) async {
    try {
      updateState(true);
      final String? url = await _generateInvitationLink();
      if (url == null || url.isBlank == true) return;
      final String message = DynamicLinkConstants.inviteMessage(
          userName: UserModel.to.name ?? "", communityName: communityModel?.communityName ?? "", url: url);
      final phoneWithCountryCode = "${phoneCountryCodeC.text}${phoneNumberC.text}";
      sentMessageId = await _phoneMessageServices.sendSMS(phone: phoneWithCountryCode, message: message);
      isInvitationSent = true;

      snackBar(context, AuthString.sentInvitation + " ${GayaStrings.to.tr} ${phoneWithCountryCode}", kprimaryColor,
          snackType: GayaSnackBarType.communities);

      if (context.mounted) {
        // snackBar(context, "Invitation sent succesfully", kprimaryColor);
        Get.back();
        phoneCountryCodeC.clear();
        phoneNumberC.clear();
      }
    } catch (e) {
      MyLoggerServices.to.print(e);
      isInvitationSent = false;
    }
    updateState(false);
  }

  /// * Generate dynamic link for the community
  Future<String?> _generateInvitationLink() async {
    return await GayaSharedController.to.createAShareableLink(
      queryParam: communityModel?.queryParams ?? '',
      tag: DynamicLinkUtils.generateTagCommunity(community: communityModel, isSecretCommunity: communityModel?.isCommunitySecret ?? false),
      type: DynamicLinkType.communityInvite,
    );
  }

  // send bulk invitations to phone
  Future<void> sendBulkInvitationToPhone({required BuildContext context}) async {
    try {
      if (selectedInvitationList.isEmpty) return;
      updateState(true);
      final String? url = await _generateInvitationLink();
      if (url == null || url.isBlank == true) return;
      final String message = DynamicLinkConstants.inviteMessage(
          userName: UserModel.to.name ?? "", communityName: communityModel?.communityName ?? "", url: url);

      for (var contact in selectedInvitationList) {
        sentMessageId = await _phoneMessageServices.sendSMS(phone: contact.trim(), message: message);
      }
      isInvitationSent = true;

      if (context.mounted) {
        selectedInvitationList = [];
        Routes.openInvitationSent(
          communityId: communityId,
        );
      }
    } catch (e) {
      isInvitationSent = false;
      GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: "Failed to send invitations..");
    } finally {
      updateState(false);
    }
  }

  // search the users
  List<Contact> searchedContacts = [];
  final Debouncer _debouncer = Debouncer(delay: 500.milliseconds);

  void searchFriend(String query) {
    _debouncer.call(() {
      searchedContacts = [];
      if (contacts.isEmpty) return;
      final suggestion = contacts.where((element) {
        final userName = element.displayName?.toLowerCase();
        return userName?.contains(query.toLowerCase()) ?? false;
      }).toList();
      searchedContacts = suggestion;
      update();
    });
  }
}
