import 'package:flutter/material.dart';
import 'package:app_ontapkienthuc/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App Ôn Tập Kiến Thức",
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const MyHomePage(),
    );
  }
}
