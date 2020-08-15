import 'package:didicodes/Widgets/FullPhotoScreenState.dart';
import 'package:flutter/material.dart';

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url);
}
