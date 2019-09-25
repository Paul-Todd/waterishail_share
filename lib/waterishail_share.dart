import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';

import 'package:flutter/services.dart';

class WaterishailShare {
  static const MethodChannel _channel = const MethodChannel('waterishail_share');

  static Future<int> shareImage({@required File imageFile, String text}) async {
    Map<String, dynamic> params = {"imageFile": imageFile.absolute.uri.toString()};

    if (text != null && text.isNotEmpty) {
      params["text"] = text;
    }

    final int result = await _channel.invokeMethod('share_image', params);
    return result;
  }

  static Future<int> shareText({@required String text, bool isHtml}) async {

    Map<String, dynamic> params = {"text": text, "isHTML": isHtml};

    final int result = await _channel.invokeMethod('share_text', params);
    return result;
  }

}
