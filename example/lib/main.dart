import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/services.dart';
import 'package:waterishail_share/waterishail_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  void onShareImage() async {
    print("Reading logo from assets");
    final byteData = await rootBundle.load('assets/flutter-logo.png');

    print("Getting temporary path");
    final Directory tempPath = await getTemporaryDirectory();

    print("Creating the file in a tempaoryfolder");
    final File file = File('${tempPath.path}/logo.png');

    print("Writing data to file");
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    print("Sharing image");
    await WaterishailShare.shareImage(imageFile: file, text: "This is a file");

    print("Deleting file");
    await file.delete();

    print("Finished");
  }

  void onShareText() {
    WaterishailShare.shareText(text: "This is some text", isHtml: false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text("Share Image"),
                onPressed: () {
                  onShareImage();
                },
              ),
              RaisedButton(
                child: Text("Share Text"),
                onPressed: () {
                  onShareText();
                },
              )
            ],
          ),
        )
      ),
    );
  }
}
