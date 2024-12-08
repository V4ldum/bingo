import 'package:bingo/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.actions = const [],
  });

  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: ShadButton.link(
        padding: EdgeInsets.zero,
        onPressed: () => context.goNamed(AppRoute.admin),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 5, left: 5),
              child: Icon(LucideIcons.bot),
            ),
            const SizedBox(width: 18),
            Text(
              'Bingo Builder',
              style: ShadTheme.of(context).textTheme.large.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        ...actions,
        const SizedBox(width: 5),
      ],
    );
  }
}
