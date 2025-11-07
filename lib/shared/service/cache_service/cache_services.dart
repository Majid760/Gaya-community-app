import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gaya/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';

abstract class CacheServiceInterface {
  Future<Uint8List?> generateThumbnail({required String url});
  Future<File?> generateThumbnailFile({required String url});
  Future<Uint8List?> generatelocalPdfThumbnail({required String url});
  Future<String> downloadAndCachePdf({required String url});
}

class CacheServices implements CacheServiceInterface {
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  @override
  Future<Uint8List?> generateThumbnail({required String url}) async {
    final file = await _cacheManager.getSingleFile(url);
    final pdfDocument = await PdfDocument.openFile(file.path);
    final pdfPage = await pdfDocument.getPage(1);
    final pageImage = await pdfPage.render(width: 200, height: 200);
    final image = await pageImage.createImageDetached();
    final pngData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List? _pdfThumbnail = (pngData != null) ? Uint8List.view(pngData.buffer) : null;
    await pdfDocument.dispose(); //close();
    return _pdfThumbnail;
  }

  @override
  Future<File?> generateThumbnailFile({required String url}) async {
    final pdfDocument = await PdfDocument.openFile(url);
    final pdfPage = await pdfDocument.getPage(1);
    final pageImage = await pdfPage.render(width: 200, height: 200);
    final image = await pageImage.createImageDetached();
    final pngData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List? _pdfThumbnail = (pngData != null) ? Uint8List.view(pngData.buffer) : null;
    await pdfDocument.dispose(); //close();
    if (_pdfThumbnail == null) return null;
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(_pdfThumbnail);
    return file;
  }

  @override
  Future<Uint8List?> generatelocalPdfThumbnail({required String url}) async {

    final pdfDocument = await PdfDocument.openFile(url);
    final pdfPage = await pdfDocument.getPage(1);
    final pageImage = await pdfPage.render(width: 200, height: 200);
    final image = await pageImage.createImageDetached();
    final pngData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List? _pdfThumbnail = (pngData != null) ? Uint8List.view(pngData.buffer) : null;
    await pdfDocument.dispose(); //close();
    return _pdfThumbnail;
  }

  @override
  Future<String> downloadAndCachePdf({required String url}) async {
    final file = await _cacheManager.getSingleFile(url);
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    var filename = url.split("/").last.split('-').last;
    final pdfPath = '${appDocumentsDirectory.path}/$filename.pdf';
    MyLoggerServices.to.print('pdf path is: $pdfPath');
    try {
      await file.copy(pdfPath);
    } catch (_) {
      MyLoggerServices.to.print('pdf path in catch is: $pdfPath , $_');
    }
    return pdfPath;
  }
}
