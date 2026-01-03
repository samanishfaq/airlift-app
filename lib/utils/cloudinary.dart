import 'dart:developer';
import 'dart:io';

import 'package:airlift/utils/logger.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/material.dart';

class CloudinaryService {
  final cloudinary = Cloudinary.signedConfig(
    apiKey: '133667761245899',
    apiSecret: 'QkSBpskesqko8gK_91FJ1_5HSUo',
    cloudName: 'dwo2ke97j',
  );
  Future<String> uploadFile(File file) async {
    Logger.info('Uploading file: ${file.path}');
    final res = await cloudinary.upload(
      file: file.path,
      resourceType: CloudinaryResourceType.image,
    );
    log(res.statusCode.toString());
    if (res.statusCode == 200) {
      return res.secureUrl ?? '';
    } else {
      debugPrint('Failed to upload file: ${res.error}');
      return '';
    }
  }
}
