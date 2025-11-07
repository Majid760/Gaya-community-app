// import 'package:collection/collection.dart' show IterableExtension;

import 'package:connectycube_sdk/connectycube_core.dart' as sdk;
import 'package:connectycube_sdk/connectycube_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_io/io.dart';

import 'storage_test_utils.dart';

Future<void> main() async {
  setUpAll(beforeTestPreparations);

  group("Tests STORAGE", () {
    test("testUploadFile", () async {
      var dir = Directory.current.path;
      var file = File('$dir/test/storage/resources/image.png');

      int? blobId;
      await uploadFile(
        file,
        isPublic: true,
        onProgress: (progress) {
          log("Progress: $progress");
        },
      ).then((cubeFile) {
        log("URL ${cubeFile.getPublicUrl()}");
        assert(cubeFile.id != null);
        blobId = cubeFile.id;

        assert(cubeFile.name == 'image.png');
        assert(cubeFile.contentType == 'image/png');
        assert(cubeFile.isPublic!);
        assert(!sdk.isEmpty(cubeFile.uid));
        assert(cubeFile.size != null && cubeFile.size != 0);
      }).catchError((onError) {
        assert(onError == null);
      }).whenComplete(() async {
        if (blobId != null) {
          await deleteFile(blobId!);
        }
      });
    });

    test("testUploadFileCustomType", () async {
      var dir = Directory.current.path;
      var file = File('$dir/test/storage/resources/image.png');
      var customType = 'image/jpeg';

      int? blobId;
      await uploadFile(
        file,
        isPublic: true,
        mimeType: customType,
        onProgress: (progress) {
          log("Progress: $progress");
        },
      ).then((cubeFile) {
        log("URL ${cubeFile.getPublicUrl()}");
        assert(cubeFile.id != null);
        blobId = cubeFile.id;

        assert(cubeFile.contentType == customType);
      }).catchError((onError) {
        assert(onError == null);
      }).whenComplete(() async {
        if (blobId != null) {
          await deleteFile(blobId!);
        }
      });
    });

    // TODO not implemented on the server-side yet
    // test("testUpdateFile", () async {
    //   var dir = Directory.current.path;
    //   var file = File('$dir/test/storage/resources/image.png');
    //   var newName = "new_name.jpeg";
    //   var newContentType = "image/jpeg";
    //
    //   int? blobId;
    //   await uploadFile(
    //     file,
    //     isPublic: true,
    //     onProgress: (progress) {
    //       log("Progress: $progress");
    //     },
    //   ).then((cubeFile) {
    //     log("URL ${cubeFile.getPublicUrl()}");
    //     assert(cubeFile.id != null);
    //     blobId = cubeFile.id;
    //
    //     cubeFile.name = newName;
    //     cubeFile.contentType = newContentType;
    //     return updateCubeFile(cubeFile).then((updatedFile) {
    //       assert(updatedFile.name == newName);
    //       assert(updatedFile.contentType != newContentType);
    //     });
    //   }).catchError((onError) {
    //     assert(onError == null);
    //   }).whenComplete(() async {
    //     if (blobId != null) {
    //       // await deleteFile(blobId!);
    //     }
    //   });
    // });

    test("testGetFile", () async {
      var dir = Directory.current.path;
      var file = File('$dir/test/storage/resources/image.png');

      int? blobId;
      await uploadFile(
        file,
        isPublic: true,
        onProgress: (progress) {
          log("Progress: $progress");
        },
      ).then((cubeFile) {
        log("URL ${cubeFile.getPublicUrl()}");
        assert(cubeFile.id != null);
        blobId = cubeFile.id;

        return getCubeFile(blobId!).then((file) {
          assert(file.id == blobId);
          assert(file.name == 'image.png');
          assert(file.contentType == 'image/png');
          assert(file.isPublic!);
          assert(!sdk.isEmpty(file.uid));
          assert(file.size != null && file.size != 0);
        });
      }).catchError((onError) {
        assert(onError == null);
      }).whenComplete(() async {
        if (blobId != null) {
          await deleteFile(blobId!);
        }
      });
    });

    // TODO not implemented on the server-side yet
    // test("testGetFiles", () async {
    //   var dir = Directory.current.path;
    //   var file = File('$dir/test/storage/resources/image.png');
    //
    //   int? blobId;
    //   await uploadFile(
    //     file,
    //     isPublic: true,
    //     onProgress: (progress) {
    //       log("Progress: $progress");
    //     },
    //   ).then((cubeFile) {
    //     log("URL ${cubeFile.getPublicUrl()}");
    //     assert(cubeFile.id != null);
    //     blobId = cubeFile.id;
    //
    //     return getCubeFiles().then((result) {
    //       CubeFile? crestedMeeting =
    //           result.items.firstWhereOrNull((element) => element.id == blobId);
    //       assert(crestedMeeting != null);
    //     });
    //   }).catchError((onError) {
    //     assert(onError == null);
    //   }).whenComplete(() async {
    //     if (blobId != null) {
    //       await deleteFile(blobId!);
    //     }
    //   });
    // });

    test("testDeleteFile", () async {
      var dir = Directory.current.path;
      var file = File('$dir/test/storage/resources/image.png');

      int? blobId;
      await uploadFile(
        file,
        isPublic: true,
      ).then((cubeFile) async {
        assert(cubeFile.id != null);
        blobId = cubeFile.id;

        await deleteFile(blobId!);

        await getCubeFile(blobId!).catchError((onError) {
          log("Error1: $onError");
          assert(onError.toString().contains('Not found'));
        });
      }).catchError((onError) {
        log("Error2: $onError");
        // assert(onError == null);
      });
    });
  });

  tearDownAll(deleteSession);
}
