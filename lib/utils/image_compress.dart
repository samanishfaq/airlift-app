import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<Uint8List> compressFile(File file) async {
  try {
    final imageSize = file.lengthSync() / 1024;
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: imageSize > 5000
          ? 12
          : imageSize > 3000
              ? 20
              : 30,
    );
    log("Before: $imageSize");
    log("After: ${((result?.length ?? 1) / 1024).toString()}");
    return result ?? Uint8List(0);
  } on Exception catch (e) {
    log(e.toString());
    throw Uint8List(0);
  }
}
