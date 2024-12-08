import 'package:bingo/router.dart';
import 'package:bingo/view_models/bingo_list_view_model.dart';
import 'package:bingo/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  void _onShareButtonPressed(BuildContext context, String id) {
    const url = 'bingo.valdum.dev';
    final controller = TextEditingController()..text = 'https://$url/bingo/$id';

    showShadDialog<void>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Partager'),
        child: ShadInput(
          controller: controller,
          suffix: ShadButton.ghost(
            padding: EdgeInsets.zero,
            decoration: const ShadDecoration(
              secondaryBorder: ShadBorder.none,
              secondaryFocusedBorder: ShadBorder.none,
            ),
            icon: const ShadImage.square(
              size: 16,
              LucideIcons.copy,
            ),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: controller.text));

              if (context.mounted) {
                ShadToaster.of(context).show(
                  const ShadToast(
                    description: Text('URL copiée dans le presse-papier.'),
                  ),
                );
                context.pop();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onDeleteButtonPressed(
    BuildContext context,
    WidgetRef ref, {
    required String id,
    required String title,
  }) async {
    final delete = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text('Supprimer $title'),
        description: const Text('Cette action est irreversible'),
        actions: [
          ShadButton.outline(
            child: const Text('Annuler'),
            onPressed: () => context.pop(false),
          ),
          ShadButton(
            child: const Text('Supprimer'),
            onPressed: () => context.pop(true),
          ),
        ],
      ),
    );

    if (delete ?? false) {
      ref.read(bingoListViewModelProvider.notifier).deleteBingo(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnSizes = [120.0, 500.0, 180.0];

    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          ref.watch(bingoListViewModelProvider).maybeWhen(
                data: (_) => Row(
                  children: [
                    ShadButton.secondary(
                      onPressed: () {
                        Supabase.instance.client.auth.signOut();
                        // We pass a value here to force the route to rebuild, not ideal but don't know
                        // how to do otherwise
                        context.goNamed(AppRoute.admin, extra: false);
                      },
                      child: const Text('Se déconnecter'),
                    ),
                    const SizedBox(width: 10),
                    ShadButton(
                      onPressed: () => context.goNamed(AppRoute.bingoNew),
                      icon: const Icon(
                        LucideIcons.plus,
                        size: 16,
                      ),
                      child: const Text('Nouveau'),
                    ),
                  ],
                ),
                orElse: () => const SizedBox(),
              ),
        ],
      ),
      body: Center(
        child: ref.watch(bingoListViewModelProvider).when(
              data: (bingos) => ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: columnSizes.fold(0, (prev, e) => prev + e),
                ),
                child: ShadTable.list(
                  rowSpanBackgroundDecoration: (index) => TableSpanDecoration(
                    border: TableSpanBorder(
                      trailing: index == bingos.length
                          ? BorderSide.none
                          : BorderSide(color: ShadTheme.of(context).colorScheme.border),
                    ),
                  ),
                  columnSpanExtent: (index) => FixedTableSpanExtent(columnSizes[index]),
                  header: const [
                    ShadTableCell.header(
                      child: Text('Création'),
                    ),
                    ShadTableCell.header(
                      child: Text('Nom du bingo'),
                    ),
                    ShadTableCell.header(
                      child: SizedBox(),
                    ),
                  ],
                  children: bingos.map(
                    (bingo) => [
                      ShadTableCell(
                        alignment: Alignment.center,
                        child: Text(DateFormat('dd/MM/yyyy').format(bingo.created)),
                      ),
                      ShadTableCell(
                        child: Text(
                          bingo.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ShadTableCell(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShadButton.ghost(
                              onPressed: () => context.goNamed(AppRoute.bingo, pathParameters: {'id': bingo.id}),
                              icon: const Icon(
                                LucideIcons.eye,
                                size: 18,
                              ),
                            ),
                            ShadButton.ghost(
                              onPressed: () => _onShareButtonPressed(context, bingo.id),
                              icon: const Icon(
                                LucideIcons.forward,
                                size: 18,
                              ),
                            ),
                            ShadButton.ghost(
                              onPressed: () => _onDeleteButtonPressed(context, ref, id: bingo.id, title: bingo.title),
                              icon: const Icon(
                                LucideIcons.trash,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              error: (error, stackTrace) {
                debugPrint('$stackTrace');
                return Text('$error');
              },
              loading: CircularProgressIndicator.new,
            ),
      ),
    );
  }
}
