library keyboard_avoider;

import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';

/// Wraps the [child] in a [Container] or [AnimatedContainer], based on [animated],
/// that adjusts its bottom [padding] to accommodate the on-screen keyboard.
class KeyboardAvoider extends StatefulWidget
{
  /// The child to embed.
  final Widget child;

  // Whether to animate the transition.
  final bool animated;

  /// Duration of the resize animation if [animated] is true. Defaults to 100ms.
  final Duration duration;

  /// Animation curve. Defaults to [easeInOut]
  final Curve curve;

  KeyboardAvoider(
    {Key key,
    @required this.child,
    this.animated: true,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut
  }) : super(key: key);

  _KeyboardAvoiderState createState() => new _KeyboardAvoiderState();
}

class _KeyboardAvoiderState extends State<KeyboardAvoider>
{
  double _overlap = 0.0;

  @override
  Widget build(BuildContext context)
  {
    //Execute after build() so that we can call context.findRenderObject();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _resize();
    });

    if (widget.animated) {
      return new AnimatedContainer(
        padding: new EdgeInsets.only(bottom: _overlap),
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child
      );
    }

    return new Container(
      padding: new EdgeInsets.only(bottom: _overlap),
      child: widget.child
    );
  }

  void _resize()
  {
    //Calculate Rect of widget on screen
    RenderBox box = context.findRenderObject();
    Offset offset = box.localToGlobal(Offset.zero);
    Rect widgetRect = new Rect.fromLTWH(offset.dx, offset.dy, box.size.width, box.size.height);

    //Calculate top of keyboard
    MediaQueryData mediaQuery = MediaQuery.of(context);
    Size screenSize = mediaQuery.size;
    EdgeInsets screenInsets = mediaQuery.viewInsets;
    double keyboardTop = screenSize.height - screenInsets.bottom;

    //Check if keyboard overlaps widget
    double overlap = max(0.0, widgetRect.bottom - keyboardTop);
    if (overlap != _overlap) {
      setState(() => _overlap = overlap);
    }
  }
}
