import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Wraps the [child] in a [Container] or [AnimatedContainer], based on [animated],
/// that adjusts its bottom [padding] to accommodate the on-screen keyboard.
class KeyboardAvoidingContainer extends StatefulWidget {
  /// The child to embed.
  final Widget child;

  // Whether to animate the transition.
  final bool animated;

  /// Duration of the resize animation if [animated] is true. Defaults to 100ms.
  final Duration duration;

  /// Animation curve. Defaults to [easeInOut]
  final Curve curve;

  KeyboardAvoidingContainer({
    Key key,
    @required this.child,
    this.animated: true,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  _KeyboardAvoidingContainerState createState() => new _KeyboardAvoidingContainerState();
}

class _KeyboardAvoidingContainerState extends State<KeyboardAvoidingContainer>
    with WidgetsBindingObserver {
  double _overlap = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animated) {
      return new AnimatedContainer(
        padding: new EdgeInsets.only(bottom: _overlap),
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      );
    }

    return new Container(
      padding: new EdgeInsets.only(bottom: _overlap),
      child: widget.child,
    );
  }

  /// WidgetsBindingObserver

  @override
  void didChangeMetrics() {
    //Need to wait a frame to get the new size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resize();
    });
  }

  //Private

  void _resize() {
    //Calculate Rect of widget on screen
    RenderBox box = context.findRenderObject();
    Offset offset = box.localToGlobal(Offset.zero);
    Rect widgetRect = new Rect.fromLTWH(
      offset.dx,
      offset.dy,
      box.size.width,
      box.size.height,
    );

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
