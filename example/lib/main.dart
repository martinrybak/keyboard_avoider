import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: KeyboardAvoidingScrollView(
          child: Column(
            children: List.generate(40, (index) {
              return TextFormField(initialValue: 'index = $index');
            }),
          ),
        ),
      ),
    );
  }
}
