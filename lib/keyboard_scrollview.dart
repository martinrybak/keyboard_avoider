library keyboard_avoider;

import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'keyboard_avoider.dart';

/// Embeds the [child] in a [SingleChildScrollView]
/// and wraps with a [KeyboardAvoider].
class KeyboardScrollView extends StatefulWidget
{
  /// The child to embed. Must not be a [Scrollable].
  final Widget child;

  // Whether to animate the transition
  final bool animated;

  /// Duration of the resize animation if [animated] is true. Defaults to 100ms.
  final Duration duration;

  /// How to align the focused widget. 0 is top, 1 is bottom. Defaults to 0.5.
  final double alignment;

  KeyboardScrollView({
    Key key,
    @required this.child,
    this.animated = true,
    this.duration = const Duration(milliseconds: 100),
    this.alignment = 0.5
}) : assert(!(child is Scrollable)),
     assert(alignment >= 0 && alignment <= 1),
     super(key: key);

  @override
  _KeyboardScrollViewState createState() => _KeyboardScrollViewState();
}

class _KeyboardScrollViewState extends State<KeyboardScrollView> with WidgetsBindingObserver
{
  final ScrollController _scrollController = new ScrollController();

  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose()
  {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return new KeyboardAvoider(
      animated: widget.animated,
      duration: widget.duration,
      child: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return new SingleChildScrollView(
            controller: _scrollController,
            child: new ConstrainedBox(
              constraints: new BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: widget.child
            ),
          );
        }
      ),
    );
  }

  /// WidgetsBindingObserver

  @override void didChangeMetrics()
  {
    //Keyboard closing, do nothing
    if (window.viewInsets.bottom == 0) {
      return;
    }

    //Wait for keyboard animation to finish showing
    new Future.delayed(const Duration(milliseconds: 300)).then((_){
      _autoScroll();
    });
  }

  /// Private

  void _autoScroll()
  {
    _findFocusedRenderObject(context.findRenderObject());
  }

  //TODO: replace with breadth-first search
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
    _scrollController.position.ensureVisible(
      object,
      alignment: widget.alignment,
      duration: widget.duration,
    );
  }
}
