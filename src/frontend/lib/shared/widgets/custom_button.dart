import 'package:flutter/material.dart';

/// Custom button variants
enum CustomButtonType { primary, secondary, outlined, text }

/// Custom button widget with consistent styling
class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  /// Primary button constructor
  const CustomButton.primary({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  }) : type = CustomButtonType.primary;

  /// Secondary button constructor
  const CustomButton.secondary({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  }) : type = CustomButtonType.secondary;

  /// Outlined button constructor
  const CustomButton.outlined({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  }) : type = CustomButtonType.outlined;

  /// Text button constructor
  const CustomButton.text({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  }) : type = CustomButtonType.text;
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    final buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), const SizedBox(width: 8), Text(text)],
          )
        : Text(text);

    final minimumSize = width != null || height != null
        ? Size(width ?? double.infinity, height ?? 48)
        : null;

    switch (type) {
      case CustomButtonType.primary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(minimumSize: minimumSize),
            child: buttonChild,
          ),
        );

      case CustomButtonType.secondary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              minimumSize: minimumSize,
            ),
            child: buttonChild,
          ),
        );

      case CustomButtonType.outlined:
        return SizedBox(
          width: width,
          height: height,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(minimumSize: minimumSize),
            child: buttonChild,
          ),
        );

      case CustomButtonType.text:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: TextButton.styleFrom(minimumSize: minimumSize),
            child: buttonChild,
          ),
        );
    }
  }
}
