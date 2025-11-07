import 'package:flutter/material.dart';
import 'package:gaya/utils/const.dart';
import 'package:pinput/pinput.dart';

import '../../../utils/textstyles.dart';

class PinInputField extends StatefulWidget {
  final int length;
  final void Function(bool)? onFocusChange;
  final void Function(String) onSubmit;
  final TextEditingController? controller;
  final String? phoneNumber;

  const PinInputField({
    Key? key,
    this.length = 6,
    this.onFocusChange,
    required this.onSubmit,
    this.controller,
    this.phoneNumber,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PinInputFieldState createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  late final TextEditingController _pinPutController;
  late final FocusNode _pinPutFocusNode;
  late final int _length;

  Size _findContainerSize(BuildContext context) {
    // full screen width
    double width = MediaQuery.sizeOf(context).width * 0.85;
    // using left-over space to get width of each container
    width /= _length;
    return Size.square(width);
  }

  @override
  void initState() {
    _pinPutController = TextEditingController();
    _pinPutFocusNode = FocusNode();
    if (widget.onFocusChange != null) {
      _pinPutFocusNode.addListener(() {
        widget.onFocusChange!(_pinPutFocusNode.hasFocus);
      });
    }
    _length = widget.length;
    super.initState();
  }

  @override
  void dispose() {
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    super.dispose();
  }

  PinTheme _getPinTheme(
    BuildContext context, {
    required Size size,
  }) {
    return PinTheme(
      height: size.height,
      width: size.width,
      textStyle: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        fontFamily: GayaFontTheme.primaryFont,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(7.5),
      ),
    );
  }

  static const _focusScaleFactor = 1.15;

  @override
  Widget build(BuildContext context) {
    final size = _findContainerSize(context);
    final defaultPinTheme = _getPinTheme(context, size: size);

    return SizedBox(
      height: size.height * _focusScaleFactor,
      child: Pinput(
        length: _length,
        controller: widget.controller,
        animationDuration: const Duration(milliseconds: 500),
        androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
        senderPhoneNumber: widget.phoneNumber,
        focusedPinTheme: defaultPinTheme.copyWith(
            height: size.height * _focusScaleFactor,
            width: size.width * _focusScaleFactor,
            decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: kprimaryColor))),
        defaultPinTheme: defaultPinTheme,
        // focusedPinTheme: defaultPinTheme.copyWith(
        //   height: size.height * _focusScaleFactor,
        //   width: size.width * _focusScaleFactor,
        //   decoration: defaultPinTheme.decoration!.copyWith(
        //     border: Border.all(color: Theme.of(context).colorScheme.secondary)
        //   ),
        // ),
        autofocus: true,
        // followingPinTheme: defaultPinTheme.copyWith(
        //   decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(8)),
        // ),
        errorPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(color: Theme.of(context).errorColor, borderRadius: BorderRadius.circular(8)),
        ),
        focusNode: _pinPutFocusNode,
        // controller: _pinPutController,
        onCompleted: widget.onSubmit,
        pinAnimationType: PinAnimationType.scale,
        // submittedFieldDecoration: _pinPutDecoration,
        // selectedFieldDecoration: _pinPutDecoration,
        // followingFieldDecoration: _pinPutDecoration,
        // textStyle: const TextStyle(
        //   color: Colors.black,
        //   fontSize: 20.0,
        //   fontWeight: FontWeight.w600,
        // ),
      ),
    );
  }
}
