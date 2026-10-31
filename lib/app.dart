import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/preference_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/cart/data/cart_repository.dart';
import 'features/cart/provider/cart_provider.dart';
import 'features/order/data/order_repository.dart';
import 'features/order/provider/order_provider.dart';
import 'features/product/data/product_repository.dart';
import 'features/product/provider/product_provider.dart';

/// Root of the widget tree: builds the repositories, injects them into the
/// providers and mounts the router.
class BazaarApp extends StatelessWidget {
  const BazaarApp({
    super.key,
    required this.dioClient,
    required this.preferenceService,
  });

  final DioClient dioClient;
  final PreferenceService preferenceService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: AuthRepositoryImpl(
              remoteDataSource: AuthRemoteDataSourceImpl(dioClient: dioClient),
              preferenceService: preferenceService,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            repository: ProductRepositoryImpl(dioClient: dioClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(
            repository: CartRepositoryImpl(preferenceService: preferenceService),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            repository: OrderRepositoryImpl(
              preferenceService: preferenceService,
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Bazaar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
