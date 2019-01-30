library keyboard_avoider;

import 'package:flutter/widgets.dart';
import 'keyboard-avoider.dart';

/// Wraps the [child] in a [KeyboardAvoider] containing a [SingleChildScrollView]
/// with its [minHeight] constrained to the [maxHeight] of its viewport.
class KeyboardScrollView extends StatelessWidget
{
  final Widget child;
  final bool animated;

  KeyboardScrollView({
    Key key,
    @required this.child,
    this.animated = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return new KeyboardAvoider(animated: this.animated, child:
    new LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return new SingleChildScrollView(child:
      new ConstrainedBox(
          constraints: new BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: this.child
      ),
      );
    }),
    );
  }
}
