import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/create.post.controller.dart';
import 'package:gaya/shared/view/widget/pdf_detail_screen.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/comments/controller/comments_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LocalPdfviewWidget extends StatefulWidget {
  final String path;
  final double? height;
  final double? width;

  const LocalPdfviewWidget({Key? key, required this.path, this.height, this.width}) : super(key: key);

  @override
  State<LocalPdfviewWidget> createState() => _LocalPdfviewWidgetState();
}

class _LocalPdfviewWidgetState extends State<LocalPdfviewWidget> {
  @override
  void initState() {
    super.initState();
    generateThumbnail();
  }

  generateThumbnail() async {
    Provider.of<CreatePostController>(context, listen: false).generateLocalPdfThumbnail(url: widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostController>(builder: (_, controller, __) {
      return Container(
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
                        SvgIconWidget.fileOutline(height: 30.h, width: 25.w),
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
      );
    });
  }
}

class PdfviewWidget extends StatefulWidget {
  final String path;
  final String? title;
  final String? filename;
  final String? thumbnailUrl;
  final double? width;

  const PdfviewWidget({Key? key, required this.path, this.title, required this.filename, this.thumbnailUrl, this.width}) : super(key: key);

  @override
  State<PdfviewWidget> createState() => _PdfviewWidgetState();
}

class _PdfviewWidgetState extends State<PdfviewWidget> {
  @override
  void initState() {
    super.initState();
    // generateThumbnail();
  }

  // var httpClient = HttpClient();
  // Future<File> _downloadFile(String url, String filename) async {
  //   var request = await httpClient.getUrl(Uri.parse(url));
  //   var response = await request.close();
  //   var bytes = await consolidateHttpClientResponseBytes(response);
  //   String dir = (await getApplicationDocumentsDirectory()).path;
  //   File file = new File('$dir/$filename');
  //   await file.writeAsBytes(bytes);
  //   // OpenFile.open('$dir/$filename').then((value) {
  //   //   print('OpenFile called');
  //   //   // delete the file.
  //   //   // File f = File('$path/${fileList[index].fileName}');
  //   //   // f.delete();
  //   // });

  //   OpenFilex.open('$dir/$filename');

  //   // final Uri uri = Uri.file('$dir/$filename');

  //   // if (!File(uri.toFilePath()).existsSync()) {
  //   //   throw Exception('$uri does not exist!');
  //   // }
  //   // if (!await launchUrl(uri)) {
  //   //   throw Exception('Could not launch $uri');
  //   // }
  //   return file;
  // }

  // generateThumbnail() async {
  //   Provider.of<CreatePostController>(context, listen: false).generateThumbnail(url: widget.path);
  // }

  // Uint8List? pdfThumbnail;

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostController>(builder: (_, controller, __) {
      return Container(
        // height: 117.h,
        width: widget.width ?? 353.w,
        decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(12).r),
        child: InkWell(
            onTap: () async {
              final path = await controller.downloadAndCachePdf(url: widget.path);
              print('File name is: $path');
              // ignore: use_build_context_synchronously
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
                // (widget.isHttpPath == true)
                //     ?
                widget.thumbnailUrl != null
                    ? SizedBox(
                    height: 64.h,
                        width: MediaQuery.sizeOf(context).width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0.r), topRight: Radius.circular(12.0.r)),
                          child: Image.network(
                            widget.thumbnailUrl!,
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

                const Divider(
                  height: 1,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                  child: SizedBox(
                    height: 35.h,
                    child: Row(
                      children: [
                        SvgIconWidget.fileOutline(height: 30.h, width: 25.w),
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

                              /// TODO: uncomment this to enable download but currently having issue with simultaneous downloads
                              /* InkWell(
                                onTap: () async {
                                  // final file = await _downloadFile(widget.path, widget.filename ?? 'abc');
                                  // print('downloaded: ${file.path}');
// Future<File> _downloadFile(String url, String filename) async {
//   var request = await httpClient.getUrl(Uri.parse(url));
//   var response = await request.close();
//   var bytes = await consolidateHttpClientResponseBytes(response);
//   String dir = (await getApplicationDocumentsDirectory()).path;
//   File file = new File('$dir/$filename');
//   await file.writeAsBytes(bytes);
//   return file;
// }
                                },
                                child: GayaSvgAsset(
                                  'Assets/icons/download.svg',
                                  height: 28.r,
                                  width: 28.r,
                                  color: AppColors.primary,
                                ),
                              )*/
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )),
      );
    });
  }
}

class LocalCommentPdfviewWidget extends StatefulWidget {
  final String path;
  final double? height;
  final double? width;
  final String postId;
  final VoidCallback? tapOnImageRemove;

  const LocalCommentPdfviewWidget({
    Key? key,
    required this.path,
    this.height,
    this.width,
    required this.postId,
    this.tapOnImageRemove,
  }) : super(key: key);

  @override
  State<LocalCommentPdfviewWidget> createState() => _LocalCommentPdfviewWidgetState();
}

class _LocalCommentPdfviewWidgetState extends State<LocalCommentPdfviewWidget> {
  @override
  void initState() {
    super.initState();
    generateThumbnail();
  }

  generateThumbnail() async {
    Get.find<CommentsController>(tag: widget.postId).generateLocalPdfThumbnail(url: widget.path);
  }

  @override
  Widget build(BuildContext context) {
    final CommentsController commentsController = Get.find<CommentsController>(tag: widget.postId);

    return GetBuilder<CommentsController>(
      tag: widget.postId,
      init: commentsController,
      autoRemove: false,
      builder: (controller) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
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
                              SvgIconWidget.fileOutline(height: 30.h, width: 25.w),
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
                top: 14,
                right: 14,
                child: InkWell(
                  onTap: widget.tapOnImageRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: kBaseGrey, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.black, size: 14),
                  ),
                )),
          ],
        );
      },
    );
  }
}

