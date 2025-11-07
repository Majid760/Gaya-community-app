//button
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';

class PdfDetailScreen extends StatefulWidget {
  final String path;
  final bool? isHttpPath;
  const PdfDetailScreen({Key? key, required this.path, this.isHttpPath = false}) : super(key: key);

  @override
  State<PdfDetailScreen> createState() => _PdfDetailScreenState();
}

class _PdfDetailScreenState extends State<PdfDetailScreen> {
  int? pages = 0;

  int? currentPage = 0;

  bool isReady = false;

  String errorMessage = '';

  bool isLoading = false;

  final Completer<PDFViewController> _controller = Completer<PDFViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        iconTheme: const IconThemeData(color: kBlackColor),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: PDFView(
        filePath: widget.path,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false, // if set to true the link is handled in flutter
        onRender: (pages) {
          print('onRender');
          // setState(() {
          //   pages = pages;
          //   isReady = true;
          // });
        },
        onError: (error) {
          setState(() {
            errorMessage = error.toString();
          });
          print(error.toString());
        },
        onPageError: (page, error) {
          setState(() {
            errorMessage = '$page: ${error.toString()}';
          });
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          print('onViewCreated');
          // _controller.complete(pdfViewController);
        },
        onLinkHandler: (String? uri) {
          print('goto uri: $uri');
        },
        onPageChanged: (int? page, int? total) {
          // print('page change: $page/$total');
          // setState(() {
          //   currentPage = page;
          // });
        },
      ),
    );
  }
}
