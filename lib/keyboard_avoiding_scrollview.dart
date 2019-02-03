import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'keyboard_avoiding_container.dart';

/// Embeds the [child] in a [SingleChildScrollView] wrapped with a [KeyboardAvoidingContainer].
/// If the [child] contains a focused widget such as a [TextField] that becomes active,
/// it will auto-scroll so that it is visible in the viewport according to the given [alignment].
class KeyboardAvoidingScrollView extends StatefulWidget {
  /// The child to embed. Must not be a [Scrollable].
  final Widget child;

  /// Whether to animate the [KeyboardAvoider].
  final bool animated;

  /// Duration of the [KeyboardAvoider] animation and focus animation. Defaults to 100ms.
  final Duration duration;

  /// Curve for the [KeyboardAvoider] animation and focus animation. Defaults to [easeInOut].
  final Curve curve;

  /// How to align the focused widget in the viewport. 0 is top, 1 is bottom. Defaults to 0.5.
  final double alignment;

  /// How long to wait after the keyboard starts appearing before auto-scrolling to the focused widget.
  /// This value can't be too low or the auto-scroll won't work. Default is 300ms.
  final Duration focusDelay;

  KeyboardAvoidingScrollView({
    Key key,
    @required this.child,
    this.animated = true,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
    this.alignment = 0.5,
    this.focusDelay = const Duration(milliseconds: 300),
  })  : assert(!(child is Scrollable)),
        assert(alignment >= 0 && alignment <= 1),
        super(key: key);

  @override
  _KeyboardAvoidingScrollViewState createState() => _KeyboardAvoidingScrollViewState();
}

class _KeyboardAvoidingScrollViewState extends State<KeyboardAvoidingScrollView>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = new ScrollController();

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
    return new KeyboardAvoidingContainer(
      animated: widget.animated,
      duration: widget.duration,
      curve: widget.curve,
      child: new LayoutBuilder(builder: (context, constraints) {
        return new SingleChildScrollView(
          controller: _scrollController,
          child: new ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: widget.child,
          ),
        );
      }),
    );
  }

  /// WidgetsBindingObserver

  @override
  void didChangeMetrics() {
    new Future.delayed(widget.focusDelay).then((_) {
      _scrollToFocusedObject();
    });
  }

  /// Private

  void _scrollToFocusedObject() {
    var focused = _findFocusedObject(context.findRenderObject());
    if (focused != null) {
      _scrollToObject(focused);
    }
  }

  /// Finds the first focused [RenderEditable] child of [root] using a breadth-first search.
  RenderObject _findFocusedObject(RenderObject root) {
    var q = new Queue<RenderObject>();
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

  _scrollToObject(RenderObject object) {
    _scrollController.position.ensureVisible(
      object,
      alignment: widget.alignment,
      duration: widget.duration,
      curve: widget.curve,
    );
  }
}
