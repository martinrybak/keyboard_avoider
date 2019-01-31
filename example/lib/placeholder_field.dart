import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlaceholderField extends StatefulWidget {
  @override
  _PlaceholderFieldState createState() => _PlaceholderFieldState();
}

class _PlaceholderFieldState extends State<PlaceholderField>
    implements TextInputClient {
  TextInputConnection _textInputConnection;

  /// State

  @override
  void initState() {
    super.initState();
    _textInputConnection = TextInput.attach(this, new TextInputConfiguration());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _showKeyboard();
  }

  @override
  void dispose() {
    _textInputConnection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: _showKeyboard,
      child: new Container(color: Colors.white, child: new Placeholder()),
    );
  }

  /// Private

  void _showKeyboard() {
    _textInputConnection.show();
  }

  /// TextInputClient

  void updateEditingValue(TextEditingValue value) {}

  void performAction(TextInputAction action) {}
}
