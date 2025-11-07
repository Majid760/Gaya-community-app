import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/shared/view/widget/pdf_detail_screen.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/chat/components/text_link_widget.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:get/get.dart';

class NetworkPDFView extends StatefulWidget {
  final String path;
  final String? title;
  final String? filename;
  final String? thumbnailUrl;
  final double? width;
  final String chatDialogId;
  String sentTime = '';
  String deliveryStatus = '';
  bool mySelf = false;

  NetworkPDFView(
      {Key? key,
      required this.path,
      this.title,
      required this.filename,
      this.thumbnailUrl,
      this.width,
      required this.chatDialogId,
      required this.sentTime,
      required this.deliveryStatus,
      required this.mySelf})
      : super(key: key);

  @override
  State<NetworkPDFView> createState() => _NetworkPDFViewState();
}

class _NetworkPDFViewState extends State<NetworkPDFView> {
  @override
  void initState() {
    super.initState();
    // generateThumbnail();
  }

  bool isDownloading = false;

  Future<void> _onTap(ConversationController controller) async {
    setState(() {
      isDownloading = true;
    });
    try {
      final path = await controller.downloadAndCachePdf(url: widget.path);
      print('File name is: $path');
      if (path.isBlank == true) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => PdfDetailScreen(path: path)));
      isDownloading = false;
    } catch (_) {}
    setState(() {
      isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationController = ConversationController.to(widget.chatDialogId);

    return GetBuilder<ConversationController>(
      init: conversationController,
      tag: widget.chatDialogId,
      builder: (controller) {
        return Stack(
          children: [
            Container(
              // height: 117.h,
              width: widget.width ?? 353.w,
              decoration: BoxDecoration(
                  color: AppColors.white, border: Border.all(color: AppColors.secondary4), borderRadius: BorderRadius.circular(12).r),
              child: InkWell(
                  onTap: isDownloading ? null : () => _onTap(controller),
                  child: Column(
                    children: [
                      // (widget.isHttpPath == true)
                      //     ?
                      widget.thumbnailUrl != null
                          ? SizedBox(
                              height: 64.h,
                              width: MediaQuery.sizeOf(context).width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0.r), topRight: Radius.circular(12.0.r)),
                                child: Image.network(
                                  widget.thumbnailUrl!.replaceAll('%2F', '/').replaceAll('%3A', ':'),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return AppData.defaultGreySimpleImage;
                                  },
                                ),
                                // Image.memory(pdfThumbnail!, fit: BoxFit.cover),
                              ))
                          : SizedBox(
                              height: 64.h,
                              child: const Center(
                                child: AppData.defaultGreySimpleImage,
                              ),
                            ),
                      // : Image.file(File(widget.path)),

                      Divider(height: 1, color: AppColors.secondary4),
                      Padding(
                        padding: EdgeInsets.only(top: 10.h, left: 14.w, right: 14.w),
                        child: SizedBox(
                          height: 35.h,
                          child: Row(
                            children: [
                              GayaSvgAsset('Assets/images/doc.svg', height: 30.h, width: 25.w, color: AppColors.black),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.filename ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GayaTypography.captionMedium.copyWith(color: MyColorHex().blackShade2)),
                                          if (widget.title != null)
                                            Text(widget.title.toString(),
                                                maxLines: 1, overflow: TextOverflow.ellipsis, style: GayaTypography.subtitleMedium)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h, left: 4.w, right: 4.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              widget.sentTime,
                              style: TextStyle(color: AppColors.secondary2, fontSize: 10.0.sp, fontStyle: FontStyle.italic),
                            ),
                            (widget.mySelf)
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 4.r,
                                      ),
                                      getReadDeliveredWidget(widget.deliveryStatus),
                                    ],
                                  )
                                : const SizedBox.shrink()
                          ],
                        ),
                      )
                    ],
                  )),
            ),
            if (isDownloading) Positioned(left: 0, right: 0, top: 30.h, child: const CupertinoActivityIndicator())
          ],
        );
      },
    );
  }
}
