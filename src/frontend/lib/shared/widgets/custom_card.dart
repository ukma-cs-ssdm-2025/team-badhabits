// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

/// Custom card widget with consistent styling
class CustomCard extends StatelessWidget {
  const CustomCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.borderRadius,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation,
      color: color,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}

/// Info card with icon and text
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.iconColor,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => CustomCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(
              0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
      ],
    ),
  );
}

/// Statistic card
class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    super.key,
    this.icon,
    this.color,
    this.subtitle,
  });
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).primaryColor;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              if (icon != null) Icon(icon, color: cardColor, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: cardColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Empty state card
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.actionText,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: CustomCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onAction, child: Text(actionText!)),
          ],
        ],
      ),
    ),
  );
}

/// Error card
class ErrorCard extends StatelessWidget {
  const ErrorCard({required this.message, super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => CustomCard(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    ),
  );
}
