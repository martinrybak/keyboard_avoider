import 'dart:math';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Wraps the [child] in a [AnimatedContainer] that adjusts its [padding] to accommodate the on-screen keyboard.
/// If the [child] is not a [ScrollView], first embeds the child in a [SingleChildScrollView].
/// If the [child] contains a focused widget such as a [TextField], it will auto-scroll so that
/// it is just visible above the keyboard, plus any additional [focusPadding].
class KeyboardAvoider extends StatefulWidget {
  /// The child to embed. If the [child] is not a [ScrollView], it is automatically embedded in a [SingleChildScrollView].
  /// If the [child] is a [ScrollView], it must have a [ScrollController].
  final Widget child;

  /// Duration of the resize animation. Defaults to 100ms. To disable, set to [Duration.zero].
  final Duration duration;

  /// Animation curve. Defaults to [easeOut]
  final Curve curve;

  /// Space to put between the focused widget and the top of the keyboard. Defaults to 12.
  /// Useful in case the focused widget is inside a parent widget that you also want to be visible.
  final double focusPadding;

  KeyboardAvoider({
    Key key,
    @required this.child,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeOut,
    this.focusPadding = 12.0,
  })  : assert(child is ScrollView ? child.controller != null : true),
        super(key: key);

  _KeyboardAvoiderState createState() => _KeyboardAvoiderState();
}

class _KeyboardAvoiderState extends State<KeyboardAvoider>
    with WidgetsBindingObserver {
  ScrollController _scrollController;
  final _animationKey = new GlobalKey<ImplicitlyAnimatedWidgetState>();
  Function(AnimationStatus) _animationListener;
  double _overlap = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationKey.currentState.animation
        .removeStatusListener(_animationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add a status listener to the animation.
    // This must be done post-build so that _animationKey.currentState is not null.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Add the status listener just once
      if (_animationListener == null) {
        _animationListener = _animationStatusChanged;
        _animationKey.currentState.animation
            .addStatusListener(_animationListener);
      }
    });

    // If [child] is a [ScrollView], grab its [ScrollController]
    // and just embed the [child] directly in an [AnimatedContainer].
    if (widget.child is ScrollView) {
      var scrollable = widget.child as ScrollView;
      _scrollController = scrollable.controller;
      return _buildAnimatedContainer(widget.child);
    }

    // If [child] is not a [ScrollView], create a new [ScrollController]
    // and embed the [child] in a [SingleChildScrollView].
    _scrollController = new ScrollController();
    return _buildAnimatedContainer(LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: widget.child,
          ),
        );
      },
    ));
  }

  /// WidgetsBindingObserver

  @override
  void didChangeMetrics() {
    //Need to wait a frame to get the new size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resize();
    });
  }

  /// AnimationStatus

  void _animationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0.0;
      if (keyboardVisible) {
        _keyboardShown();
      }
    }
  }

  /// Private

  Widget _buildAnimatedContainer(Widget child) {
    return AnimatedContainer(
      key: _animationKey,
      padding: EdgeInsets.only(bottom: _overlap),
      duration: widget.duration,
      curve: widget.curve,
      child: child,
    );
  }

  void _resize() {
    //Calculate Rect of widget on screen
    final object = context.findRenderObject();
    final box = object as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final widgetRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      box.size.width,
      box.size.height,
    );

    //Calculate top of keyboard
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenInsets = mediaQuery.viewInsets;
    final keyboardTop = screenSize.height - screenInsets.bottom;

    //Check if keyboard overlaps widget
    final overlap = max(0.0, widgetRect.bottom - keyboardTop);
    if (overlap != _overlap) {
      setState(() {
        _overlap = overlap;
      });
    }
  }

  void _keyboardShown() {
    //Need to wait a frame to get the new size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFocusedObject();
    });
  }

  void _scrollToFocusedObject() {
    final focused = _findFocusedObject(context.findRenderObject());
    if (focused != null) {
      _scrollToObject(focused);
    }
  }

  /// Finds the first focused [RenderEditable] child of [root] using a breadth-first search.
  RenderObject _findFocusedObject(RenderObject root) {
    final q = Queue<RenderObject>();
    q.add(root);
    while (q.isNotEmpty) {
      final node = q.removeFirst();
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
    final box = object as RenderBox;
    final viewport = RenderAbstractViewport.of(object);
    final offset = box.localToGlobal(Offset.zero, ancestor: viewport);
    final rect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      box.size.width,
      box.size.height,
    );

    //Calculate the top and bottom of the visible viewport
    final position = _scrollController.position;
    final viewportTop = position.pixels;
    final viewportBottom = viewportTop + position.viewportDimension;

    //If the object bottom is covered by the keyboard, scroll to it
    //so that its bottom touches the top of the keyboard, plus any padding.
    if (rect.bottom > viewportBottom) {
      final newOffset =
          rect.bottom - position.viewportDimension + widget.focusPadding;
      _scrollController.animateTo(
        newOffset,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }
}
