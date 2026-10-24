import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/dialogs/premium_alert.dart';
import '../../../../core/ui/snackbars/premium_snackbar.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/image_gallery.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/quantity_selector.dart';
import '../../../../shared/widgets/review_card.dart';
import '../../../../shared/widgets/selection_pickers.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../../wishlist/presentation/providers/wishlist_notifier.dart';
import '../../data/models/product_model.dart';
import '../providers/product_details_notifier.dart';
import '../widgets/product_lightbox.dart';
import '../widgets/product_purchase_bar.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _pincodeController = TextEditingController();
  bool _isNavigating = false;

  void _navigateToCart() {
    if (_isNavigating) return;
    _isNavigating = true;
    context.go('/cart');
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(productDetailsProvider(widget.productId).notifier).loadMoreRelatedProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailsProvider(widget.productId));
    final isWishlisted = ref.watch(wishlistProvider.select((s) => s.isWishlisted(widget.productId)));
    final cartState = ref.watch(cartProvider);
    final bool isInCart = cartState.isInCart(widget.productId, state.selectedSize, state.selectedColor);
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = LayoutUtils.isDesktop(context);

    if (state.isLoading) {
      return const ProductDetailsSkeleton();
    }

    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Failed to load product details',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.read(productDetailsProvider(widget.productId).notifier).loadProductDetails(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final product = state.product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Product Not Found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The requested product could not be located.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref
                      .read(productDetailsProvider(widget.productId).notifier)
                      .loadProductDetails(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final availableStock = product.getStockForSize(state.selectedSize.isNotEmpty ? state.selectedSize : null);

    final galleryWidget = Container(
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
          Hero(
            tag: 'product_${widget.productId}',
            child: ImageGallery(
              images: product.images,
              onImageTap: (index) => _openLightbox(context, product.images, index),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                Hero(
                  tag: 'wishlist_${widget.productId}',
                  child: _buildFloatingAction(
                    context,
                    icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? theme.colorScheme.error : theme.colorScheme.onSurface,
                    onTap: () => ref.read(wishlistProvider.notifier).toggleWishlist(widget.productId),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFloatingAction(
                  context,
                  icon: Icons.share_outlined,
                  onTap: () {}, // Share
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
        // Basic Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (product.rating != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      product.rating!.toStringAsFixed(1),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, color: Colors.black, size: 12),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          product.subcategory ?? product.category ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        // Price
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              '₹${product.price.round()}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
              ),
            ),
            if (product.hasDiscount) ...[
              Text(
                '₹${product.originalPrice?.round()}',
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${product.discountPercentage.round()}% OFF',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),

        // Stock Status
        _buildStockBadge(context, product, state.selectedSize),
        const SizedBox(height: 24),

        // Color Picker
        if (product.colors.isNotEmpty) ...[
          const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ColorPicker(
            colors: product.colors,
            selectedColor: state.selectedColor,
            onSelected: (color) => ref
                .read(productDetailsProvider(widget.productId).notifier)
                .selectColor(color),
          ),
          const SizedBox(height: 24),
        ],

        // Size Picker
        if (product.sizes.isNotEmpty || (product.sizeStock?.isNotEmpty ?? false)) ...[
          const Text('Select Size', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizePicker(
            sizes: product.sizes.isNotEmpty ? product.sizes : (product.sizeStock?.keys.toList() ?? []),
            sizeStock: product.sizeStock,
            masterStock: product.stock > 0 ? product.stock : product.totalStock,
            selectedSize: state.selectedSize,
            onSelected: (size) => ref
                .read(productDetailsProvider(widget.productId).notifier)
                .selectSize(size),
          ),
          const SizedBox(height: 24),
        ],

        // Quantity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
            if (availableStock > 0 && availableStock <= 5)
              Text(
                'Only $availableStock left!',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        QuantitySelector(
          quantity: state.quantity,
          maxQuantity: availableStock > 0 ? availableStock : 1,
          onChanged: (q) => ref
              .read(productDetailsProvider(widget.productId).notifier)
              .updateQuantity(q),
          onMaxReached: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Only $availableStock items available in stock'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Delivery Check
        _buildDeliveryCheck(context, ref, widget.productId, state),
        const SizedBox(height: 32),

        // Expandable Product Info
        _buildInfoSection(context, 'Product Details', product.description ?? 'No description available.'),
        _buildInfoSection(context, 'Material & Care', 'Premium quality fabric. Hand wash recommended.'),
        _buildInfoSection(context, 'Size Guide', 'Available in S, M, L, XL. Standard regular fit.'),

        const SizedBox(height: 32),

        // Reviews
        _buildReviewSection(context, ref, theme, state),
        const SizedBox(height: 32),

        // Related Products & Infinite Scroll Section
        if (state.relatedProducts.isNotEmpty) ...[
          const Text('You May Also Like', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          SizedBox(
            height: 360,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.relatedProducts.length + (state.isLoadingMoreRelated ? 2 : 0),
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                if (index >= state.relatedProducts.length) {
                  return const SizedBox(
                    width: 180,
                    child: ProductCardSkeleton(),
                  );
                }
                return SizedBox(
                  width: 180,
                  child: ProductCard(
                    product: state.relatedProducts[index],
                    heroSuffix: 'related_$index',
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 120),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: ResponsiveContainer(
          child: isDesktop
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: galleryWidget),
                      const SizedBox(width: 32),
                      Expanded(flex: 7, child: detailsContent),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    galleryWidget,
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: detailsContent,
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: ResponsiveContainer.bottomBar(
        child: ProductPurchaseBar(
          isAvailable: availableStock > 0,
          isInCart: isInCart,
          isLoading: cartState.isLoading,
          onAddToCart: () async {
            if (_isNavigating) return;
            if (isInCart) {
              _navigateToCart();
              return;
            }
            final success = await ref.read(cartProvider.notifier).addToCart(
              productId: widget.productId,
              quantity: state.quantity,
              size: state.selectedSize,
              color: state.selectedColor,
            );
            if (success && context.mounted) {
              final confirmed = await PremiumAlert.confirm(
                context,
                title: 'Added to Cart',
                message: '${product.name} has been added to your bag.',
                confirmText: 'Go to Cart',
                cancelText: 'Continue Shopping',
              );
              if (confirmed && context.mounted) {
                _navigateToCart();
              }
            }
          },
          onBuyNow: () {
            if (_isNavigating) return;
            _isNavigating = true;
            context.push('/checkout', extra: [
              CartItemModel(
                id: 'temp_${widget.productId}',
                productId: widget.productId,
                name: product.name,
                price: product.price,
                quantity: state.quantity,
                selectedSize: state.selectedSize,
                selectedColor: state.selectedColor,
                images: product.images,
                stock: availableStock,
              )
            ]).then((_) {
              if (mounted) setState(() => _isNavigating = false);
            });
          },
        ),
      ),
    );
  }

  void _openLightbox(BuildContext context, List<String> images, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) => ProductLightbox(images: images, initialIndex: index),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAction(BuildContext context, {required IconData icon, Color? color, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: color ?? theme.colorScheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildStockBadge(BuildContext context, ProductModel product, String selectedSize) {
    final theme = Theme.of(context);
    final int stock = product.getStockForSize(selectedSize.isNotEmpty ? selectedSize : null);

    if (stock <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(20)),
        child: Text('Out of Stock', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        stock <= 5 ? 'Only $stock left' : 'In Stock ($stock available)',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildDeliveryCheck(BuildContext context, WidgetRef ref, String productId, ProductDetailsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Check Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _pincodeController,
                hintText: 'Enter PIN Code',
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (v) {
                  if (v.length == 6) {
                    ref.read(productDetailsProvider(productId).notifier).checkShipping(v);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            if (state.isCheckingShipping)
              const CircularProgressIndicator()
          ],
        ),
        if (state.shippingMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.shippingMessage!,
              style: TextStyle(
                color: state.isShippingServiceable ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context, WidgetRef ref, ThemeData theme, ProductDetailsState state) {
    final authStatus = ref.watch(authProvider).status;
    final isAuthenticated = authStatus == AuthStatus.authenticated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if (state.reviews.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${state.product?.rating?.toStringAsFixed(1) ?? "0.0"} (${state.reviews.length} reviews)',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
              ],
            ),
            if (state.canReview)
              TextButton.icon(
                onPressed: () => _showReviewComposer(context),
                icon: const Icon(Icons.edit_note),
                label: const Text('Write a Review'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Status message for review eligibility
        if (!state.canReview)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  state.hasReviewed ? Icons.check_circle_outline : Icons.info_outline, 
                  size: 18,
                  color: state.hasReviewed ? Colors.green : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !isAuthenticated 
                          ? 'Sign in to share your experience with this product.'
                          : state.hasReviewed 
                            ? "You've already shared your review for this product." 
                            : 'Only verified buyers can review this product.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (!isAuthenticated)
                        GestureDetector(
                          onTap: () => context.push('/login'),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Login Now',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
        if (state.reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No reviews yet. Be the first to review!',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          ...state.reviews.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReviewCard(review: r),
              )),
        if (state.reviews.length > 3)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // View all reviews
              },
              child: const Text('View All Reviews'),
            ),
          ),
      ],
    );
  }

  void _showReviewComposer(BuildContext context) {
    int selectedRating = 5;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: LayoutUtils.maxFormWidth),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rate this Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final ratingValue = index + 1;
                    return IconButton(
                      icon: Icon(
                        ratingValue <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 40,
                        color: Colors.amber,
                      ),
                      onPressed: () => setModalState(() => selectedRating = ratingValue),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: textController,
                  hintText: 'Share your experience (optional)',
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                Consumer(
                  builder: (context, modalRef, _) {
                    final isSubmitting = modalRef.watch(productDetailsProvider(widget.productId)).isSubmittingReview;
                    return PrimaryButton(
                      text: 'Submit Review',
                      loading: isSubmitting,
                      onPressed: () async {
                        final success = await modalRef.read(productDetailsProvider(widget.productId).notifier).submitReview(
                              rating: selectedRating,
                              text: textController.text.trim(),
                            );
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          PremiumSnackbar.showSuccess(context, 'Thank you for your review!');
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
