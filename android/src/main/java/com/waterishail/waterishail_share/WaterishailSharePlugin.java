package com.waterishail.waterishail_share;

import androidx.core.app.ShareCompat;
import androidx.core.content.FileProvider;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.util.Log;

import java.io.*;
import java.net.URI;


/** NativeSharePlugin */
public class WaterishailSharePlugin implements MethodCallHandler {
  Result result;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "waterishail_share");
    channel.setMethodCallHandler(new WaterishailSharePlugin(registrar));
  }

  private final Registrar registrar;
  private WaterishailSharePlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, Result res) {
    result = res;

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

    String SHARED_INTENT_NAME ="FLUTTER_SHARE";
    PendingIntent pi = PendingIntent.getBroadcast(registrar.context(), 0, new Intent(SHARED_INTENT_NAME),0);

    registrar.context().registerReceiver(new BroadcastReceiver()
    {
      @Override
      public void onReceive(Context arg0, Intent arg1)
      {
        Log.d("ZZZZZZZZZ", "Receiver was called");
      }
    }, new IntentFilter(SHARED_INTENT_NAME));

    Intent chooserIntent = Intent.createChooser(shareIntent, null, pi.getIntentSender());

    registrar.activity().startActivity(chooserIntent);
  }

}
