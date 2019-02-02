library keyboard_avoider;

import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';

/// Wraps the [child] in a [Container] or [AnimatedContainer], based on [animated],
/// that adjusts its bottom [padding] to accommodate the on-screen keyboard.
class KeyboardAvoider extends StatefulWidget {
  /// The child contained by the widget
  final Widget child;

  // Whether to animate the transition
  final bool animated;

  /// Duration of the resize animation if [animated] is true. Defaults to 100ms.
  final Duration duration;

  KeyboardAvoider(
      {Key key,
      @required this.child,
      this.animated: true,
      this.duration = const Duration(milliseconds: 100)})
      : super(key: key);

  _KeyboardAvoiderState createState() => new _KeyboardAvoiderState();
}

class _KeyboardAvoiderState extends State<KeyboardAvoider> {
  double _overlap = 0.0;

  @override
  Widget build(BuildContext context) {
    //Execute after build() so that we can call context.findRenderObject();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _resize();
    });

    if (this.widget.animated) {
      return new AnimatedContainer(
          padding: new EdgeInsets.only(bottom: _overlap),
          duration: this.widget.duration,
          child: this.widget.child);
    }

    return new Container(
        padding: new EdgeInsets.only(bottom: _overlap),
        child: this.widget.child);
  }

  void _resize() {
    //Calculate Rect of widget on screen
    RenderBox box = context.findRenderObject();
    Offset offset = box.localToGlobal(Offset.zero);
    Rect widgetRect = new Rect.fromLTWH(
        offset.dx, offset.dy, box.size.width, box.size.height);

    //Calculate top of keyboard
    MediaQueryData mediaQuery = MediaQuery.of(context);
    Size screenSize = mediaQuery.size;
    EdgeInsets screenInsets = mediaQuery.viewInsets;
    double keyboardTop = screenSize.height - screenInsets.bottom;

    //Check if keyboard overlaps widget
    double overlap = max(0.0, widgetRect.bottom - keyboardTop);
    if (overlap != _overlap) {
      _findFocusedRenderObject(context.findRenderObject());
      setState(() => _overlap = overlap);
    }
  }

  void _findFocusedRenderObject(RenderObject parent)
  {
    parent.visitChildren((child){
      if (child is RenderEditable && child.hasFocus) {
        _scrollToFocusedRenderObject(child);
        return;
      }
      _findFocusedRenderObject(child);
    });
  }

  _scrollToFocusedRenderObject(RenderObject object)
  {
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);
    assert(viewport != null);

    // Get the Scrollable state (in order to retrieve its offset)
    ScrollableState scrollableState = Scrollable.of(context);
    assert(scrollableState != null);

    // Get its offset
    ScrollPosition position = scrollableState.position;
    double alignment;

    if (position.pixels > viewport.getOffsetToReveal(object, 0.0).offset) {
      // Move down to the top of the viewport
      alignment = 0.0;
    } else if (position.pixels < viewport.getOffsetToReveal(object, 1.0).offset) {
      // Move up to the bottom of the viewport
      alignment = 1.0;
    } else {
      // No scrolling is necessary to reveal the child
      return;
    }

    position.ensureVisible(
        object,
        alignment: alignment,
        duration: this.widget.duration,
//        curve: this.widget.curve
    );
  }
}
