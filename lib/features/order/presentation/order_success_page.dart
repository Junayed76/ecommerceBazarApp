import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../provider/order_provider.dart';

/// Confirmation screen shown right after a successful checkout.
class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = context.watch<OrderProvider>().lastOrder;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Order placed'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 54,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Thank you for your order!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have received your order and will start preparing it shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerTheme.color!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order reference',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        Flexible(
                          child: SelectableText(
                            orderId,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (order != null) ...[
                      const Divider(height: 22),
                      _Row(
                        label: 'Items',
                        value: '${order.itemCount}',
                      ),
                      const SizedBox(height: 8),
                      _Row(
                        label: 'Payment',
                        value: order.paymentMethod.label,
                      ),
                      const SizedBox(height: 8),
                      _Row(
                        label: 'Total paid',
                        value: Formatters.money(order.total),
                        highlighted: true,
                      ),
                      const SizedBox(height: 8),
                      _Row(
                        label: 'Deliver to',
                        value: order.shippingAddress.city,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRouter.homePath),
                  child: const Text('Continue shopping'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push(AppRouter.ordersPath),
                  child: const Text('View my orders'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlighted ? 15 : 13,
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
            color: highlighted ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}
