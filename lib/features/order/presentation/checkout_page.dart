import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/provider/auth_provider.dart';
import '../../cart/provider/cart_provider.dart';
import '../models/payment_method.dart';
import '../models/shipping_address.dart';
import '../provider/order_provider.dart';
import 'widgets/payment_option_tile.dart';

/// Checkout: delivery details, payment method and the final order summary.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Dhaka');
  final _postalController = TextEditingController(text: '1200');
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      context.push(AppRouter.signInPath);
      return;
    }

    final order = await orders.placeOrder(
      items: cart.items,
      subtotal: cart.subtotal,
      tax: cart.tax,
      total: cart.total,
      address: ShippingAddress(
        fullName: _nameController.text.trim(),
        addressLine: _addressController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
      user: user,
    );

    if (!mounted) return;

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orders.errorMessage ?? 'Order could not be placed.'),
        ),
      );
      return;
    }

    await cart.clear();
    if (!mounted) return;
    context.go(AppRouter.orderSuccessPath(order.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final orders = context.watch<OrderProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.lock_outline,
          title: 'Sign in to continue',
          message: 'You need an account to place an order.',
          actionLabel: 'Sign in',
          onAction: () => context.push(AppRouter.signInPath),
        ),
      );
    }

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Nothing to check out',
          message: 'Add some products to your cart first.',
          actionLabel: 'Browse products',
          onAction: () => context.go(AppRouter.homePath),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const _SectionTitle('Delivery address'),
            const SizedBox(height: 10),
            _Panel(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Recipient name',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Recipient name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Street address',
                      hintText: 'House, road, area',
                      prefixIcon: Icon(Icons.home_outlined, size: 20),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Street address is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _cityController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'City',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _postalController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Postal code',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().length < 6)
                        ? 'Enter a valid phone number'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle('Payment method'),
            const SizedBox(height: 10),
            _Panel(
              child: Column(
                children: [
                  for (final method in PaymentMethod.values)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: method == PaymentMethod.values.last ? 0 : 8,
                      ),
                      child: PaymentOptionTile(
                        method: method,
                        isSelected: orders.selectedPaymentMethod == method,
                        onSelected: () => orders.selectPaymentMethod(method),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle('Order summary'),
            const SizedBox(height: 10),
            _Panel(
              child: Column(
                children: [
                  _Line(
                    label: 'Items (${cart.itemCount})',
                    value: Formatters.money(cart.subtotal),
                  ),
                  const SizedBox(height: 8),
                  _Line(
                    label:
                        'Tax (${(CartProvider.taxRate * 100).round()}%)',
                    value: Formatters.money(cart.tax),
                  ),
                  const SizedBox(height: 8),
                  const _Line(label: 'Delivery', value: 'Free'),
                  const Divider(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total payable',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        Formatters.money(cart.total),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: orders.isPlacing ? null : _placeOrder,
              child: orders.isPlacing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Place order'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerTheme.color!),
      ),
      child: child,
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.65);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: muted)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
