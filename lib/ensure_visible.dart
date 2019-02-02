import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//https://www.didierboelens.com/2018/04/hint-4-ensure-a-textfield-or-textformfield-is-visible-in-the-viewport-when-has-the-focus/
class EnsureVisible extends StatefulWidget
{
  final Widget Function(BuildContext, FocusNode) builder;

  final Duration duration;

  final Curve curve;

  EnsureVisible({
    Key key,
    this.builder,
    this.duration: const Duration(milliseconds: 300),
    this.curve: Curves.ease,
  }) : super(key: key);

  _EnsureVisibleState createState() => new _EnsureVisibleState();
}

class _EnsureVisibleState extends State<EnsureVisible> with WidgetsBindingObserver
{
  final FocusNode _focusNode = new FocusNode();

  /// State

  @override
  void initState()
  {
    super.initState();
    _focusNode.addListener(_focusChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose()
  {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_focusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return this.widget.builder(context, _focusNode);
  }

  /// WidgetsBindingObserver

  @override
  void didChangeMetrics()
  {
    _focusChanged();
  }

  /// Private

  void _focusChanged()
  {
    if (_focusNode.hasFocus) {
      _scrollToWidget();
    }
  }

  void _scrollToWidget() async
  {
    // Wait for the keyboard to come into view
    await new Future.delayed(const Duration(milliseconds: 300));

    // No need to go any further if the node has not the focus
    if (!_focusNode.hasFocus) {
      return;
    }

    // Find the object which has the focus
    final RenderObject object = context.findRenderObject();
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
      curve: this.widget.curve
    );
  }
}
