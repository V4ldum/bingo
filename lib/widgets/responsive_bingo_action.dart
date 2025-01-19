import 'package:bingo/models/bingo.dart';
import 'package:bingo/router.dart';
import 'package:bingo/view_models/bingo_list_view_model.dart';
import 'package:bingo/widgets/enhanced_shad_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ResponsiveBingoAction extends ConsumerStatefulWidget {
  const ResponsiveBingoAction({
    required this.bingo,
    required this.breakpoint,
    super.key,
  });

  final Bingo bingo;
  final ShadBreakpoint breakpoint;

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
            icon: const Icon(
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
  ConsumerState<ResponsiveBingoAction> createState() => _ResponsiveBingoActionState();
}

class _ResponsiveBingoActionState extends ConsumerState<ResponsiveBingoAction> {
  final controller = ShadPopoverController();
  @override
  Widget build(BuildContext context) {
    final targetBreakpoint = ShadTheme.of(context).breakpoints.sm;
    final buttons = [
      EnhancedShadButton.ghost(
        middleClickPath: '${AppRoute.bingo}/${widget.bingo.id}',
        onPressed: () => context.goNamed(AppRoute.bingo, pathParameters: {'id': widget.bingo.id}),
        icon: const Icon(
          LucideIcons.eye,
          size: 18,
        ),
        child: widget.breakpoint < targetBreakpoint
            ? const Expanded(
                child: Text('Voir le bingo', textAlign: TextAlign.start),
              )
            : null,
      ),
      ShadButton.ghost(
        onPressed: () {
          if (widget.breakpoint < targetBreakpoint) {
            controller.toggle();
          }
          widget._onShareButtonPressed(context, widget.bingo.id);
        },
        icon: const Icon(
          LucideIcons.forward,
          size: 18,
        ),
        child: widget.breakpoint < targetBreakpoint
            ? const Expanded(
                child: Text('Partager', textAlign: TextAlign.start),
              )
            : null,
      ),
      ShadButton.ghost(
        onPressed: () => widget._onDeleteButtonPressed(context, ref, id: widget.bingo.id, title: widget.bingo.title),
        icon: const Icon(
          LucideIcons.trash,
          size: 18,
        ),
        child: widget.breakpoint < targetBreakpoint
            ? const Expanded(
                child: Text('Supprimer', textAlign: TextAlign.start),
              )
            : null,
      ),
    ];

    // Normal screen
    if (widget.breakpoint >= targetBreakpoint) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: buttons,
      );
    }
    // Tiny screen
    return ShadPopover(
      controller: controller,
      popover: (context) => SizedBox(
        width: 148,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: buttons,
        ),
      ),
      child: ShadButton.ghost(
        onPressed: controller.toggle,
        icon: const Icon(
          LucideIcons.ellipsisVertical,
          size: 18,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
