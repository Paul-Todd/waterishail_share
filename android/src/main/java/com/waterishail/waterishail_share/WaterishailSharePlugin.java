package com.waterishail.waterishail_share;

import androidx.core.app.ShareCompat;
import androidx.core.content.FileProvider;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import java.io.*;
import java.net.URI;

/** NativeSharePlugin */
public class WaterishailSharePlugin implements MethodCallHandler,PluginRegistry.ActivityResultListener {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "waterishail_share");
    channel.setMethodCallHandler(new WaterishailSharePlugin(registrar));
  }

  private final Registrar registrar;
  private String title,url,imageUrl;
  private WaterishailSharePlugin(Registrar registrar) {
    this.registrar = registrar;
    registrar.addActivityResultListener(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if(call.method.equals("share_image")){
      shareImage(call, result);
    } else if (call.method.equals("share_text")) {
      shareText(call, result);
    } else {
      result.notImplemented();
    }
  }

  private void shareImage(MethodCall call, Result result) {
    String text = call.argument("text");
    String imageFile = call.argument("imageFile");

    if (imageFile == null || imageFile.isEmpty()) {
      result.error("MISSING_IMAGEPATH_PARAM", "The image path parameter is missing", null);
      return;
    }

    share(text, imageFile, result);
  }

  private void shareText(MethodCall call, Result result) {
    String text = call.argument("text");

    if (text == null || text.isEmpty()) {
      result.error("MISSING_TEXT_PARAM", "The text parameter is required", null);
      return;
    }

    share(text, null, result);
  }


  private void share(String text,String fileURI, Result result) {


    Intent shareIntent;

    if (fileURI != null) {
      URI uri = URI.create(fileURI);

      Log.d("XXXXXXX", "File: " + fileURI);

      File imageFile = new File(uri);
      String authority = registrar.context().getPackageName();
      Log.d("XXXXXXX", "Authority: " + authority);

      Uri uriToImage = FileProvider.getUriForFile(registrar.context(), authority, imageFile);
      Log.d("XXXXXX", "URI: " + uriToImage.toString());

      shareIntent = ShareCompat.IntentBuilder
              .from(registrar.activity())
              .setStream(uriToImage)
              .setType(registrar.activity().getContentResolver().getType(uriToImage))
              .setText(text)
              .getIntent()
              .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
      } else {
      shareIntent = ShareCompat.IntentBuilder
              .from(registrar.activity())
              .setText(text)
              .setType("text/plain")
              .getIntent();
    }

//    shareIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//    shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

    Intent intent = Intent.createChooser(shareIntent, null);

    if (shareIntent.resolveActivity(registrar.context().getPackageManager()) != null) {
      registrar.activity().startActivity(intent);
    }
  }

  public
  boolean onActivityResult(int var1, int var2, Intent var3) {
    return true;
  }
}
