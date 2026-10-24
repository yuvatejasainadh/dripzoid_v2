import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/banner_carousel.dart';
import '../../../../shared/widgets/category_card.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../providers/home_notifier.dart';
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: ResponsiveContainer(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              
              // Banners
              SliverToBoxAdapter(
                child: homeState.isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: ShimmerWidget.rectangular(height: 200),
                      )
                    : BannerCarousel(banners: homeState.banners),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Categories
              _SliverCategorySection(homeState: homeState),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Featured Section
              _SliverProductGrid(
                title: 'Featured Picks',
                products: homeState.featuredProducts,
                isLoading: homeState.isLoading,
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Trending Section
              _SliverTrendingSection(homeState: homeState),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverCategorySection extends StatelessWidget {
  final HomeState homeState;
  const _SliverCategorySection({required this.homeState});

  static IconData getCategoryIcon(String category) {
    final lower = category.trim().toLowerCase();
    switch (lower) {
      case 'men':
      case 'man':
      case 'male':
        return Icons.man;
      case 'women':
      case 'woman':
      case 'female':
        return Icons.woman;
      case 'kids':
      case 'kid':
      case 'children':
        return Icons.child_care;
      case 'shoes':
      case 'footwear':
        return Icons.roller_skating_outlined;
      case 'accessories':
      case 'accessory':
        return Icons.watch_outlined;
      default:
        return Icons.checkroom_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {






    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Shop by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: homeState.isLoading
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) => const ShimmerWidget.circular(width: 80, height: 80),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: homeState.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      final category = homeState.categories[index];
                      return CategoryCard(
                        label: category.category,
                        icon: getCategoryIcon(category.category),
                        onTap: () => context.push('/shop?category=${category.category}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SliverProductGrid extends StatelessWidget {
  final String title;
  final List<dynamic> products;
  final bool isLoading;

  const _SliverProductGrid({
    required this.title,
    required this.products,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final columns = LayoutUtils.getGridColumnCount(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            SliverProductGridSkeleton(
              columns: columns,
              itemCount: columns * 2,
            )
          else
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: LayoutUtils.getProductGridRatio(context),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(
                  product: products[index],
                  heroSuffix: 'featured',
                ),
                childCount: products.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _SliverTrendingSection extends StatelessWidget {
  final HomeState homeState;
  const _SliverTrendingSection({required this.homeState});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trending Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 380,
            child: homeState.isLoading
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) => const SizedBox(
                      width: 200,
                      child: ProductCardSkeleton(),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: homeState.trendingProducts.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 200,
                        child: ProductCard(
                          product: homeState.trendingProducts[index],
                          heroSuffix: 'trending',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
