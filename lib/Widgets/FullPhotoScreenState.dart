import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'FullPhotoScreen.dart';

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

 FullPhotoScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: NetworkImage(url)
      )
    );
  }
}
