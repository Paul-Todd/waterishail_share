import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flutter/services.dart';

class WaterishailShare {
  static const MethodChannel _channel = const MethodChannel('waterishail_share');

  static Future<int> shareImage({@required File imageFile, String text, Rect sharePositionOrigin,}) async {
    Map<String, dynamic> params = {"imageFile": imageFile.absolute.uri.toString()};

    if (text != null && text.isNotEmpty) {
      params["text"] = text;
    }

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    print('Sharing position $sharePositionOrigin');

    final int result = await _channel.invokeMethod('share_image', params);
    return result;
  }

  static Future<int> shareText({@required String text, bool isHtml, Rect sharePositionOrigin,}) async {

    Map<String, dynamic> params = {"text": text, "isHTML": isHtml};

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    final int result = await _channel.invokeMethod('share_text', params);
    return result;
  }

}
