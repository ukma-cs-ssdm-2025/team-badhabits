import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom text field widget with consistent styling
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
  });
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    var suffixIcon = widget.suffixIcon;

    // Add toggle visibility icon for password fields
    if (widget.obscureText && suffixIcon == null) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      inputFormatters: widget.inputFormatters,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Email text field
class EmailTextField extends StatelessWidget {
  const EmailTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
  });
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => CustomTextField(
    controller: controller,
    labelText: labelText ?? 'Email',
    hintText: hintText ?? 'your.email@example.com',
    prefixIcon: Icons.email_outlined,
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    validator:
        validator ??
        (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
    onChanged: onChanged,
  );
}

/// Password text field
class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.textInputAction,
  });
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) => CustomTextField(
    controller: controller,
    labelText: labelText ?? 'Password',
    hintText: hintText ?? 'Enter your password',
    prefixIcon: Icons.lock_outlined,
    obscureText: true,
    textInputAction: textInputAction ?? TextInputAction.done,
    validator:
        validator ??
        (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
    onChanged: onChanged,
  );
}

/// Search text field
class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
  });
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => CustomTextField(
    controller: controller,
    hintText: hintText ?? 'Search...',
    prefixIcon: Icons.search,
    suffixIcon: controller?.text.isNotEmpty ?? false
        ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller?.clear();
              onClear?.call();
            },
          )
        : null,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
  );
}
