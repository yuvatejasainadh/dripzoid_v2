import 'package:flutter/material.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../products/data/models/product_model.dart';

class AiProductCarousel extends StatelessWidget {
  final List<ProductModel> products;

  const AiProductCarousel({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 300,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 40), // Offset for chat bubble alignment
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 160,
            child: ProductCard(
              product: products[index],
              showWishlist: false,
              showDiscount: false,
            ),
          );
        },
      ),
    );
  }
}
