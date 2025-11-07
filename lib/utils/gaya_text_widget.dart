import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get.dart';

import 'logger.dart';
import 'methods.dart';

enum TrimMode { length, line }

RegExp asterisksExp = RegExp(r"\*(.*?)\*");
RegExp rtlExp = RegExp(r'[\u0590-\u08FF]');
RegExp linkExp = RegExp(
    r"(https?|ftp|file)://[-A-Za-z\d+&@#/%?=~_|!:,.;]+[-A-Za-z\d+&@#/%=~_|]|(www\.[-A-Za-z\d+&@#/%?=~_|!:,.;]+[-A-Za-z\d+&@#/%=~_|])",
    unicode: true,
    caseSensitive: false);
RegExp hashTagExp = RegExp(r"#(\w+)");
RegExp mentionedExp = RegExp(r'\B@\w+');

bool isRtl(String text) => rtlExp.hasMatch(text);

class GayaTextWidget extends StatefulWidget {
  /// Returns true if the text is longer than the trimLength 240
  static bool canReadMore(String content) {
    MyLoggerServices.to.print("This is our content length ${content.length}");
    return content.toString().length >= 180;
  }

  const GayaTextWidget(
    this.data, {
    Key? key,
    this.preDataText,
    this.postDataText,
    this.preDataTextStyle,
    this.postDataTextStyle,
    this.trimExpandedText = ' Read less',
    this.trimCollapsedText = ' Read more',
    this.colorClickableText,
    this.trimLength = 180,
    this.trimLines = 5,
    this.trimMode = TrimMode.length,
    this.style,
    this.locale,
    this.textScaleFactor,
    this.semanticsLabel,
    this.moreStyle,
    this.lessStyle,
    this.delimiter = '$_kEllipsis ',
    this.delimiterStyle,
    this.callback,
    this.onLinkPressed,
    this.linkTextStyle,
    this.asterisksStyle,
    this.shouldIgnoreSelectableText = false,
    this.hashTagStyle,
    this.community,
    this.onHashTagPressed,
    this.shouldIgnoreHashTag = true,
    this.isReadMore = true,
    this.mentionedUsers,
    this.onReadMoreButtonTap,
    this.isEllipsis = false,
  }) : super(key: key);

  /// Used on TrimMode.Length
  final int trimLength;

  // community id in case of hashtag click navigation to group
  final Community? community;

  /// Used on TrimMode.Lines
  final int trimLines;

  /// Determines the type of trim. TrimMode.Length takes into account
  /// the number of letters, while TrimMode.Lines takes into account
  /// the number of lines
  final TrimMode trimMode;

  /// TextStyle for expanded text
  final TextStyle? moreStyle;

  /// TextStyle for compressed text
  final TextStyle? lessStyle;

  /// Text-span used before the data any heading or something
  final String? preDataText;

  /// Text-span used after the data end or before the more/less
  final String? postDataText;

  /// Text-span used before the data any heading or something
  final TextStyle? preDataTextStyle;

  /// Text-span used after the data end or before the more/less
  final TextStyle? postDataTextStyle;

  ///Called when state change between expanded/compress
  final Function(bool val)? callback;

  final ValueChanged<String>? onLinkPressed;

  final TextStyle? linkTextStyle;

  final TextStyle? hashTagStyle;

  final String delimiter;
  final String? data;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final TextStyle? style;
  final TextStyle? asterisksStyle;
  final Locale? locale;
  final double? textScaleFactor;
  final String? semanticsLabel;
  final TextStyle? delimiterStyle;
  final bool shouldIgnoreSelectableText;
  final bool shouldIgnoreHashTag;
  final bool isReadMore;

  final bool isEllipsis;

  /// Called when hash tag is pressed
  final Function(String?)? onHashTagPressed;
  final List<Map<String, dynamic>>? mentionedUsers;

  /// call back for read more button (custom read more functionality)
  final VoidCallback? onReadMoreButtonTap;

  @override
  GayaTextWidgetState createState() => GayaTextWidgetState();
}

const String _kEllipsis = '\u2026';

const String _kLineSeparator = '\u2028';

class GayaTextWidgetState extends State<GayaTextWidget> {
  late TextDirection textDirection;
  late TextAlign textAlign;

