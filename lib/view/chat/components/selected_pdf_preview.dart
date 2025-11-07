import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/shared/view/widget/pdf_detail_screen.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:get/get.dart';

class SelectedPDFPreview extends StatefulWidget {
  final String path;
  final String chatDialogId;
  final double? height;
  final double? width;
  final VoidCallback? tapOnImageRemove;

  const SelectedPDFPreview({
    Key? key,
    required this.path,
    this.height,
    this.width,
    this.tapOnImageRemove,
    required this.chatDialogId,
  }) : super(key: key);

  @override
  State<SelectedPDFPreview> createState() => _SelectedPDFPreviewState();
}

class _SelectedPDFPreviewState extends State<SelectedPDFPreview> {
  late ConversationController conversationController;
  @override
  void initState() {
    super.initState();
    conversationController = ConversationController.to(widget.chatDialogId);
    generateThumbnail();
  }

  // final chatController = ChatController.to();

  generateThumbnail() async {
    conversationController.generatePdfThumbnail(url: widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(
      init: conversationController,
      tag: widget.chatDialogId,
      builder: (controller) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: EdgeInsets.only(top: 15.h),
              // height: 117.h,
              width: widget.width ?? 353.w,
              decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(12).r),
              child: InkWell(
                  onTap: () async {
                    final path = widget.path;
                    print('File name is: ${widget.path.split("/").last}');

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PdfDetailScreen(
                                  path: path,
                                )));

                    // _openPdf(context, path);
                  },
                  child: Column(
                    children: [
                      controller.pdfThumbnail != null
                          ? SizedBox(
                              height: 64.h,
                              width: MediaQuery.sizeOf(context).width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0.r), topRight: Radius.circular(12.0.r)),
                                child: Image.memory(controller.pdfThumbnail!, fit: BoxFit.cover),
                              ))
                          : Center(
                              child: CircularProgressIndicator.adaptive(
                              backgroundColor: AppColors.primary,
                            )),
                      const Divider(
                        height: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                        child: SizedBox(
                          height: 35.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GayaSvgAsset(
                                'Assets/images/doc.svg',
                                height: 30.h,
                                width: 25.w,
                                color: AppColors.black,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.path.split('/').last.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GayaTypography.captionMedium.copyWith(color: MyColorHex().blackShade2)),
                                    if (controller.documentTextField.text.isNotEmpty)
                                      Text(controller.documentTextField.text.toString(),
                                          maxLines: 1, overflow: TextOverflow.ellipsis, style: GayaTypography.subtitleMedium)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            ),
            Positioned(
              top: 5.h,
              right: -5.w,
              child: InkWell(
                onTap: widget.tapOnImageRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: kBaseGrey, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.black, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
