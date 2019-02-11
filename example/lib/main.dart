import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Material(
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Flexible(flex: 2, child: _buildPlaceholder(Colors.red)),
                    Flexible(flex: 1, child: _buildPlaceholder(Colors.pink)),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    Flexible(flex: 2, child: _buildForm(Colors.green)),
                    Flexible(flex: 1, child: _buildPlaceholder(Colors.lightGreen),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Flexible(flex: 1, child: _buildPlaceholder(Colors.blue),),
                    Flexible(flex: 2, child: _buildPlaceholder(Colors.lightBlue)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(Color color)
  {
    return Container(
      color: color,
      child: KeyboardAvoider(
        autoFocus: true,
        child: Column(
          children: List.generate(40, (index) {
            return TextFormField(initialValue: 'TextFormField ${index + 1}');
          }),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color)
  {
    return Container(
      color: color,
      child: KeyboardAvoider(
        child: Placeholder(),
      )
    );
  }
}
