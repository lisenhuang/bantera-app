import 'package:flutter/widgets.dart';

/// Makes mobile touch follow the same outside-field dismissal as pointer input.
/// Flutter's text-field tap regions preserve editing, clear buttons and selection;
/// an action override does not intercept taps intended for other controls.
class AppKeyboardDismissal extends StatelessWidget {
  const AppKeyboardDismissal({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Actions(
    actions: <Type, Action<Intent>>{
      EditableTextTapOutsideIntent:
          CallbackAction<EditableTextTapOutsideIntent>(
            onInvoke: (intent) {
              intent.focusNode.unfocus();
              return null;
            },
          ),
    },
    child: child,
  );
}
