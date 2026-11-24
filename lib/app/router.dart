import 'package:go_router/go_router.dart';

import '../screens/about/about_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/faq/faq_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/product/product_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/splash/splash_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/shop', builder: (_, __) => const ShopScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) => ProductScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/faqs', builder: (_, __) => const FaqScreen()),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
    ],
  );
}
