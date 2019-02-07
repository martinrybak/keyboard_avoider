import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'keyboard_avoiding_container.dart';

/// Embeds the [child] in a [SingleChildScrollView] wrapped with a [KeyboardAvoidingContainer].
/// If the [child] contains a focused widget such as a [TextField], it will auto-scroll so that
/// that it is just visible above the keyboard, plus any additional [bottomPadding].
class KeyboardAvoidingScrollView extends StatefulWidget {
  /// The child to embed. Must not be a [Scrollable].
  final Widget child;

  /// Whether to animate the [KeyboardAvoidingContainer].
  final bool animated;

  /// Duration of the [KeyboardAvoidingContainer] animation and auto-scroll animation. Defaults to 100ms.
  final Duration duration;

  /// Curve for the [KeyboardAvoidingContainer] animation and auto-scroll animation. Defaults to [easeInOut].
  final Curve curve;

  /// Space to put between the focused widget and the top of the keyboard.
  /// Useful in case the focused widget is inside a container that you also want to be visible.
  final double bottomPadding;

  KeyboardAvoidingScrollView({
    Key key,
    @required this.child,
    this.animated = true,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
    this.bottomPadding = 12.0,
  })  : assert(!(child is Scrollable)),
        super(key: key);

  @override
  _KeyboardAvoidingScrollViewState createState() =>
      _KeyboardAvoidingScrollViewState();
}

class _KeyboardAvoidingScrollViewState extends State<KeyboardAvoidingScrollView> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return KeyboardAvoidingContainer(
      duration: widget.duration,
      curve: widget.curve,
      onKeyboardShown: _keyboardShown,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: widget.child,
          ),
        );
      }),
    );
  }

  /// Private

  void _keyboardShown() {
    //Need to wait a frame to get the new size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFocusedObject();
    });
  }

  void _scrollToFocusedObject() {
    var focused = _findFocusedObject(context.findRenderObject());
    if (focused != null) {
      _scrollToObject(focused);
    }
  }

  /// Finds the first focused [RenderEditable] child of [root] using a breadth-first search.
  RenderObject _findFocusedObject(RenderObject root) {
    var q = Queue<RenderObject>();
    q.add(root);
    while (q.isNotEmpty) {
      var node = q.removeFirst();
      if (node is RenderEditable && node.hasFocus) {
        return node;
      }
      node.visitChildren((child) {
        q.add(child);
      });
    }
    return null;
  }

  /// If the focused object is covered by the keyboard, scroll to it.
  /// Otherwise do nothing.
  _scrollToObject(RenderObject object) {
    //Calculate Rect of object in scrollview
    var box = object as RenderBox;
    var viewport = RenderAbstractViewport.of(object);
    var offset = box.localToGlobal(Offset.zero, ancestor: viewport);
    var rect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      box.size.width,
      box.size.height,
    );

    //Calculate the top and bottom of the visible viewport
    var position = _scrollController.position;
    var viewportTop = position.pixels;
    var viewportBottom = viewportTop + position.viewportDimension;

    //If the object bottom is covered by the keyboard, scroll to it
    //so that its bottom touches the top of the keyboard, plus any padding.
    if (rect.bottom > viewportBottom) {
      var newOffset = rect.bottom - position.viewportDimension + widget.bottomPadding;
      _scrollController.animateTo(
        newOffset,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }
}
