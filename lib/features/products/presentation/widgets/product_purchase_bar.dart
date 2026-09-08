import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';

class ProductPurchaseBar extends StatelessWidget {
  final bool isAvailable;
  final bool isInCart;
  final bool isLoading;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const ProductPurchaseBar({
    super.key,
    required this.isAvailable,
    required this.isInCart,
    required this.isLoading,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          // Add to Cart / Go to Cart
          Expanded(
            child: PrimaryButton(
              onPressed: isAvailable ? onAddToCart : null,
              loading: isLoading,
              icon: isInCart ? Icons.shopping_bag : Icons.shopping_cart_outlined,
              text: isAvailable 
                ? (isInCart ? 'Go to Cart' : 'Add to Cart')
                : 'Out of Stock',
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Buy Now
          if (isAvailable && !isInCart)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBuyNow,
                icon: const Icon(Icons.flash_on, size: 20),
                label: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
