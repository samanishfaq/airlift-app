import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../api/api_constants.dart';

class AuthRepository {
  Future<dynamic> authenticate(String phone, String password) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse(ApiConstants.loginUrl));
      request.fields.addAll({
        'phone': phone,
        'password': password,
      });

      http.StreamedResponse response = await request.send();
      final Map<String, dynamic> responseData =
          json.decode(await response.stream.bytesToString());

      if (response.statusCode == 200) {
        // return AuthModel.fromJson(responseData);
      } else {
        if (response.statusCode >= 500) {
          throw ('failedToLoadData'.tr);
        }
        throw responseData["msg"];
      }
    } on SocketException catch (_) {
      throw ("checkInternetConnection".tr);
    } on TimeoutException catch (_) {
      throw ('failedToLoadData'.tr);
    } on HttpException catch (_) {
      throw ('checkInternetConnection'.tr);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> updatePassword(String token, String password) async {
    try {
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var request =
          http.MultipartRequest('POST', Uri.parse(ApiConstants.loginUrl));
      request.fields
          .addAll({'password': password, 'confirmPassword': password});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final Map<String, dynamic> responseData =
          json.decode(await response.stream.bytesToString());

      if (response.statusCode == 200) {
        return true;
      } else {
        if (response.statusCode >= 500) {
          throw ('failedToLoadData'.tr);
        }
        throw responseData["msg"];
      }
    } on SocketException catch (_) {
      throw ('checkInternetConnection'.tr);
    } on TimeoutException catch (_) {
      throw ('failedToLoadData'.tr);
    } on HttpException catch (_) {
      throw ('checkInternetConnection'.tr);
    } catch (error, s) {
      rethrow;
    }
  }
}
