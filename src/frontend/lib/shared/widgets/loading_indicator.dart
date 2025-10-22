// ignore_for_file: deprecated_member_use, discarded_futures

import 'package:flutter/material.dart';

/// Custom loading indicator widget
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message, this.size = 40, this.color});

  /// Small loading indicator
  const LoadingIndicator.small({super.key, this.message, this.color})
    : size = 24;

  /// Large loading indicator
  const LoadingIndicator.large({super.key, this.message, this.color})
    : size = 60;
  final String? message;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: size / 10,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
          SizedBox(height: size / 4),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  );
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.child,
    super.key,
    this.isLoading = false,
    this.message,
  });
  final String? message;
  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      if (isLoading)
        ColoredBox(
          color: Colors.black.withOpacity(0.5),
          child: LoadingIndicator(message: message),
        ),
    ],
  );
}

/// Adaptive loading widget - shows different loading states
class AdaptiveLoading extends StatelessWidget {
  const AdaptiveLoading({
    required this.isLoading,
    required this.child,
    super.key,
    this.loadingWidget,
  });
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const LoadingIndicator();
    }
    return child;
  }
}

/// Linear progress indicator for top of screen
class LinearLoadingIndicator extends StatelessWidget {
  const LinearLoadingIndicator({
    required this.isLoading,
    super.key,
    this.color,
  });
  final bool isLoading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? Theme.of(context).primaryColor,
      ),
    );
  }
}

/// Shimmer loading effect for lists
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius,
  });

  /// Rectangular shimmer
  const ShimmerLoading.rectangular({
    required this.width,
    required this.height,
    super.key,
  }) : borderRadius = null;

  /// Circular shimmer
  const ShimmerLoading.circular({required double size, super.key})
    : width = size,
      height = size,
      borderRadius = null;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment(_animation.value, 0),
            colors: [baseColor, highlightColor, baseColor],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

/// List of shimmer items for loading state
class ShimmerListLoading extends StatelessWidget {
  const ShimmerListLoading({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });
  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: itemCount,
    itemBuilder: (context, index) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const ShimmerLoading.circular(size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
