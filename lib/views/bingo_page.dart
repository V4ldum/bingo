import 'package:bingo/constants/app_assets.dart';
import 'package:bingo/models/bingo.dart';
import 'package:bingo/router.dart';
import 'package:bingo/utils/image_downloader.dart';
import 'package:bingo/view_models/bingo_view_model.dart';
import 'package:bingo/widgets/bingo_table.dart';
import 'package:bingo/widgets/custom_app_bar.dart';
import 'package:bingo/widgets/no_bingo_here_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rust/rust.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BingoPage extends ConsumerWidget {
  const BingoPage({
    required this.id,
    super.key,
  });

  final String id;

  Future<void> _onDownloadButtonPressed(BuildContext context, Bingo bingo) async {
    final downloaded = await ImageDownloader.downloadAsImage(bingo);

    if (!downloaded) {
      if (context.mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            description: Text('Echec du téléchargement'),
          ),
        );
      }
    }
  }

  void _onCellTapped(WidgetRef ref, String bingoItemId) {
    ref.read(bingoViewModelProvider(id).notifier).checkBingoItem(bingoItemId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          if (Supabase.instance.client.auth.currentSession != null)
            ref.read(bingoViewModelProvider(id)).maybeWhen(
                  data: (_) => ShadButton(
                    onPressed: () => context.goNamed(AppRoutes.bingoEdit, pathParameters: {'id': id}),
                    icon: const Icon(
                      LucideIcons.pencil,
                      size: 16,
                    ),
                    child: const Text('Modifier'),
                  ),
                  orElse: () => const SizedBox(),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: ref.watch(bingoViewModelProvider(id)).when(
              data: (bingo) => SingleChildScrollView(
                child: ShadResponsiveBuilder(
                  builder: (context, breakpoint) => Column(
                    children: [
                      Text(
                        bingo.title,
                        textAlign: TextAlign.center,
                        style: breakpoint <= ShadTheme.of(context).breakpoints.sm
                            ? ShadTheme.of(context).textTheme.h2
                            : ShadTheme.of(context).textTheme.h1Large,
                      ),
                      const SizedBox(height: 60),
                      Center(
                        child: RepaintBoundary(
                          key: ImageDownloader.downloadKey,
                          child: BingoTable(
                            bingo: bingo,
                            onCellTapped: Supabase.instance.client.auth.currentSession != null
                                ? (i) {
                                    final item = Option.of(bingo.items.elementAtOrNull(i));
                                    if (item case Some(:final v)) {
                                      _onCellTapped(ref, v.id);
                                    }
                                  }
                                : null,
                            itemBuilder: (i) {
                              final item = Option.of(bingo.items.elementAtOrNull(i));

                              return item.mapOrElse(
                                () => const SizedBox(),
                                (item) => Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      item.text,
                                      textAlign: TextAlign.center,
                                      style: switch (breakpoint) {
                                        _ when (bingo.size < 3) => ShadTheme.of(context).textTheme.large,
                                        ShadBreakpointTN() => ShadTheme.of(context).textTheme.small.copyWith(
                                              // arbitrary dynamic font size for tiny screens
                                              fontSize: MediaQuery.of(context).size.width / 45,
                                            ),
                                        ShadBreakpointSM() =>
                                          ShadTheme.of(context).textTheme.p.copyWith(fontWeight: FontWeight.w600),
                                        _ => ShadTheme.of(context).textTheme.large,
                                      }
                                          .copyWith(color: ShadTheme.of(context).colorScheme.primaryForeground),
                                    ),
                                    if (item.isChecked)
                                      Image.asset(
                                        AppAssets.bingoCross,
                                        opacity: const AlwaysStoppedAnimation(0.8),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ShadButton.outline(
                        onPressed: () => _onDownloadButtonPressed(context, bingo),
                        icon: const Icon(
                          LucideIcons.download,
                          size: 16,
                        ),
                        child: const Text('Télécharger'),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, trace) => NoBingoHereError(error: error, trace: trace),
            ),
      ),
    );
  }
}
