library keyboard_avoider;

import 'dart:ui';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'keyboard_avoider.dart';

/// Embeds the [child] in a [SingleChildScrollView] wrapped with a [KeyboardAvoider].
/// If the [child] contains a focused widget, it will auto-scroll so that it is visible
/// in the viewport according to the given [alignment].
class KeyboardScrollView extends StatefulWidget
{
  /// The child to embed. Must not be a [Scrollable].
  final Widget child;

  // Whether to animate the transition.
  final bool animated;

  /// Duration of the animations if [animated] is true. Defaults to 100ms.
  final Duration duration;

  /// Animation curve. Defaults to [easeInOut].
  final Curve curve;

  /// How to align the focused widget. 0 is top, 1 is bottom. Defaults to 0.5.
  final double alignment;

  KeyboardScrollView({
    Key key,
    @required this.child,
    this.animated = true,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
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
      curve: widget.curve,
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

    //Wait for keyboard to finish showing
    new Future.delayed(const Duration(milliseconds: 300)).then((_){
      _scrollToFocused();
    });
  }

  /// Private

  void _scrollToFocused()
  {
    var focused = _findFocusedObject(context.findRenderObject());
    if (focused != null) {
      _scrollToObject(focused);
    }
  }

  /// Finds the first focused [RenderEditable] child of [root] using a breadth-first search.
  RenderObject _findFocusedObject(RenderObject root)
  {
    var q = new Queue<RenderObject>();
    q.add(root);
    while (q.isNotEmpty) {
      var node = q.removeFirst();
      if (node is RenderEditable && node.hasFocus) {
        return node;
      }
      node.visitChildren((child){
        q.add(child);
      });
    }
    return null;
  }

  _scrollToObject(RenderObject object)
  {
    _scrollController.position.ensureVisible(
      object,
      alignment: widget.alignment,
      duration: widget.duration,
      curve: widget.curve
    );
  }
}
