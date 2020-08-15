import 'package:flutter/material.dart';
import 'FullPhotoScreen.dart';

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1B5E20),
        title: Text("Image"),
      ),
      body: FullPhotoScreen(url: url),
    );
  }
}


