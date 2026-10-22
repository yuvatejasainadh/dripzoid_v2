import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens/app_shadows.dart';
import '../../core/theme/tokens/app_shapes.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'shimmer_loading.dart';

enum ProductCardMode { grid, horizontal, compact }

class ProductCard extends ConsumerStatefulWidget {
  final ProductModel product;
  final ProductCardMode mode;
  final VoidCallback? onWishlistToggle;
  final bool isWishlisted;
  final bool showWishlist;
  final bool showRating;
  final bool showDiscount;
  final bool showStock;
  final String heroSuffix;

  const ProductCard({
    super.key,
    required this.product,
    this.mode = ProductCardMode.grid,
    this.onWishlistToggle,
    this.isWishlisted = false,
    this.showWishlist = true,
    this.showRating = true,
    this.showDiscount = true,
    this.showStock = true,
    this.heroSuffix = '',
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isPressed = false;

  void _onTap() => context.pushNamed('product', pathParameters: {'id': widget.product.id});

  @override
  Widget build(BuildContext context) {
    final bool wishlisted = ref.watch(wishlistProvider.select((s) => s.isWishlisted(widget.product.id)));

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: _isPressed ? 0.97 : 1.0,
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _onTap,
        child: _buildCard(wishlisted),
      ),
    );
  }

  Widget _buildCard(bool wishlisted) {
    return switch (widget.mode) {
      ProductCardMode.grid => _GridCard(
          product: widget.product,
          onWishlistToggle: () => ref.read(wishlistProvider.notifier).toggleWishlist(widget.product.id),
          isWishlisted: wishlisted,
          showWishlist: widget.showWishlist,
          showRating: widget.showRating,
          showDiscount: widget.showDiscount,
          showStock: widget.showStock,
          heroSuffix: widget.heroSuffix,
        ),
      ProductCardMode.horizontal => _HorizontalCard(
          product: widget.product,
          onWishlistToggle: () => ref.read(wishlistProvider.notifier).toggleWishlist(widget.product.id),
          isWishlisted: wishlisted,
          showWishlist: widget.showWishlist,
          showRating: widget.showRating,
          showDiscount: widget.showDiscount,
          showStock: widget.showStock,
          heroSuffix: widget.heroSuffix,
        ),
      ProductCardMode.compact => _CompactCard(
          product: widget.product,
        ),
    };
  }
}

class _GridCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onWishlistToggle;
  final bool isWishlisted;
  final bool showWishlist;
  final bool showRating;
  final bool showDiscount;
  final bool showStock;
  final String heroSuffix;

  const _GridCard({
    required this.product,
    this.onWishlistToggle,
    required this.isWishlisted,
    required this.showWishlist,
    required this.showRating,
    required this.showDiscount,
    required this.showStock,
    required this.heroSuffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        children: [
          // Image Section
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Hero(
                  tag: 'product_${product.id}${heroSuffix.isNotEmpty ? '_$heroSuffix' : ''}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: product.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.images.first,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            placeholder: (context, url) => const ShimmerWidget(),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(Icons.broken_image_outlined, color: colorScheme.outline),
                            ),
                          )
                        : Center(child: Icon(Icons.image_outlined, color: colorScheme.outline)),
                  ),
                ),
              ),
              // Discount Badge
              if (showDiscount && product.hasDiscount)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: AppShapes.radius8,
                    ),
                    child: Text(
                      '${product.discountPercentage.round()}% OFF',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              // Wishlist Button
              if (showWishlist)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Hero(
                    tag: 'wishlist_${product.id}${heroSuffix.isNotEmpty ? '_$heroSuffix' : ''}',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onWishlistToggle,
                        borderRadius: AppShapes.radiusFull,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surface.withValues(alpha: 0.9),
                            boxShadow: AppShadows.tight(context),
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isWishlisted ? Colors.red : colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Info Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.subcategory ?? product.category ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '₹${product.price.round()}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                            ),
                          ),
                          if (product.hasDiscount)
                            Text(
                              '₹${product.originalPrice?.round()}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: colorScheme.onSurface.withValues(alpha: 0.4),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      if (showRating) ...[
                        const SizedBox(height: 4),
                        _RatingRow(product: product),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final ProductModel product;
  const _RatingRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final rating = product.rating ?? 0.0;
    final reviewsCount = product.reviews.length;

    if (rating == 0 || reviewsCount == 0) {
      return Text(
        'No reviews yet',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 14.0, color: Colors.amber),
        const SizedBox(width: 2.0),
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 4.0),
        Text(
          '($reviewsCount)',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class _HorizontalCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onWishlistToggle;
  final bool isWishlisted;
  final bool showWishlist;
  final bool showRating;
  final bool showDiscount;
  final bool showStock;
  final String heroSuffix;

  const _HorizontalCard({
    required this.product,
    this.onWishlistToggle,
    required this.isWishlisted,
    required this.showWishlist,
    required this.showRating,
    required this.showDiscount,
    required this.showStock,
    required this.heroSuffix,
  });

  @override
  Widget build(BuildContext context) {
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
            // Image
            SizedBox(
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_horizontal_${product.id}${heroSuffix.isNotEmpty ? '_$heroSuffix' : ''}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                      child: product.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.images.first,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 300),
                              placeholder: (context, url) => const ShimmerWidget(),
                            )
                          : Center(child: Icon(Icons.image_outlined, color: colorScheme.outline)),
                    ),
                  ),
                  if (showDiscount && product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: AppShapes.radius8,
                        ),
                        child: Text(
                          '${product.discountPercentage.round()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.subcategory ?? product.category ?? '',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 2,
                          children: [
                            Text(
                              '₹${product.price.round()}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                              ),
                            ),
                            if (product.hasDiscount)
                              Text(
                                '₹${product.originalPrice?.round()}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (showWishlist)
                        IconButton(
                          onPressed: onWishlistToggle,
                          icon: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : colorScheme.onSurface.withValues(alpha: 0.4),
                            size: 22,
                          ),
                        ),
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
}

class _CompactCard extends StatelessWidget {
  final ProductModel product;

  const _CompactCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: AppShapes.radius8,
        child: product.images.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: product.images.first,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image),
      ),
      title: Text(
        product.name, 
        maxLines: 1, 
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '₹${product.price.round()}',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
