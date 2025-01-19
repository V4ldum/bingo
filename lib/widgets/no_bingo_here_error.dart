import 'package:bingo/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NoBingoHereError extends StatelessWidget {
  const NoBingoHereError({
    required this.error,
    required this.trace,
    super.key,
  });

  final Object? error;
  final StackTrace? trace;

  @override
  Widget build(BuildContext context) {
    if (error != null) debugPrint('$error');
    if (trace != null) debugPrint('$trace');

    return ShadResponsiveBuilder(
      builder: (context, breakpoint) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 60,
          children: [
            Text(
              'Pas de bingo ici',
              textAlign: TextAlign.center,
              style: breakpoint <= ShadTheme.of(context).breakpoints.sm
                  ? ShadTheme.of(context).textTheme.h2
                  : ShadTheme.of(context).textTheme.h1Large,
            ),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                width: breakpoint <= ShadTheme.of(context).breakpoints.sm ? 200 : 300,
                height: breakpoint <= ShadTheme.of(context).breakpoints.sm ? 200 : 300,
                AppAssets.racoon,
              ),
            ),
          ],
        );
      },
    );
  }
}
