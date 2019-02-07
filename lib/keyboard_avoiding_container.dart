import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Wraps the [child] in a [AnimatedContainer] that adjusts its bottom [padding]
/// to accommodate the on-screen keyboard. To disable the animation, set [duration] to zero.
class KeyboardAvoidingContainer extends StatefulWidget {
  /// The child to embed.
  final Widget child;

  /// Duration of the resize animation. Defaults to 100ms.
  final Duration duration;

  /// Animation curve. Defaults to [easeInOut]
  final Curve curve;

  KeyboardAvoidingContainer({
    Key key,
    @required this.child,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  _KeyboardAvoidingContainerState createState() => _KeyboardAvoidingContainerState();
}

class _KeyboardAvoidingContainerState extends State<KeyboardAvoidingContainer>
    with WidgetsBindingObserver {
  final GlobalKey<ImplicitlyAnimatedWidgetState> _animationKey = new GlobalKey<ImplicitlyAnimatedWidgetState>();
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
    _animationKey.currentState.animation.removeStatusListener(_animationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Add a status listener to the animation. This has to be done post-build so that _animationKey.currentState is not null.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Don't add a status listener after every build, just once
      if (_animationListener == null) {
        _animationListener = _animationStatusChanged;
        _animationKey.currentState.animation.addStatusListener(_animationListener);
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

  void _animationStatusChanged(AnimationStatus status)
  {
    if (status == AnimationStatus.completed) {
      var keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
      if (keyboardVisible) {
        print ("keyboard shown");
      } else {
        print ("keyboard hidden");
      }
    }
  }

  //Private

  void _resize() {
    //Calculate Rect of widget on screen
    RenderBox box = context.findRenderObject();
    Offset offset = box.localToGlobal(Offset.zero);
    Rect widgetRect = Rect.fromLTWH(
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
