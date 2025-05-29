import 'package:bingo/constants/app_assets.dart';
import 'package:bingo/router.dart';
import 'package:bingo/view_models/edit_bingo_view_model.dart';
import 'package:bingo/widgets/bingo_table.dart';
import 'package:bingo/widgets/custom_app_bar.dart';
import 'package:bingo/widgets/no_bingo_here_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rust/rust.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BingoEditPage extends ConsumerWidget {
  const BingoEditPage({
    this.id,
    super.key,
  });

  final String? id;

  Future<void> _onCreateButtonPressed(BuildContext context, WidgetRef ref) async {
    final state = Option.of(ref.read(editBingoViewModelProvider(id: id)).value);

    if (state case Some(:final v)) {
      if (v.title.isEmpty) {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Titre manquant'),
            description: Text('Veuillez entrer un titre pour votre bingo.'),
          ),
        );
        return;
      }

      await ref.read(editBingoViewModelProvider(id: id).notifier).editBingo();
      if (!ref.read(editBingoViewModelProvider(id: id)).hasError && context.mounted) {
        context.goNamed(AppRoutes.admin);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Refresh only if loading or size changed
    ref.watch(
      editBingoViewModelProvider(id: id).select((bingo) => (bingo.isLoading, bingo.valueOrNull?.size)),
    );

    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          ref
              .read(editBingoViewModelProvider(id: id))
              .maybeWhen(
                data: (_) => ShadButton(
                  onPressed: () => _onCreateButtonPressed(context, ref),
                  leading: Icon(
                    id != null ? LucideIcons.pencil : LucideIcons.plus,
                    size: 16,
                  ),
                  child: id != null ? const Text('Mettre à jour') : const Text('Créer'),
                ),
                orElse: () => const SizedBox(),
              ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: ref
            .read(editBingoViewModelProvider(id: id))
            .when(
              data: (bingo) => Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: ShadInput(
                      initialValue: bingo.title,
                      placeholder: const Text('Titre du bingo'),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => ref.read(editBingoViewModelProvider(id: id).notifier).title(value),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ShadDatePicker(
                    selected: bingo.created,
                    onChanged: ref.read(editBingoViewModelProvider(id: id).notifier).date,
                    closeOnSelection: true,
                    allowDeselection: false,
                    formatDate: (date) => DateFormat.yMMMMd('fr-FR').format(date),
                  ),
                  const SizedBox(height: 10),
                  ShadSelect<int>(
                    initialValue: bingo.size,
                    selectedOptionBuilder: (_, value) => Text('${value}x$value'),
                    onChanged: (value) => ref.read(editBingoViewModelProvider(id: id).notifier).size(value!),
                    options: const [
                      ShadOption(value: 5, child: Text('5x5')),
                      ShadOption(value: 4, child: Text('4x4')),
                      ShadOption(value: 3, child: Text('3x3')),
                      ShadOption(value: 1, child: Text('1x1')),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ShadResponsiveBuilder(
                      builder: (context, breakpoint) {
                        return BingoTable(
                          bingo: bingo,
                          cellPadding: EdgeInsets.zero,
                          itemBuilder: (i) {
                            final item = bingo.items.elementAtOrNull(i);

                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                // Avoid issue with rebuild optimization showing wrong UI
                                SizedBox.expand(
                                  key: item != null ? Key(item.id) : null,
                                  child: ShadInput(
                                    initialValue: item?.text,
                                    cursorColor: ShadTheme.of(context).colorScheme.primaryForeground,
                                    textAlign: TextAlign.center,
                                    maxLines: null,
                                    padding: EdgeInsets.zero,
                                    decoration: ShadDecoration(
                                      border: ShadBorder.none,
                                      shape: BoxShape.rectangle,
                                      focusedBorder: ShadBorder.fromBorderSide(
                                        ShadBorderSide(
                                          color: ShadTheme.of(context).colorScheme.mutedForeground,
                                          width: 3,
                                          strokeAlign: BorderSide.strokeAlignOutside,
                                        ),
                                      ),
                                    ),
                                    style: switch (breakpoint) {
                                      _ when (bingo.size < 3) => ShadTheme.of(context).textTheme.large,
                                      ShadBreakpointTN() => ShadTheme.of(context).textTheme.small.copyWith(
                                        // arbitrary dynamic font size for tiny screens
                                        fontSize: MediaQuery.of(context).size.width / 45,
                                      ),
                                      ShadBreakpointSM() => ShadTheme.of(
                                        context,
                                      ).textTheme.p.copyWith(fontWeight: FontWeight.w600),
                                      _ => ShadTheme.of(context).textTheme.large,
                                    }.copyWith(color: ShadTheme.of(context).colorScheme.primaryForeground),
                                    onChanged: (value) => ref
                                        .read(editBingoViewModelProvider(id: id).notifier)
                                        .cell(value: value, index: i),
                                  ),
                                ),
                                if (item != null && item.isChecked)
                                  IgnorePointer(
                                    child: Image.asset(
                                      AppAssets.bingoCross,
                                      opacity: const AlwaysStoppedAnimation(0.8),
                                      width: 40,
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  ShadIconButton.outline(
                    onPressed: ref.read(editBingoViewModelProvider(id: id).notifier).shuffle,
                    icon: const Icon(
                      LucideIcons.shuffle,
                      size: 16,
                    ),
                  ),
                ],
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
