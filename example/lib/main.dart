import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
          child: Material(
//          child: _buildScaffold(),
        child: _buildExample(),
      )),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      floatingActionButton: _buildFab(),
      body: Column(
        children: <Widget>[
          _buildTextField(),
          Expanded(
            child: _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExample() {
    return Column(
      children: <Widget>[
//        _buildTextField(),
        Expanded(
          child: Stack(
            children: <Widget>[
              Positioned(bottom: 20, right: 20, child: _buildFab()),
              KeyboardAvoider(
//                child: _buildList(),
                child: _buildColumn()
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumn() {
    return Column(
      children: List.generate(40, (index) {
        return TextFormField(initialValue: 'TextFormField ${index + 1}');
      }),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      controller: new ScrollController(),
      itemCount: 40,
      itemBuilder: (context, index) {
        return TextFormField(initialValue: 'TextFormField ${index + 1}');
//        return ListTile(
//          leading: Icon(IconData(index + 10000)),
//          title: Text('ListTile ${index + 1}'),
//        );
      },
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {},
    );
  }

  Widget _buildTextField() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.5),
        borderRadius: BorderRadius.all(const Radius.circular(8.0)),
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(Icons.search),
          ),
          Flexible(
            child: TextField(
              autocorrect: false,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Search",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
