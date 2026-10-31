import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/profile_page.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/order/presentation/checkout_page.dart';
import '../../features/order/presentation/order_success_page.dart';
import '../../features/order/presentation/orders_page.dart';
import '../../features/product/presentation/product_details_page.dart';
import '../../features/product/presentation/product_list_page.dart';

/// Single place where every route of the app is declared.
class AppRouter {
  AppRouter._();

  static const String homePath = '/';
  static const String cartPath = '/cart';
  static const String signInPath = '/sign-in';
  static const String profilePath = '/profile';
  static const String checkoutPath = '/checkout';
  static const String ordersPath = '/orders';

  static String productDetailsPath(int id) => '/product/$id';

  static String orderSuccessPath(String orderId) => '/order-success/$orderId';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        name: 'home',
        builder: (context, state) => const ProductListPage(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'productDetails',
        builder: (context, state) => ProductDetailsPage(
          productId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: cartPath,
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: signInPath,
        name: 'signIn',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: profilePath,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: checkoutPath,
        name: 'checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/order-success/:orderId',
        name: 'orderSuccess',
        builder: (context, state) => OrderSuccessPage(
          orderId: state.pathParameters['orderId'] ?? '',
        ),
      ),
      GoRoute(
        path: ordersPath,
        name: 'orders',
        builder: (context, state) => const OrdersPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_outlined, size: 56),
              const SizedBox(height: 14),
              const Text(
                'This page does not exist',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                state.uri.path,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go(homePath),
                child: const Text('Go to catalog'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
