import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StoragePaths {
  static FirebaseStorage storage = FirebaseStorage.instance;

  static Reference userAvatar(String useruid) => storage.ref().child("users/$useruid/avatar.png");
  static Reference userCoverPhoto(String useruid) => storage.ref().child("users/$useruid/cover.png");
  static Reference commentPhoto(String userId) =>
      storage.ref().child("comments").child("images").child("$userId/${const Uuid().v1()}/comment.png");
  static Reference commentVideo(String userId) =>
      storage.ref().child("comments").child("video").child("$userId/${const Uuid().v1()}/comment.png");

  static Reference commentDocuments(String userId, String fileName) =>
      storage.ref().child("comments documents").child("documents").child("$userId/${const Uuid().v1()}/$fileName");
  static Reference commentDocumentPhoto(String userId) =>
      storage.ref().child("comments documents").child("document thumbnails").child("$userId/${const Uuid().v1()}/comment.png");
}
