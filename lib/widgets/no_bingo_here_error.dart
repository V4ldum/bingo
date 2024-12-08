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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pas de bingo ici',
          textAlign: TextAlign.center,
          style: ShadTheme.of(context).textTheme.h1Large,
        ),
        const SizedBox(height: 60),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const ShadImage.square(
            AppAssets.racoon,
            size: 300,
          ),
        ),
      ],
    );
  }
}
