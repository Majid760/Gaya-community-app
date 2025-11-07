import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/language/translation.dart';
import '../../../../utils/textstyles.dart';

enum SearchMode {
  onEdit,
  onSubmit,
}

enum SearchTextPosition {
  top,
  bottom,
}

class SearchTextField extends StatelessWidget {
  final FocusNode? focusNode;
  final bool searchFieldEnabled;
  final InputDecoration? inputDecoration;
  final TextEditingController? searchTextController;
  final TextInputAction keyboardAction;
  final TextInputType textInputType;
  final bool obscureText;
  final SearchMode searchMode;
  final Function(String) filterList;
  final Function(String)? onSubmitSearch;
  final bool displayClearIcon;
  final Color defaultSuffixIconColor;
  final TextStyle? textStyle;
  final Color? cursorColor;
  final int? maxLines;
  final int? maxLength;
  final TextAlign textAlign;
  final List<String> autoCompleteHints;
  final bool autoFocus;
  final Widget? secondaryWidget;

  const SearchTextField({
    Key? key,
    required this.filterList,
    required this.focusNode,
    required this.inputDecoration,
    required this.keyboardAction,
    required this.obscureText,
    required this.onSubmitSearch,
    required this.searchFieldEnabled,
    required this.searchMode,
    required this.searchTextController,
    required this.textInputType,
    required this.displayClearIcon,
    required this.defaultSuffixIconColor,
    required this.textStyle,
    required this.cursorColor,
    required this.maxLines,
    required this.maxLength,
    required this.textAlign,
    required this.autoCompleteHints,
    required this.autoFocus,
    this.secondaryWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: autoCompleteHints.isNotEmpty
                ? Autocomplete(
                    optionsBuilder: (textEditingValue) {
                      return autoCompleteHints;
                    },
                    onSelected: (option) {
                      filterList(option.toString());
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    fieldViewBuilder: (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15).r,
                        child: CupertinoSearchTextField(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6).r,
                          // cursorColor: cursorColor,
                          placeholder: GayaStrings.search_hint.tr,
                          style: const TextStyle(color: Colors.black, fontFamily: GayaFontTheme.primaryFont),
                          controller: searchTextController,
                          keyboardType: textInputType,
                          onSubmitted: (value) {
                            onSubmitSearch?.call(value);
                            if (searchMode == SearchMode.onSubmit) {
                              filterList(value);
                            }
                          },
                          onChanged: (value) {
                            if (searchMode == SearchMode.onEdit) {
                              filterList(value);
                            }
                          },
                        ),
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15).r,
                    child: CupertinoSearchTextField(
                      // cursorColor: cursorColor,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6).r,
                      placeholder: GayaStrings.search_hint.tr,
                      style: const TextStyle(color: Colors.black, fontFamily: GayaFontTheme.primaryFont),
                      controller: searchTextController,
                      keyboardType: textInputType,
                      onSubmitted: (value) {
                        onSubmitSearch?.call(value);
                        if (searchMode == SearchMode.onSubmit) {
                          filterList(value);
                        }
                      },
                      onChanged: (value) {
                        if (searchMode == SearchMode.onEdit) {
                          filterList(value);
                        }
                      },
                    ),
                  )),
      ],
    );
  }
}
