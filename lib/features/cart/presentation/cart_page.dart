import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/cart_provider.dart';
import 'widgets/cart_item_tile.dart';

/// Shopping cart with quantity editing, removal and a totals footer.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Empty the cart?'),
        content: const Text('This removes every product from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Remove all',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) await cart.clear();
  }

  Future<void> _goToCheckout(BuildContext context) async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    if (!context.read<AuthProvider>().isAuthenticated) {
      final shouldSignIn = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Sign in required'),
          content: const Text(
            'You need an account to place an order. Sign in and come back to finish your purchase.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sign in'),
            ),
          ],
        ),
      );

      if (shouldSignIn == true && context.mounted) {
        context.push(AppRouter.signInPath);
      }
      return;
    }

    context.push(AppRouter.checkoutPath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cart.isEmpty ? 'Cart' : 'Cart (${cart.itemCount})',
        ),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'Empty cart',
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message:
                  'Browse the catalog and add a few products to see them here.',
              actionLabel: 'Start shopping',
              onAction: () => context.go(AppRouter.homePath),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Dismissible(
                  key: ValueKey(item.product.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => cart.remove(item.product.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  child: CartItemTile(item: item),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border(
                  top: BorderSide(color: theme.dividerTheme.color!),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SummaryRow(
                      label: 'Subtotal',
                      value: Formatters.money(cart.subtotal),
                    ),
                    const SizedBox(height: 6),
                    _SummaryRow(
                      label: 'Tax (${(CartProvider.taxRate * 100).round()}%)',
                      value: Formatters.money(cart.tax),
                    ),
                    const Divider(height: 20),
                    _SummaryRow(
                      label: 'Total',
                      value: Formatters.money(cart.total),
                      emphasised: true,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _goToCheckout(context),
                        child: const Text('Proceed to checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final labelStyle = TextStyle(
      fontSize: emphasised ? 15.5 : 13.5,
      fontWeight: emphasised ? FontWeight.w700 : FontWeight.w500,
      color: emphasised
          ? null
          : theme.colorScheme.onSurface.withValues(alpha: 0.65),
    );

    final valueStyle = TextStyle(
      fontSize: emphasised ? 18 : 13.5,
      fontWeight: emphasised ? FontWeight.w800 : FontWeight.w600,
      color: emphasised ? AppColors.primary : null,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
