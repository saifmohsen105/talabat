import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/order_repository.dart';
import '../data/product_repository.dart';
import '../services/auth_service.dart';
import '../state/auth_controller.dart';
import '../state/cart_controller.dart';
import '../state/orders_controller.dart';
import '../state/products_controller.dart';
import 'router.dart';
import 'theme.dart';

class TalabatCloneApp extends StatefulWidget {
  const TalabatCloneApp({super.key});

  @override
  State<TalabatCloneApp> createState() => _TalabatCloneAppState();
}

class _TalabatCloneAppState extends State<TalabatCloneApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(AuthService())),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => CartController(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsController(ProductRepository())..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersController(OrderRepository()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Talabat Clone',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}

class SetupRequiredApp extends StatelessWidget {
  const SetupRequiredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restaurant_menu, size: 56, color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Connect your Supabase project',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Open lib/app/env.dart and paste SUPABASE_URL and SUPABASE_ANON_KEY. '
                      'Then restart the app.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}