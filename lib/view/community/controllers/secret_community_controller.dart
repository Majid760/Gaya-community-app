import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/controller/gaya_shared_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/service/dynamic_link_service/enums/dynamic_link_type.dart';
import 'package:gaya/shared/service/dynamic_link_service/model/gaya_social_tag.dart';
import 'package:gaya/shared/service/dynamic_link_service/utils/dynamic_link_utils.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../../shared/service/phone_message_services/phone_message_services.dart';
import '../../../shared/view/widget/gaya_snackbar.dart';
import '../../../utils/vallidation.dart';
import '../../Auth/constants/auth_constants.dart';

class SecretCommunityBindings extends Bindings {
  @override
  void dependencies() {
    final Community community = Get.arguments["community"] as Community;
    Get.lazyPut<SecretCommunityController>(() => SecretCommunityController(community: community));
  }
}

class SecretCommunityController extends GetxController {
  final Community community;

  SecretCommunityController({required this.community});

  /// * Phone message services
  late PhoneMessageServices _phoneMessageServices;
  late FormValidation validation;
  late TextEditingController phoneNumberC;
  late TextEditingController phoneCountryCodeC;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// once the message is sent, we will store the message id here
  /// so that we can listen to the message status
  String? sentMessageId;

  bool isInvitationSent = false;
  bool isValidated = false;
  bool isLoading = false;

  @override
  void onInit() async {
    super.onInit();
    phoneNumberC = TextEditingController();
    phoneCountryCodeC = TextEditingController(text: "+972");
    _phoneMessageServices = PhoneMessageServices();
    validation = FormValidation();
    print('SecretCommunityController: init called');
    await isFingerprintSupported();
  }

  void setLoading(bool value) {
    isLoading = value;
    update();
  }

  setIsValidated(bool value) {
    if (isValidated == value) return;
    isValidated = value;

    update();
  }

  setIsLoading(bool value) {
    if (isLoading == value) return;
    isLoading = value;

    update();
  }

  /// * Send invitation to phone
  Future<void> sendInvitationToPhone({required BuildContext context}) async {
    try {
      setIsLoading(true);
      final String? url = await _generateInvitationLink();
      if (url == null || url.isBlank == true) return;
      final String message =
          DynamicLinkConstants.inviteMessage(userName: UserModel.to.name ?? "", communityName: community.communityName ?? "", url: url);
      MyLoggerServices.to.print("Sending SMS to ${phoneCountryCodeC.text}${phoneNumberC.text} with message: $message");
      final phoneWithCountryCode = "${phoneCountryCodeC.text}${phoneNumberC.text}";
      sentMessageId = await _phoneMessageServices.sendSMS(phone: phoneWithCountryCode, message: message);
      isInvitationSent = true;

      GayaSnackBar.show(context: context, type: GayaSnackBarType.communities, text: AuthString.sentInvitation);
    } catch (e) {
      MyLoggerServices.to.print(e);
      isInvitationSent = false;
    }
    setIsLoading(false);
  }

  /// * Generate dynamic link for the community
  Future<String?> _generateInvitationLink() async {
    return await GayaSharedController.to.createAShareableLink(
      queryParam: community.queryParams,
      tag: DynamicLinkUtils.generateTagCommunity(community: community, isSecretCommunity: true),
      type: DynamicLinkType.communityInvite
    );
  }

// Secret community authentication part

  final LocalAuthentication auth = LocalAuthentication();
  SupportState supportState = SupportState.unknown;
  bool? canCheckBiometrics;
  List<BiometricType>? availableBiometrics;
  String authorized = 'Not Authorized';
  bool isAuthenticating = false;

// checking the fingerprint support in device
  Future<void> isFingerprintSupported() async {
    await auth.isDeviceSupported().then((bool isSupported) {
      supportState = isSupported ? SupportState.supported : SupportState.unsupported;
      setLoading(false);
    });
  }

//checking fingerprint status before going to secret community
  Future<SupportState> checkFingerprintStatus() async {
    print('checkFingerprintStatus: function called');
    await isFingerprintSupported();
    return supportState;
  }

// is device is capable of checking the fingerprint?
  Future<void> checkBiometrics(context) async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      canCheckBiometrics = false;
    }
    if (!context.mounted) {
      return;
    }
    this.canCheckBiometrics = canCheckBiometrics;
    setLoading(false);
  }

// get available device fingerprints
  Future<void> getAvailableBiometrics(context) async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
    }
    if (!context.mounted) {
      return;
    }
    this.availableBiometrics = availableBiometrics;
    setLoading(false);
  }

// cancel authentication process
  Future<void> cancelAuthentication() async {
    await auth.stopAuthentication();
    isAuthenticating = false;
    setLoading(false);
  }

// fingerprint authentication
  Future<String> authenticateWithBiometrics(context) async {
    debugPrint('authenticateWithBiometrics');

    bool authenticated = false;
    try {
      isAuthenticating = true;
      authorized = GayaStrings.authenticating.tr;
      setLoading(true);

      /// show loading dialog while authenticating
      showDialog(
          barrierColor: Colors.white.withOpacity(0.5),
          barrierDismissible: false,
          context: context,
          builder: (_) => Center(child: CircularProgressIndicator.adaptive(backgroundColor: AppColors.black)));

      authenticated = await auth.authenticate(
        localizedReason: GayaStrings.access_denied.tr,
        options: const AuthenticationOptions(stickyAuth: true),
      );



      isAuthenticating = false;
      authorized = GayaStrings.authenticating.tr;
      setLoading(false);
    } on PlatformException catch (e) {
      isAuthenticating = false;
      authorized = 'Error - ${e.message}';
      setLoading(false);
      return authorized;
    } finally{
      /// close the loading dialog
      Navigator.pop(context);
    }
    if (!context.mounted) {
      return authorized;
    }

      String message = authenticated ? GayaStrings.authorized.tr : GayaStrings.not_authorized.tr;

    // before making not authroized checking if any authentication is enabled for device
    // if so, then directly authenticate the user
    if(authenticated == false && (await auth.getAvailableBiometrics()).isEmpty){
      message = GayaStrings.authorized.tr;
    }
    authorized = message;
    setLoading(false);
    return authorized;
  }
}

enum SupportState {
  unknown,
  supported,
  unsupported,
}
