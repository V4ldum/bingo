import 'package:bingo/router.dart';
import 'package:bingo/view_models/bingo_list_view_model.dart';
import 'package:bingo/widgets/bingo_list_sheet.dart';
import 'package:bingo/widgets/custom_app_bar.dart';
import 'package:bingo/widgets/responsive_bingo_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadResponsiveBuilder(
      builder: (context, breakpoint) {
        final targetBreakpoint = ShadTheme.of(context).breakpoints.sm;
        final columnSizes = [
          120.0,
          switch (breakpoint) {
            ShadBreakpointTN() =>
              MediaQuery.of(context).size.width * 0.92 - 200, // Variable width and subtract other columns
            ShadBreakpointSM() => 300.0,
            ShadBreakpointMD() => 450.0,
            ShadBreakpointLG() => 500.0,
            ShadBreakpointXL() => 600.0,
            ShadBreakpointXXL() => 700.0,
          },
          switch (breakpoint) {
            ShadBreakpointTN() => 80.0,
            _ => 180.0,
          },
        ];

        return Scaffold(
          appBar: CustomAppBar(
            actions: [
              ref.watch(bingoListViewModelProvider).maybeWhen(
                    data: (_) {
                      final buttons = [
                        ShadButton.secondary(
                          onPressed: () {
                            Supabase.instance.client.auth.signOut();
                            // We pass a value here to force the route to rebuild, not ideal but don't know
                            // how to do otherwise
                            context.goNamed(AppRoutes.admin, extra: false);
                          },
                          child: breakpoint < targetBreakpoint
                              ? const Expanded(
                                  child: Text('Se déconnecter', textAlign: TextAlign.start),
                                )
                              : const Text('Se déconnecter'),
                        ),
                        ShadButton(
                          onPressed: () => context.goNamed(AppRoutes.bingoNew),
                          icon: const Icon(
                            LucideIcons.plus,
                            size: 16,
                          ),
                          child: breakpoint < targetBreakpoint
                              ? const Expanded(
                                  child: Text('Nouveau', textAlign: TextAlign.start),
                                )
                              : const Text('Nouveau'),
                        ),
                      ];

                      // Normal screen
                      if (breakpoint >= targetBreakpoint) {
                        return Row(spacing: 10, children: buttons);
                      }
                      // Tiny screen
                      return ShadButton.ghost(
                        onPressed: () => showShadSheet<void>(
                          context: context,
                          side: ShadSheetSide.right,
                          builder: (context) => BingoListSheet(buttons: buttons.reversed.toList()),
                        ),
                        icon: const Icon(
                          LucideIcons.menu,
                        ),
                      );
                    },
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
                      children: bingos.map((bingo) {
                        return [
                          ShadTableCell(
                            alignment: Alignment.center,
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(bingo.created),
                              style: const TextStyle(
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          ShadTableCell(
                            child: Text(
                              bingo.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ShadTableCell(
                            alignment: Alignment.centerLeft,
                            child: ResponsiveBingoAction(bingo: bingo, breakpoint: breakpoint),
                          ),
                        ];
                      }),
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
      },
    );
  }
}
