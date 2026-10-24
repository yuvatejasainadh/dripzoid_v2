import 'package:flutter/material.dart';
import '../../core/theme/tokens/app_shadows.dart';
import '../../core/theme/tokens/app_shapes.dart';
import '../../core/utils/layout_utils.dart';

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
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
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


// ---------------------------------------------------------------------------
// Component-Level Skeletons for Products, Catalog & Orders
// ---------------------------------------------------------------------------

/// Display mode for [ProductCardSkeleton].
enum ProductCardSkeletonMode { grid, horizontal, compact }

/// Skeleton card accurately matching the geometry, padding, and layout of ProductCard.
class ProductCardSkeleton extends StatelessWidget {
  final ProductCardSkeletonMode mode;

  const ProductCardSkeleton({
    super.key,
    this.mode = ProductCardSkeletonMode.grid,
  });

  @override
  Widget build(BuildContext context) {
    return switch (mode) {
      ProductCardSkeletonMode.grid => _buildGridSkeleton(context),
      ProductCardSkeletonMode.horizontal => _buildHorizontalSkeleton(context),
      ProductCardSkeletonMode.compact => _buildCompactSkeleton(context),
    };
  }

  Widget _buildGridSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        final infoSection = Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(height: 14, width: double.infinity),
                  const SizedBox(height: 6),
                  const SkeletonLine(height: 14, width: 100),
                  const SizedBox(height: 6),
                  SkeletonLine(
                    height: 10,
                    width: 65,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      SkeletonLine(height: 16, width: 55),
                      SizedBox(width: 8),
                      SkeletonLine(height: 12, width: 35),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      SkeletonCircle(size: 12),
                      SizedBox(width: 4),
                      SkeletonLine(height: 10, width: 45),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppShapes.radius16,
            boxShadow: AppShadows.soft(context),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
            children: [
              // Image Section
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: const ShimmerWidget(),
                    ),
                  ),
                  // Wishlist Circle Placeholder
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surface.withValues(alpha: 0.9),
                        boxShadow: AppShadows.tight(context),
                      ),
                      child: const Center(
                        child: SkeletonCircle(size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              // Info Section
              if (hasBoundedHeight)
                Expanded(child: infoSection)
              else
                infoSection,
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorizontalSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppShapes.radius16,
        boxShadow: AppShadows.soft(context),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                child: const ShimmerWidget(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SkeletonLine(height: 15, width: double.infinity),
                        const SizedBox(height: 6),
                        const SkeletonLine(height: 15, width: 120),
                        const SizedBox(height: 6),
                        SkeletonLine(
                          height: 11,
                          width: 70,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SkeletonLine(height: 16, width: 60),
                            SizedBox(width: 8),
                            SkeletonLine(height: 12, width: 40),
                          ],
                        ),
                        SkeletonCircle(size: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Row(
        children: [
          SkeletonImage(width: 50, height: 50, borderRadius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonLine(height: 13, width: double.infinity),
                SizedBox(height: 6),
                SkeletonLine(height: 12, width: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable responsive product grid skeleton for catalog and shop pages.
class ProductGridSkeleton extends StatelessWidget {
  final int? columns;
  final int? itemCount;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const ProductGridSkeleton({
    super.key,
    this.columns,
    this.itemCount,
    this.padding = const EdgeInsets.all(16),
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colCount = columns ?? LayoutUtils.getGridColumnCount(context);
    final count = itemCount ?? (colCount * 2);

    return GridView.builder(
      controller: controller,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colCount,
        childAspectRatio: LayoutUtils.getProductGridRatio(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: count,
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }
}

/// Sliver variant of [ProductGridSkeleton] for use inside [CustomScrollView].
class SliverProductGridSkeleton extends StatelessWidget {
  final int? columns;
  final int? itemCount;
  final double spacing;

  const SliverProductGridSkeleton({
    super.key,
    this.columns,
    this.itemCount,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colCount = columns ?? LayoutUtils.getGridColumnCount(context);
    final count = itemCount ?? (colCount * 2);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colCount,
        childAspectRatio: LayoutUtils.getProductGridRatio(context),
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ProductCardSkeleton(),
        childCount: count,
      ),
    );
  }
}

/// Full screen skeleton specifically mirroring ProductDetailsScreen layout.
class ProductDetailsSkeleton extends StatelessWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = LayoutUtils.isDesktop(context);

    final gallerySkeleton = Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
      ),
      child: Stack(
        children: [
          SizedBox(
            height: isDesktop ? 460 : 400,
            width: double.infinity,
            child: const ShimmerWidget(),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: SkeletonCircle(size: 22)),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: SkeletonCircle(size: 22)),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final detailsContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Rating Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(height: 22, width: double.infinity),
                  SizedBox(height: 6),
                  SkeletonLine(height: 22, width: 180),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SkeletonBox(width: 48, height: 26, borderRadius: BorderRadius.circular(4)),
          ],
        ),
        const SizedBox(height: 8),

        // Subcategory / Category
        const SkeletonLine(height: 14, width: 120),
        const SizedBox(height: 16),

        // Price, Strikethrough, Discount Badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SkeletonLine(height: 28, width: 90),
            const SizedBox(width: 12),
            const SkeletonLine(height: 18, width: 60),
            const SizedBox(width: 8),
            SkeletonBox(width: 68, height: 22, borderRadius: BorderRadius.circular(4)),
          ],
        ),
        const SizedBox(height: 24),

        // Stock Badge
        SkeletonBox(width: 120, height: 28, borderRadius: BorderRadius.circular(14)),
        const SizedBox(height: 24),

        // Color Picker Placeholder
        const SkeletonLine(height: 16, width: 90),
        const SizedBox(height: 12),
        const Row(
          children: [
            SkeletonCircle(size: 36),
            SizedBox(width: 12),
            SkeletonCircle(size: 36),
            SizedBox(width: 12),
            SkeletonCircle(size: 36),
          ],
        ),
        const SizedBox(height: 24),

        // Size Picker Placeholder
        const SkeletonLine(height: 16, width: 85),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SkeletonBox(
                width: 48,
                height: 42,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Quantity Selector Placeholder
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonLine(height: 16, width: 75),
            SkeletonLine(height: 12, width: 85),
          ],
        ),
        const SizedBox(height: 12),
        SkeletonBox(width: 130, height: 42, borderRadius: BorderRadius.circular(8)),
        const SizedBox(height: 32),

        // Delivery Check Placeholder
        const SkeletonLine(height: 16, width: 140),
        const SizedBox(height: 12),
        SkeletonBox(height: 52, borderRadius: BorderRadius.circular(12)),
        const SizedBox(height: 32),

        // Accordion Sections (3 items)
        ...List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(height: 16, width: 130),
                SkeletonBox(
                  width: 18,
                  height: 18,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const SkeletonLine(height: 18, width: 160),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: ResponsiveContainer(
          child: isDesktop
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: gallerySkeleton),
                      const SizedBox(width: 32),
                      Expanded(flex: 7, child: detailsContent),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    gallerySkeleton,
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: detailsContent,
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: ResponsiveContainer.bottomBar(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: const Row(
            children: [
              Expanded(child: SkeletonButton(height: 52, borderRadius: 12)),
              SizedBox(width: 12),
              Expanded(child: SkeletonButton(height: 52, borderRadius: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Component Skeleton: Order Item Tile matching OrderItemTile layout
class OrderItemTileSkeleton extends StatelessWidget {
  const OrderItemTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Row(
        children: [
          SkeletonImage(width: 70, height: 85, borderRadius: 10),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(height: 15, width: 180),
                SizedBox(height: 8),
                SkeletonLine(height: 12, width: 100),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLine(height: 14, width: 60),
                    SkeletonLine(height: 12, width: 40),
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

/// Component Skeleton: Order Status Hero matching OrderStatusHero
class OrderStatusHeroSkeleton extends StatelessWidget {
  const OrderStatusHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonCircle(size: 28),
              SkeletonBox(
                width: 100,
                height: 26,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ],
          ),
          SizedBox(height: 18),
          SkeletonLine(height: 22, width: 190),
          SizedBox(height: 8),
          SkeletonLine(height: 14, width: 240),
        ],
      ),
    );
  }
}

/// Component Skeleton: Order Info Card matching OrderInfoCard
class OrderInfoCardSkeleton extends StatelessWidget {
  const OrderInfoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(height: 11, width: 45),
              SizedBox(height: 6),
              SkeletonLine(height: 15, width: 85),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(height: 11, width: 40),
              SizedBox(height: 6),
              SkeletonLine(height: 15, width: 75),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(height: 11, width: 50),
              SizedBox(height: 6),
              SkeletonLine(height: 15, width: 65),
            ],
          ),
        ],
      ),
    );
  }
}

/// Component Skeleton: Order History Card matching OrderHistoryCard
class OrderHistoryCardSkeleton extends StatelessWidget {
  const OrderHistoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(height: 16, width: 110),
                  SizedBox(height: 4),
                  SkeletonLine(height: 12, width: 70),
                ],
              ),
              SkeletonBox(
                width: 80,
                height: 26,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              SkeletonImage(width: 60, height: 70, borderRadius: 10),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(height: 15, width: 170),
                    SizedBox(height: 6),
                    SkeletonLine(height: 12, width: 90),
                    SizedBox(height: 8),
                    SkeletonLine(height: 14, width: 60),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLine(height: 12, width: 100),
              SkeletonBox(
                width: 100,
                height: 32,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Full screen skeleton specifically mirroring OrderDetailsScreen layout.
class OrderDetailsSkeleton extends StatelessWidget {
  const OrderDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const OrderStatusHeroSkeleton(),
              const SizedBox(height: 24),
              const OrderInfoCardSkeleton(),
              const SizedBox(height: 24),

              // Items Section Title
              const SkeletonLine(height: 18, width: 90),
              const SizedBox(height: 16),
              const OrderItemTileSkeleton(),
              const OrderItemTileSkeleton(),
              const SizedBox(height: 24),

              // Delivery Address Section Title
              const SkeletonLine(height: 18, width: 140),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonCircle(size: 18),
                        SizedBox(width: 12),
                        SkeletonLine(height: 16, width: 140),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    SkeletonLine(height: 14, width: double.infinity),
                    SizedBox(height: 6),
                    SkeletonLine(height: 14, width: 220),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        SkeletonCircle(size: 14),
                        SizedBox(width: 8),
                        SkeletonLine(height: 12, width: 100),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tracking Section Title
              const SkeletonLine(height: 18, width: 80),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index < 2 ? 16 : 0),
                      child: const Row(
                        children: [
                          SkeletonCircle(size: 16),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonLine(height: 14, width: 130),
                                SizedBox(height: 4),
                                SkeletonLine(height: 11, width: 85),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Summary Section Title
              const SkeletonLine(height: 18, width: 140),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonLine(height: 14, width: 80),
                        SkeletonLine(height: 14, width: 50),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonLine(height: 14, width: 65),
                        SkeletonLine(height: 14, width: 45),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonLine(height: 18, width: 90),
                        SkeletonLine(height: 18, width: 65),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Action buttons placeholders
              const SkeletonButton(height: 54, borderRadius: 12),
              const SizedBox(height: 16),
              const SkeletonButton(height: 54, borderRadius: 12),
              const SizedBox(height: 60),
            ]),
          ),
        ),
      ],
    );
  }
}
