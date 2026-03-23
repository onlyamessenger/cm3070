import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isDestructive;

  const AdminButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isDestructive = false,
  });

  @override
  State<AdminButton> createState() => _AdminButtonState();
}

class _AdminButtonState extends State<AdminButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isDestructive
        ? AdminColors.error
        : widget.isPrimary
        ? AdminColors.primary
        : Colors.transparent;
    final Color fgColor = widget.isDestructive
        ? AdminColors.onSurface
        : widget.isPrimary
        ? AdminColors.background
        : AdminColors.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isHovered && widget.isPrimary && !widget.isDestructive
              ? <BoxShadow>[const BoxShadow(color: AdminColors.primaryGlow, blurRadius: 10, offset: Offset(0, 2))]
              : null,
        ),
        child: widget.isPrimary
            ? ElevatedButton.icon(
                onPressed: widget.onPressed,
                icon: widget.icon != null ? Icon(widget.icon, size: 18) : const SizedBox.shrink(),
                label: Text(widget.label),
                style: ElevatedButton.styleFrom(backgroundColor: bgColor, foregroundColor: fgColor),
              )
            : OutlinedButton.icon(
                onPressed: widget.onPressed,
                icon: widget.icon != null ? Icon(widget.icon, size: 18) : const SizedBox.shrink(),
                label: Text(widget.label),
              ),
      ),
    );
  }
}
