import 'package:flutter/material.dart';
import 'Screens/Login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Didi Chat',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Login()
    );
  }
}
