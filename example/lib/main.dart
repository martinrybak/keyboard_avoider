import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Row(
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
                Flexible(flex: 2, child: _buildForm(40, Colors.green)),
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
    );
  }

  Widget _buildForm(int rows, Color color)
  {
    return Container(
      color: color,
      child: KeyboardAvoider(
        autoFocus: true,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          controller: ScrollController(),
          itemCount: rows,
          itemBuilder: (context, index) {
            return Material(
              child: TextFormField(
                initialValue: 'TextFormField ${index + 1}',
                decoration: InputDecoration(
                  fillColor: color,
                  filled: true
              ),
              )
            );
          },
        )
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
