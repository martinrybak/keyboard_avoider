import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Wraps the [child] in a [AnimatedContainer] that adjusts its bottom [padding]
/// to accommodate the on-screen keyboard. To disable the animation, set [duration] to [Duration.zero].
class KeyboardAvoidingContainer extends StatefulWidget {
  /// The child to embed.
  final Widget child;

  /// Duration of the resize animation. Defaults to 100ms.
  final Duration duration;

  /// Animation curve. Defaults to [easeOut]
  final Curve curve;

  /// Callback invoked when the [AnimatedContainer] animation completes after the keyboard is shown.
  final Function onKeyboardShown;

  /// Callback invoked when the [AnimatedContainer] animation completes after the keyboard is hidden.
  final Function onKeyboardHidden;

  KeyboardAvoidingContainer({
    Key key,
    @required this.child,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeOut,
    this.onKeyboardShown,
    this.onKeyboardHidden,
  }) : super(key: key);

  _KeyboardAvoidingContainerState createState() =>
      _KeyboardAvoidingContainerState();
}

class _KeyboardAvoidingContainerState extends State<KeyboardAvoidingContainer>
    with WidgetsBindingObserver {
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
    //Add a status listener to the animation. This has to be done post-build so that _animationKey.currentState is not null.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Don't add a status listener after every build, just once
      if (_animationListener == null) {
        _animationListener = _animationStatusChanged;
        _animationKey.currentState.animation
            .addStatusListener(_animationListener);
      }
    });

    return AnimatedContainer(
      key: _animationKey,
      padding: EdgeInsets.only(bottom: _overlap),
      duration: widget.duration,
      curve: widget.curve,
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

  /// Animation status

  void _animationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
      if (keyboardVisible) {
        widget.onKeyboardShown?.call();
      } else {
        widget.onKeyboardHidden?.call();
      }
    }
  }

  /// Private

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
}