class PdfCommentViewWidget extends StatefulWidget {
  final String path;
  final String? title;
  final String? filename;
  final String? thumbnailUrl;
  final double? width;
  final String postId;

  const PdfCommentViewWidget(
      {Key? key, required this.path, this.title, required this.filename, this.thumbnailUrl, this.width, required this.postId})
      : super(key: key);

  @override
  State<PdfCommentViewWidget> createState() => _PdfCommentViewWidgetState();
}

class _PdfCommentViewWidgetState extends State<PdfCommentViewWidget> {
  @override
  void initState() {
    super.initState();
    // generateThumbnail();
  }

  @override
  Widget build(BuildContext context) {
    final CommentsController commentsController = Get.find<CommentsController>(tag: widget.postId);

    return GetBuilder<CommentsController>(
      tag: widget.postId,
      autoRemove: false,
      init: commentsController,
      builder: (controller) {
        return Container(
          // height: 117.h,
          width: widget.width ?? 353.w,
          decoration: BoxDecoration(
              color: AppColors.white, border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(12).r),
          child: InkWell(
              onTap: () async {
                final path = await controller.downloadAndCachePdf(url: widget.path);
                print('File name is: ');
                // ignore: use_build_context_synchronously
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
                  // (widget.isHttpPath == true)
                  //     ?
                  widget.thumbnailUrl != null
                      ? SizedBox(
                      height: 64.h,
                          width: MediaQuery.sizeOf(context).width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0.r), topRight: Radius.circular(12.0.r)),
                            child: Image.network(
                              widget.thumbnailUrl!,
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

                  const Divider(
                    height: 1,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                    child: SizedBox(
                      height: 35.h,
                      child: Row(
                        children: [
                          SvgIconWidget.fileOutline(height: 30.h, width: 25.w),
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

                                /// TODO: uncomment this to enable download but currently having issue with simultaneous downloads
                                /* InkWell(
                                  onTap: () async {
                                    // final file = await _downloadFile(widget.path, widget.filename ?? 'abc');
                                    // print('downloaded: ${file.path}');
                                    // Future<File> _downloadFile(String url, String filename) async {
                                    //   var request = await httpClient.getUrl(Uri.parse(url));
                                    //   var response = await request.close();
                                    //   var bytes = await consolidateHttpClientResponseBytes(response);
                                    //   String dir = (await getApplicationDocumentsDirectory()).path;
                                    //   File file = new File('/');
                                    //   await file.writeAsBytes(bytes);
                                    //   return file;
                                    // }
                                  },
                                  child: GayaSvgAsset(
                                    'Assets/icons/download.svg',
                                    height: 28.r,
                                    width: 28.r,
                                    color: AppColors.primary,
                                  ),
                                )*/
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}

class LocalCustomCommentPdfviewWidget extends StatefulWidget {
  final String path;
  final double? height;
  final double? width;
  final String documentTitle;

  const LocalCustomCommentPdfviewWidget({Key? key, required this.path, this.height, this.width, required this.documentTitle})
      : super(key: key);

  @override
  State<LocalCustomCommentPdfviewWidget> createState() => _LocalCustomCommentPdfviewWidgetState();
}

class _LocalCustomCommentPdfviewWidgetState extends State<LocalCustomCommentPdfviewWidget> {
  @override
  void initState() {
    super.initState();
    generateThumbnail();
  }

  Future<Uint8List?> generateThumbnail() async => Methods.generateLocalPdfThumbnail(url: widget.path);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
        future: generateThumbnail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(height: 117.h, width: widget.width ?? 353.w, child: const Center(child: CircularProgressIndicator()));
          }
          if (snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final pdfThumb = snapshot.data;
          return Container(
            // height: 117.h,
            width: widget.width ?? 353.w,
            decoration: BoxDecoration(
                color: AppColors.white, border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(12).r),
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
                    pdfThumb != null
                        ? SizedBox(
                        height: 64.h,
                            width: MediaQuery.sizeOf(context).width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0.r), topRight: Radius.circular(12.0.r)),
                              child: Image.memory(pdfThumb, fit: BoxFit.cover),
                            ))
                        : SizedBox(
                            height: 64.h,
                            child: const Center(
                              child: AppData.defaultGreySimpleImage,
                            ),
                          ),

                    // Center(
                    //     child: CircularProgressIndicator.adaptive(
                    //     backgroundColor: AppColors.primary,
                    //   )),
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
                            SvgIconWidget.fileOutline(height: 30.h, width: 25.w),
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
                                  if (widget.documentTitle.isNotEmpty)
                                    Text(widget.documentTitle.toString(),
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
          );
        });
  }
}
