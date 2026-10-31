import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/provider/auth_provider.dart';
import '../../cart/provider/cart_provider.dart';
import '../provider/product_provider.dart';
import 'widgets/product_card.dart';

/// Home screen: searchable, category-filtered product grid.
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<ProductProvider>().search(value.trim());
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {});
    context.read<ProductProvider>().search('');
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Bazaar'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: auth.isAuthenticated ? 'My account' : 'Sign in',
            onPressed: () => context.push(
              auth.isAuthenticated
                  ? AppRouter.profilePath
                  : AppRouter.signInPath,
            ),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  auth.isAuthenticated
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                ),
                if (auth.isAuthenticated)
                  const Positioned(
                    right: -1,
                    top: -1,
                    child: _Dot(color: AppColors.success),
                  ),
              ],
            ),
          ),
          _CartButton(count: cart.itemCount),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                context.read<ProductProvider>().search(value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search for phones, watches, perfume...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _clearSearch,
                      ),
              ),
            ),
          ),
          _CategoryBar(
            categories: products.categories,
            selected: products.selectedCategory,
            onSelected: products.selectCategory,
          ),
          Expanded(child: _buildBody(products)),
        ],
      ),
    );
  }

  Widget _buildBody(ProductProvider products) {
    if (products.isLoading && !products.hasProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.errorMessage != null && !products.hasProducts) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load products',
        message: products.errorMessage!,
        actionLabel: 'Try again',
        onAction: products.loadProducts,
      );
    }

    if (!products.hasProducts) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message:
            'Nothing matched your search. Try a different keyword or category.',
        actionLabel: 'Clear filters',
        onAction: () {
          _searchController.clear();
          setState(() {});
          products.clearFilters();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: products.loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        itemCount: products.products.length,
        itemBuilder: (context, index) =>
            ProductCard(product: products.products[index]),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          return ChoiceChip(
            label: Text(Formatters.titleCase(category)),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(category),
            selectedColor: AppColors.primary,
            backgroundColor: Theme.of(context).cardTheme.color,
            labelStyle: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).dividerTheme.color!,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Cart',
      onPressed: () => context.push(AppRouter.cartPath),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_bag_outlined),
          if (count > 0)
            Positioned(
              top: -6,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 17),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).appBarTheme.backgroundColor!,
          width: 1.5,
        ),
      ),
    );
  }
}