  @override
  void initState() {
    super.initState();
    _readMore = widget.isReadMore;
  }

  bool _readMore = true;

  void _onTapLink() {
    // calling our version of onReadMoreButtonTap if it is not null
    if (widget.onReadMoreButtonTap != null) {
      widget.onReadMoreButtonTap!();
      return;
    }
    setState(() {
      _readMore = !_readMore;
      widget.callback?.call(_readMore);
    });
  }

  // void _onTap-hashTagCustom(String hashTag) async {
  //   if (widget.community == null || FirebaseAuth.instance.currentUser == null) return;
  //   String tag = hashTag.split('#').last.split(':').last.trim();
  //   Get.lazyPut<CommunityFeedController>(
  //       () => CommunityFeedController(communityId: widget.community?.communityId ?? '', community: widget.community, hashTagTopic: tag));
  //   String currentRoute = Get.currentRoute;
  //   Get.find<CommunityFeedController>().setSelectedTopic(tag);
  //   if (currentRoute == '/GroupView' || currentRoute == '') {
  //     Get.find<CommunityFeedController>().setSelectedTopic(tag);
  //   } else {
  //     Methods.routeToGroup(community: widget.community!);
  //   }
  // }
  void _onTaphashTag(String hashtag) {
    widget.onHashTagPressed?.call(hashtag);
  }

  @override
  Widget build(BuildContext context) {
    /// to avoid red screen of death
    if (widget.data?.trim() == "" || widget.data == null) return const Text("");

    final bool isRtl = Methods.isRTL(widget.data ?? "");

    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style;
    if (widget.style?.inherit ?? false) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;
    textAlign = isRtl ? TextAlign.right : TextAlign.left;
    final textScaleFactor = widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);
    final overflow = defaultTextStyle.overflow;
    var locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final colorClickableText = widget.colorClickableText ?? Theme.of(context).colorScheme.secondary;
    final defaultLessStyle = widget.lessStyle ?? effectiveTextStyle?.copyWith(color: colorClickableText);
    final defaultMoreStyle = widget.moreStyle ?? effectiveTextStyle?.copyWith(color: colorClickableText);
    var defaultDelimiterStyle = widget.delimiterStyle ?? effectiveTextStyle;

    final TextSpan link = TextSpan(
      text: widget.isEllipsis
          ? ""
          : (_readMore
                  ? widget.trimCollapsedText == ' Read more'
                      ? GayaStrings.read_more
                      : widget.trimCollapsedText
                  : widget.trimExpandedText == ' Read less'
                      ? GayaStrings.read_less
                      : widget.trimExpandedText)
              .tr,
      style: widget.isEllipsis
          ? widget.style
          : _readMore
              ? defaultMoreStyle
              : defaultLessStyle,
      recognizer: widget.isEllipsis ? null : TapGestureRecognizer()
        ?..onTap = _onTapLink,
    );

    TextSpan delimiter = TextSpan(
      text: _readMore
          ? widget.trimCollapsedText.isNotEmpty
              ? widget.delimiter
              : ''
          : '',
      style: defaultDelimiterStyle,
      recognizer: widget.isEllipsis ? null : TapGestureRecognizer()
        ?..onTap = _onTapLink,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;
        TextSpan? preTextSpan;
        TextSpan? postTextSpan;
        if (widget.preDataText != null) {
          preTextSpan = TextSpan(
            text: "${widget.preDataText!} ",
            style: widget.preDataTextStyle ?? effectiveTextStyle,
          );
        }
        if (widget.postDataText != null) {
          postTextSpan = TextSpan(
            text: " ${widget.postDataText!}",
            style: widget.postDataTextStyle ?? effectiveTextStyle,
          );
        }

        // Create a TextSpan with data
        final text = TextSpan(
          children: [
            if (preTextSpan != null) preTextSpan,
            TextSpan(text: widget.data, style: effectiveTextStyle),
            if (postTextSpan != null) postTextSpan
          ],
        );

        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          //maxLines: widget.trimLines,
          ellipsis: overflow == TextOverflow.ellipsis ? widget.delimiter : null,
          locale: locale,
        );
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        // Layout and measure delimiter
        textPainter.text = delimiter;
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final delimiterSize = textPainter.size;

        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        // Get the endIndex of data
        bool linkLongerThanLine = false;
        int endIndex;

