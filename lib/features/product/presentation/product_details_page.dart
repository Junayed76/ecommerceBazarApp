import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_cached_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/provider/cart_provider.dart';
import '../models/product.dart';
import '../provider/product_provider.dart';

/// Product details with image, description, quantity stepper and add to cart.
class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().loadProduct(widget.productId);
    });
  }

  void _addToCart(Product product) {
    context.read<CartProvider>().add(
      CartItem(product: product, quantity: _quantity),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$_quantity × ${product.title} added to cart'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View cart',
            onPressed: () => context.push(AppRouter.cartPath),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = provider.selectedProduct?.id == widget.productId
        ? provider.selectedProduct
        : null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: product == null
          ? _buildPlaceholder(provider)
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.15,
                    child: Container(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF1F2F6),
                      child: AppCachedImage(
                        url: product.thumbnail,
                        fit: BoxFit.contain,
                        iconSize: 56,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                Formatters.titleCase(product.category),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (product.rating > 0) ...[
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${product.rating.toStringAsFixed(1)} / 5.0',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        if (product.brand.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'by ${product.brand}',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.money(product.discountedPrice),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  Formatters.money(product.price),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  '${product.discountPercentage.toStringAsFixed(0)}% off',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              product.isInStock
                                  ? Icons.check_circle_rounded
                                  : Icons.remove_circle_rounded,
                              size: 16,
                              color: product.isInStock
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.isInStock
                                  ? 'In stock (${product.stock} available)'
                                  : 'Out of stock',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: product.isInStock
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description.isEmpty
                              ? 'No description available for this product.'
                              : product.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                        if (product.tags.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: product.tags
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: theme.dividerTheme.color!,
                                      ),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: const TextStyle(fontSize: 11.5),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            _QuantityStepper(
                              quantity: _quantity,
                              onChanged: (value) =>
                                  setState(() => _quantity = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: product == null
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border(
                  top: BorderSide(color: theme.dividerTheme.color!),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton.icon(
                  onPressed: product.isInStock ? () => _addToCart(product) : null,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: Text(
                    product.isInStock
                        ? 'Add to cart • ${Formatters.money(product.discountedPrice * _quantity)}'
                        : 'Out of stock',
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPlaceholder(ProductProvider provider) {
    if (provider.isLoadingDetail) {
      return const Center(child: CircularProgressIndicator());
    }
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'Product unavailable',
      message:
          provider.errorMessage ?? 'We could not find this product anymore.',
      actionLabel: 'Back to catalog',
      onAction: () => context.go(AppRouter.homePath),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove, size: 16),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add, size: 16),
            onPressed: quantity < 25 ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}
