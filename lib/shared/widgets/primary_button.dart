import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final IconData? icon;
  final double? height;
  final double? borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.icon,
    this.height,
    this.borderRadius,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = widget.loading || !widget.enabled || widget.onPressed == null;

    return GestureDetector(
      onTapDown: (_) => !disabled ? setState(() => _pressed = true) : null,
      onTapCancel: () => !disabled ? setState(() => _pressed = false) : null,
      onTapUp: (_) => !disabled ? setState(() => _pressed = false) : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _pressed ? 0.98 : 1.0,
        child: SizedBox(
          width: double.infinity,
          height: widget.height ?? 56,
          child: FilledButton(
            onPressed: disabled ? null : widget.onPressed,
            style: theme.filledButtonTheme.style?.copyWith(
              shape: widget.borderRadius != null 
                  ? WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius!)))
                  : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.loading
                  ? SizedBox(
                      key: const ValueKey("loading"),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Row(
                      key: const ValueKey("text"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(widget.text),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