        if (linkSize.width < maxWidth) {
          final readMoreSize = linkSize.width + delimiterSize.width;
          final pos = textPainter.getPositionForOffset(Offset(
            textDirection == TextDirection.rtl ? readMoreSize : textSize.width - readMoreSize,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        } else {
          var pos = textPainter.getPositionForOffset(
            textSize.bottomLeft(Offset.zero),
          );
          endIndex = pos.offset;
          linkLongerThanLine = true;
        }

        TextSpan textSpan;
        switch (widget.trimMode) {
          case TrimMode.length:
            if (widget.trimLength < widget.data!.length) {
              textSpan = _buildData(
                context: context,
                data: _readMore ? widget.data!.substring(0, widget.trimLength) : widget.data!,
                textStyle: effectiveTextStyle,
                linkTextStyle: widget.linkTextStyle ?? CustomTypography.linkStyle,
                onPressed: widget.onLinkPressed,
                children: [delimiter, link],
              );
            } else {
              textSpan = _buildData(
                  context: context,
                  data: widget.data!,
                  textStyle: effectiveTextStyle,
                  linkTextStyle: widget.linkTextStyle ?? CustomTypography.linkStyle,
                  onPressed: widget.onLinkPressed,
                  children: []);
            }
            break;
          case TrimMode.line:
            if (textPainter.didExceedMaxLines) {
              textSpan = _buildData(
                  context: context,
                  data: _readMore ? widget.data!.substring(0, endIndex) + (linkLongerThanLine ? _kLineSeparator : '') : widget.data!,
                  textStyle: effectiveTextStyle,
                  linkTextStyle: widget.linkTextStyle ?? CustomTypography.linkStyle,
                  onPressed: widget.onLinkPressed,
                  children: [delimiter, link]);
            } else {
              textSpan = _buildData(
                  context: context,
                  data: widget.data!,
                  textStyle: effectiveTextStyle,
                  linkTextStyle: widget.linkTextStyle ?? CustomTypography.linkStyle,
                  onPressed: widget.onLinkPressed,
                  children: []);
            }
            break;
          default:
            throw Exception('TrimMode type: ${widget.trimMode} is not supported');
        }

        return widget.shouldIgnoreSelectableText
            ? RichText(
                text: TextSpan(
                  children: [
                    if (preTextSpan != null) preTextSpan,
                    textSpan,
                    if (postTextSpan != null) postTextSpan,
                  ],
                ),
                textAlign: textAlign,
                textDirection: textDirection,
                textScaleFactor: textScaleFactor)
            : SelectableText.rich(
                TextSpan(
                  children: [
                    if (preTextSpan != null) preTextSpan,
                    textSpan,
                    if (postTextSpan != null) postTextSpan,
                  ],
                ),
                textAlign: textAlign,
                textDirection: textDirection,
                textScaleFactor: textScaleFactor);
      },
    );
    if (widget.semanticsLabel != null) {
      result = Semantics(textDirection: textDirection, label: widget.semanticsLabel, child: ExcludeSemantics(child: result));
    }
    return result;
  }

  TextSpan _buildData(
      {required String data,
      TextStyle? textStyle,
      TextStyle? linkTextStyle,
      ValueChanged<String>? onPressed,
      required List<TextSpan> children,
      required BuildContext context}) {
    List<TextSpan> contents = [];

    //detects if it have asteric and make it bold.
    while (asterisksExp.hasMatch(data)) {
      final match = asterisksExp.firstMatch(data);
      final firstTextPart = data.substring(0, match!.start);
      final asteriskText = data.substring(match.start, match.end);
      contents.add(
        TextSpan(text: firstTextPart),
      );
      contents.add(
        TextSpan(
          text: asteriskText.replaceAll("*", ""),
          style: widget.asterisksStyle ?? widget.style?.copyWith(fontWeight: FontWeight.w600),
        ),
      );
      data = data.substring(match.end, data.length);
    }

    // detects the at@

    if (widget.mentionedUsers?.isNotEmpty ?? false) {
      // int index = 0;
      mentionedExp = RegExp(r'\s*\B@\S+\b');
      while (mentionedExp.hasMatch(data)) {
        final match = mentionedExp.firstMatch(data);
        String firstTextPart = data.substring(0, match!.start);
        String atTheRateTextPart = data.substring(match.start, match.end).replaceAll('@', '');
        var checkMentions =
            widget.mentionedUsers?.firstWhereOrNull((element) => element['id'].toString().trim() == atTheRateTextPart.toString().trim());

        contents.add(TextSpan(text: firstTextPart));

        contents.add(TextSpan(
          text: (widget.mentionedUsers != null &&
                  widget.mentionedUsers!.isNotEmpty &&
                  checkMentions?['id'].toString().trim() == atTheRateTextPart.trim())
              ? " ${checkMentions?['display']}"
              : atTheRateTextPart,
          style: checkMentions?['id'].toString().trim() == atTheRateTextPart.trim() ? CustomTypography.atTheRateTagStyle : textStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final element = widget.mentionedUsers
                  ?.firstWhereOrNull((element) => element['id'].toString().trim() == atTheRateTextPart.toString().trim()
                      //     ||
                      // element['display'].toString().split(" ").first ==
                      //     atTheRateTextPart.substring(1).replaceFirst("@", ""),
                      );

              if (element?["isCommunity"] == true) {
                return Routes.groupView(community: Community(communityId: element?["id"]));
              }
              if (element != null && element['senderUid'] != null && element['senderUid'].toString().isNotEmpty) {
                if (element['isCommunity'] != null && element['isCommunity']) {
                  Routes.groupView(community: Community(communityId: element['id']));
                } else {
                  Routes.viewProfile(uid: element['senderUid'], model: UserModel(uId: element['senderUid']));
                }
              }
            },
        ));

        try {
          final String withOut = (widget.mentionedUsers?[0]['id'] ?? '').split(" ").first;
          String nameWithOutFirst = (widget.mentionedUsers?[0]['id'] ?? '').replaceFirst(withOut, "");

          // data = data.substring(match.end, data.length) == nameWithOutFirst ? "" : data.substring(match.end, data.length);
          data = data.substring(match.end, data.length).replaceFirst(nameWithOutFirst, "");
        } catch (_) {
          data = data.substring(match.end, data.length);
        }
        // index++;
      }
    }

    // detects the hashTag
    if (widget.shouldIgnoreHashTag == false) {
      while (hashTagExp.hasMatch(data)) {
        final match = hashTagExp.firstMatch(data);
        final firstTextPart = data.substring(0, match!.start);
        final hashTagTextPart = data.substring(match.start, match.end);
        contents.add(TextSpan(text: firstTextPart));
        contents.add(
          TextSpan(
            text: hashTagTextPart,
            style: widget.hashTagStyle ?? CustomTypography.hashTagStyle,
            recognizer: TapGestureRecognizer()..onTap = () => _onTaphashTag(hashTagTextPart),
          ),
        );
        data = data.substring(match.end, data.length);
      }
    }

    //detects the link
    while (linkExp.hasMatch(data)) {
      final match = linkExp.firstMatch(data);
      final firstTextPart = data.substring(0, match!.start);
      final linkTextPart = data.substring(match.start, match.end);
      contents.add(
        TextSpan(text: firstTextPart),
      );
      contents.add(
        TextSpan(
          text: linkTextPart,
          style: widget.linkTextStyle ?? CustomTypography.linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              Methods.launchMyUrl(linkTextPart, context: context);
            },
        ),
      );
      data = data.substring(match.end, data.length);
    }

    contents.add(TextSpan(text: data));
    return TextSpan(children: contents..addAll(children), style: textStyle);
  }

  List<InlineSpan> buildMentionSpans(String text) {
    List<InlineSpan> spans = [];
    RegExp pattern = RegExp(r'@(\[[^\]]+\])\(([^)]+)\)');
    int lastIndex = 0;

    for (RegExpMatch match in pattern.allMatches(text)) {
      spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      spans.add(TextSpan(
        text: match.group(2),
        style: const TextStyle(color: Colors.blue),
        recognizer: TapGestureRecognizer()..onTap = () {},
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }
}
