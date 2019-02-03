import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Material(
        child: new KeyboardAvoidingScrollView(
          child: new Column(
            children: List.generate(20, (index) {
              return new TextFormField(initialValue: 'index = $index');
            }),
          ),
        ),
      ),
    );
  }
}
