import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'placeholder_field.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new KeyboardAvoider(child: new PlaceholderField()));
  }
}
