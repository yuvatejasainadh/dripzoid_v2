import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/layout_utils.dart';
import '../../../../shared/widgets/banner_carousel.dart';
import '../../../../shared/widgets/category_card.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../providers/home_notifier.dart';
import '../providers/search_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            if (searchState.query.isNotEmpty)
              _SliverSearchResults(searchState: searchState)
            else ...[
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
          ],
        ),
      ),
    );
  }
}

class _SliverSearchResults extends StatelessWidget {
  final SearchState searchState;
  const _SliverSearchResults({required this.searchState});

  @override
  Widget build(BuildContext context) {
    if (searchState.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (searchState.results.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No results for "${searchState.query}"',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: LayoutUtils.getProductGridRatio(context),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(
            product: searchState.results[index],
            heroSuffix: 'search',
          ),
          childCount: searchState.results.length,
        ),
      ),
    );
  }
}

class _SliverCategorySection extends StatelessWidget {
  final HomeState homeState;
  const _SliverCategorySection({required this.homeState});

  @override
  Widget build(BuildContext context) {
    final categoryIcons = {
      'Men': 'https://res.cloudinary.com/dvid0uzwo/image/upload/v1769234530/my_project/q9yp4y9u9db6plxswvqm.jpg',
      'Women': 'https://res.cloudinary.com/dvid0uzwo/image/upload/v1769234485/my_project/jjohfsp34dtkjqpbwdju.jpg',
      'Kids': 'https://res.cloudinary.com/dvid0uzwo/image/upload/v1769234558/my_project/axzwtgc54k9u7jcryawe.jpg',
    };

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
                        imageUrl: categoryIcons[category.category] ?? '',
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
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: LayoutUtils.getProductGridRatio(context),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => const ShimmerWidget.rectangular(height: 250),
                childCount: 4,
              ),
            )
          else
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
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
                    itemBuilder: (context, index) => const ShimmerWidget.rectangular(width: 200, height: 380),
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
