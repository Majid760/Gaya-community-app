import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SelectLinkWidget extends StatefulWidget {
  final String data;
  final TextStyle? style;
  final VoidCallback? onTap;

  const SelectLinkWidget({
    Key? key,
    required this.data,
    this.style,
    this.onTap,
  }) : super(key: key);

  @override
  State<SelectLinkWidget> createState() => _SelectLinkWidgetState();
}

class _SelectLinkWidgetState extends State<SelectLinkWidget> {
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = widget.onTap;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        text: widget.data,
        style: widget.style,
        recognizer: _tapGestureRecognizer,
      ),
    );
  }
}
