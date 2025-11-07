import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

class ChatGlobalVariables {
  TextEditingController globalDocumentTextField = TextEditingController();
  List<File> globalPdfFiles = [];
  File? globalAudioFile;
  Uint8List? globalPdfThumbnail;
  TextEditingController globalMessageTextField = TextEditingController();
  bool globalIsPdf = false;
  bool globalIsVideo = false;
  File? globalMessageImage;
  bool globalDocumentUploadStatus = false;
  String globalWrittenMessage = '';
  String? globalMessage;
  File? globalThumbnailFile;
  bool globalIsAttachmentLoading = false;
  ChatGlobalVariables();
}
