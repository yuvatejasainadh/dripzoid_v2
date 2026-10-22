import 'package:flutter/material.dart';

/// Reusable shimmer base widget supporting custom shapes and theme-aware colors.
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerWidget({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.shapeBorder = const RoundedRectangleBorder(),
    this.borderRadius,
    this.margin,
  });

  const ShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
    this.margin,
  }) : shapeBorder = const RoundedRectangleBorder();

  const ShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
    this.margin,
  })  : shapeBorder = const CircleBorder(),
        borderRadius = null;

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
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

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-derived subtle base and highlight colors
    final baseColor = isDark
        ? const Color(0xFF181818)
        : const Color(0xFFEBEBEB);
    final highlightColor = isDark
        ? const Color(0xFF282828)
        : const Color(0xFFF7F7F7);

    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final shape = widget.borderRadius != null
        ? RoundedRectangleBorder(borderRadius: widget.borderRadius!)
        : widget.shapeBorder;

    if (disableAnimations) {
      return Semantics(
        excludeSemantics: true,
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: ShapeDecoration(
            color: baseColor,
            shape: shape,
          ),
        ),
      );
    }

    return Semantics(
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            decoration: ShapeDecoration(
              shape: shape,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: [
                  0.0,
                  ((_animation.value + 1) / 2).clamp(0.0, 1.0),
                  1.0,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Primitive: SkeletonBox for rectangular or rounded blocks
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget.rectangular(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      margin: margin,
    );
  }
}

/// Primitive: SkeletonLine for text line placeholders
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget.rectangular(
      width: width ?? double.infinity,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      margin: margin,
    );
  }
}

/// Primitive: SkeletonCircle for avatars, radios, icons
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({
    super.key,
    required this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget.circular(
      width: size,
      height: size,
      margin: margin,
    );
  }
}

/// Primitive: SkeletonImage for product & item images
class SkeletonImage extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonImage({
    super.key,
    this.width = 90,
    this.height = 110,
    this.borderRadius = 12,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius),
      margin: margin,
    );
  }
}

/// Primitive: SkeletonButton for action buttons
class SkeletonButton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonButton({
    super.key,
    this.width = double.infinity,
    this.height = 54,
    this.borderRadius = 12,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius),
      margin: margin,
    );
  }
}

// ---------------------------------------------------------------------------
// Component-Level Skeletons for Checkout & Cart
// ---------------------------------------------------------------------------

/// Component Skeleton: Cart item tile matching CartItemTile layout
class CartItemTileSkeleton extends StatelessWidget {
  const CartItemTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonImage(width: 90, height: 110, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonLine(width: 140, height: 16),
                    SkeletonCircle(size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                const SkeletonLine(width: 90, height: 12),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonLine(width: 60, height: 18),
                    SkeletonBox(
                      width: 80,
                      height: 30,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Component Skeleton: Address card matching AddressCard layout
class AddressCardSkeleton extends StatelessWidget {
  const AddressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: SkeletonCircle(size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 80, height: 16),
                const SizedBox(height: 8),
                const SkeletonLine(width: double.infinity, height: 13),
                const SizedBox(height: 6),
                const SkeletonLine(width: 180, height: 13),
                const SizedBox(height: 8),
                const SkeletonLine(width: 110, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Component Skeleton: Payment option matching checkout payment options
class PaymentOptionSkeleton extends StatelessWidget {
  const PaymentOptionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          SkeletonBox(
            width: 28,
            height: 28,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 160, height: 16),
                SizedBox(height: 6),
                SkeletonLine(width: 220, height: 12),
              ],
            ),
          ),
          const SkeletonCircle(size: 22),
        ],
      ),
    );
  }
}

/// Component Skeleton: Order summary breakdown card
class OrderSummarySkeleton extends StatelessWidget {
  const OrderSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLine(width: 130, height: 18),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLine(width: 90, height: 14),
              SkeletonLine(width: 50, height: 14),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLine(width: 110, height: 14),
              SkeletonLine(width: 40, height: 14),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLine(width: 70, height: 14),
              SkeletonLine(width: 50, height: 14),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLine(width: 90, height: 18),
              SkeletonLine(width: 70, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

/// Full screen skeleton for Cart loading state
class CartScreenSkeleton extends StatelessWidget {
  const CartScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => const CartItemTileSkeleton(),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLine(width: 100, height: 16),
                  SkeletonLine(width: 70, height: 20),
                ],
              ),
              SizedBox(height: 16),
              SkeletonButton(height: 54),
            ],
          ),
        ),
      ],
    );
  }
}
