import 'package:flutter/material.dart';

/// Themed text field wrapper — flexible parameter naming (label/labelText, hint/hintText,
/// and prefixIcon as Widget or IconData).
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? hintText;
  final String? label;
  final String? labelText;
  final dynamic prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.hintText,
    this.label,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.focusNode,
    this.validator,
    this.fillColor,
    this.contentPadding,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget? prefix;
    if (prefixIcon is IconData) {
      prefix = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(prefixIcon as IconData, size: 22, color: scheme.primary),
      );
    } else if (prefixIcon is Widget) {
      prefix = prefixIcon as Widget;
    }

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint ?? hintText,
        labelText: label ?? labelText,
        fillColor: fillColor,
        contentPadding: contentPadding,
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
