import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:universal_html/html.dart' as html;

class EnhancedShadButton extends StatelessWidget {
  const EnhancedShadButton({
    super.key,
    this.icon,
    this.child,
    this.padding,
    this.onPressed,
    this.middleClickPath,
  }) : _variant = ShadButtonVariant.primary;

  const EnhancedShadButton.ghost({
    super.key,
    this.icon,
    this.child,
    this.padding,
    this.onPressed,
    this.middleClickPath,
  }) : _variant = ShadButtonVariant.ghost;

  const EnhancedShadButton.link({
    super.key,
    this.child,
    this.padding,
    this.onPressed,
    this.middleClickPath,
  }) : _variant = ShadButtonVariant.link,
       icon = null;

  final Widget? icon;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;
  final String? middleClickPath;
  final ShadButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final widget = switch (_variant) {
      ShadButtonVariant.primary => ShadButton(
        onPressed: onPressed,
        padding: padding,
        leading: icon,
        child: child,
      ),
      ShadButtonVariant.destructive => ShadButton.destructive(
        onPressed: onPressed,
        padding: padding,
        leading: icon,
        child: child,
      ),
      ShadButtonVariant.outline => ShadButton.outline(
        onPressed: onPressed,
        padding: padding,
        leading: icon,
        child: child,
      ),
      ShadButtonVariant.secondary => ShadButton.secondary(
        onPressed: onPressed,
        padding: padding,
        leading: icon,
        child: child,
      ),
      ShadButtonVariant.ghost => ShadButton.ghost(
        onPressed: onPressed,
        padding: padding,
        leading: icon,
        child: child,
      ),
      ShadButtonVariant.link => ShadButton.link(
        onPressed: onPressed,
        padding: padding,
        child: child,
      ),
    };

    if (middleClickPath == null) {
      return widget;
    }
    return GestureDetector(
      onTertiaryTapDown: (_) => html.window.open(middleClickPath!, '_blank'),
      child: widget,
    );
  }
}
