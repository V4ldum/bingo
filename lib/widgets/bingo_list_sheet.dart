import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BingoListSheet extends StatelessWidget {
  const BingoListSheet({
    required this.buttons,
    super.key,
  });

  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return ShadSheet(
      child: SizedBox(
        width: 145,
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: buttons,
        ),
      ),
    );
  }
}
